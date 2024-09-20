import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/helpers/notication_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/pdf_control_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/size_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

final mediaStorePlugin = MediaStore();

class PdfProvider with ChangeNotifier {
  final NotificationHelper notificationHelper = NotificationHelper();
  final PdfControlProvider controlProvider = PdfControlProvider();

  PdfProvider() {
    _loadPdfListFromHive();
  }

  PdfModel? _currentPDF;
  bool _isLoading = false;
  bool _downloadBtnLoading = false;
  final bool _moreBtnLoading = false;
  bool _isInternetConnected = false;
  PDFViewController? _pdfController;
  List<SharedMediaFile> sharedFiles = [];
  Map<String, PdfModel> _totalPdfList = {};
  Map<String, PdfModel> _favoritesList = {};
  Map<String, PdfModel> _selectedFiles = {};
  late StreamSubscription _intentSubscription;
  late StreamSubscription _internetSubscription;
  ViewMode _viewMode = ViewMode.grid;
  final int _pdfCurrentPage = 0;
  int notificationIdCounter = 0;
  int _currentIndex = 0;
  double _downloadProgress = 0.0;
  bool _isMultiSelected = false;
  bool _showPdfTools = false;
  bool _showAppbar = true;
  bool _considerScroll = false;
  String _uriPath = "";
  DownloadStatus? _downloadStatus = DownloadStatus.ongoing;
  CancelToken _cancelToken = CancelToken();

  PdfModel? get currentPDF => _currentPDF;
  bool get isLoading => _isLoading;
  DownloadStatus? get downloadStatus => _downloadStatus!;
  bool get downloadBtnLoading => _downloadBtnLoading;
  bool get moreBtnLoading => _moreBtnLoading;
  int get pdfCurrentPage => _pdfCurrentPage;
  bool get isMultiSelected => _isMultiSelected;
  bool get isInternetConnected => _isInternetConnected;
  PDFViewController get pdfController => _pdfController!;
  Map<String, PdfModel> get totalPdfList => _totalPdfList;
  Map<String, PdfModel> get favoritesList => _favoritesList;
  Map<String, PdfModel> get selectedFiles => _selectedFiles;
  double get downloadProgress => _downloadProgress;
  ViewMode get selectedViewMode => _viewMode;
  bool get showPdfTools => _showPdfTools;
  bool get showAppbar => _showAppbar;
  bool get considerScroll => _considerScroll;
  int get currentIndex => _currentIndex;

  Dio dio = Dio();

  Future<void> _loadPdfListFromHive() async {
    _totalPdfList = HiveHelper.getHivePdfList();
    _favoritesList = HiveHelper.getFavoritePdfList();
    debugPrint("_totalPdfList ${_totalPdfList.length}");
    notifyListeners();
  }

  Future<void> initializeNotifications() async {
    await notificationHelper.initializeNotifications();
  }

  Future<void> askPermissions() async {
    List<Permission> permissions = [
      Permission.storage,
      Permission.notification,
    ];

    Map<Permission, PermissionStatus> permissionStatus =
        await permissions.request();

    for (var permission in permissionStatus.entries) {
      final status = permission.value;
      switch (status) {
        case PermissionStatus.granted:
          debugPrint('${permission.key} permission granted');
          break;
        case PermissionStatus.denied:
          debugPrint('${permission.key} permission denied');

          break;
        case PermissionStatus.permanentlyDenied:
          debugPrint('${permission.key} permission permanently denied');
          break;
        default:
          break;
      }
    }
  }

  void resetValues() {
    _isLoading = false;
    _downloadProgress = 0.0;
    _uriPath = "";
    notifyListeners();
  }

  Future<void> internetSubscription() async {
    final connectionChecker = InternetConnectionChecker();

    bool isConnectedNow = await connectionChecker.hasConnection;
    _isInternetConnected = isConnectedNow;
    notifyListeners();

    log("isConnectedNow $isConnectedNow $_isInternetConnected");

    _internetSubscription = connectionChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        if (status == InternetConnectionStatus.connected) {
          _isInternetConnected = true;
          notifyListeners();
          log('Connected to the internet');
        } else {
          _isInternetConnected = false;
          notifyListeners();
          log('Disconnected from the internet');
        }
      },
    );
  }

  void internetDispose() {
    _internetSubscription.cancel();
  }

  Future<File> getPdfDownloadDirectory(String fileName) async {
    final directory = await getApplicationSupportDirectory();
    final filepath = File("${directory.path}/$fileName");
    return filepath;
  }

  Future<bool> isValidUrl(String url) async {
    try {
      final response = await dio.head(url);
      // debugPrint("url headers ${response.headers}");
      if (response.statusCode == 200 &&
          response.headers.value("content-type") == "application/pdf") {
        return true;
      }
    } catch (e) {
      debugPrint("Error while checking URL $e");
      ToastUtils.showErrorToast("Error while checking URL ");
    }
    return false;
  }

  File getDownloadedFilePath({
    String? relativePath,
    required String fileName,
    required DirType dirType,
    required DirName dirName,
  }) {
    final downloadedFile = File(
        "${dirType.fullPath(relativePath: relativePath.orAppFolder, dirName: dirName)}/$fileName");
    return downloadedFile;
  }

  Future<bool> checkIfFileExists(String fileName) async {
    try {
      final Uri? uri = await mediaStorePlugin.getFileUri(
          fileName: fileName,
          dirType: DirType.download,
          dirName: DirType.download.defaults);
      if (uri != null) {
        _uriPath = uri.path;
        debugPrint("checkIfFileExists ${uri.path} ");
        return true;
      }
    } catch (e) {
      ToastUtils.showErrorToast("Something went wrong, please try again!");
    }
    return false;
  }

  Future<void> downloadAndSavePdf(String url) async {
    setDownloadBtnLoading(true);
    setDownloadProgress(0.0);

    bool validUrl = await isValidUrl(url);
    if (url.isEmpty || !validUrl) {
      ToastUtils.showErrorToast("Enter a valid URL");
      resetValues();
      setDownloadBtnLoading(false);
      return;
    }

    String fileName = getFileNameFromPath(url);
    final File tempFilePath = await getPdfDownloadDirectory(fileName);

    int notificationId = notificationHelper.generateNotificationId();
    PdfModel downloadPdf = PdfModel(
      id: "",
      filePath: '',
      fileName: fileName,
      pageNumber: 0,
      lastOpened: DateTime.now(),
      createdAt: DateTime.now(),
      downloadProgress: 0.0,
      networkUrl: url,
      downloadStatus: DownloadStatus.ongoing.name,
      fileSize: "",
    );
    addToTotalPdfList(downloadPdf);

    // log("file exists $fileExists");
    if (_totalPdfList.containsKey(fileName)) {
      ToastUtils.showErrorToast("File already exists");
      resetValues();
      setDownloadBtnLoading(false);
      return;
    }

    try {
      await notificationHelper.showProgressNotification(
        notificationId: notificationId,
        title: "Downloading PDF",
        body: fileName,
        progress: 0,
      );

      final response = await dio.download(
        url,
        tempFilePath.path,
        cancelToken: _cancelToken,
        onReceiveProgress: (count, total) async {
          double progress = count / total;
          setDownloadProgress(progress);

          await notificationHelper.showProgressNotification(
            notificationId: notificationId,
            title: "Downloading PDF",
            body: fileName,
            progress: progress,
          );
        },
      );

      if (response.statusCode == 200) {
        final SaveInfo? saveInfo = await mediaStorePlugin.saveFile(
          tempFilePath: tempFilePath.path,
          dirType: DirType.download,
          dirName: DirType.download.defaults,
        );

        if (saveInfo != null && saveInfo.isSuccessful) {
          File downloadedFilePath = getDownloadedFilePath(
            fileName: saveInfo.name,
            dirType: DirType.download,
            dirName: DirType.download.defaults,
          );

          final thumbnailBytes =
              await controlProvider.getPdfThumbNail(downloadedFilePath.path);

          final completedPdf = downloadPdf.copyWith(
            id: saveInfo.name,
            fileSize: downloadedFilePath.lengthSync().readableFileSize,
            filePath: downloadedFilePath.path,
            fileName: saveInfo.name,
            networkUrl: url,
            pageNumber: 0,
            downloadStatus: DownloadStatus.completed.name,
            downloadProgress: 1.0,
            lastOpened: DateTime.now(),
            createdAt: DateTime.now(),
            thumbnail: thumbnailBytes,
          );

          removeFromTotalPdfList(downloadPdf);
          addToTotalPdfList(completedPdf);
          await notificationHelper.cancelNotification(notificationId);
          await notificationHelper.showDownloadCompleteNotification(
            notificationId: notificationId,
            title: "Download Complete",
            body: fileName,
          );

          ToastUtils.showSuccessToast("File downloaded successfully");
        } else {
          throw Exception("Failed to save the file");
        }
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      removeFromTotalPdfList(downloadPdf);

      downloadPdf =
          downloadPdf.copyWith(downloadStatus: DownloadStatus.cancelled.name);

      addToTotalPdfList(downloadPdf);

      await notificationHelper.cancelNotification(notificationId);
      debugPrint(" download Error $e");
      ToastUtils.showErrorToast("Error while downloading file");
    } finally {
      setDownloadBtnLoading(false);
      resetValues();
    }
  }

  Future<void> restartDownload(String url) async {
    log("I'm here in restart pdf $url");
    _cancelToken = CancelToken();
    try {
      setDownloadProgress(0.0);
      setDownloadStatus(DownloadStatus.ongoing);

      await downloadAndSavePdf(
        url,
      );
    } catch (e) {
      debugPrint("Error while restarting the download: $e");
      ToastUtils.showErrorToast("Error restarting the download");
    }
  }

  Future<void> cancelDownload(PdfModel pdfModel) async {
    try {
      log("I'm here in cancel pdf");
      _cancelToken.cancel();

      await notificationHelper.cancelAllNotifications();
      int notificationId = notificationHelper.generateNotificationId();

      await removeFromTotalPdfList(pdfModel);

      await notificationHelper.showDownloadCancelNotification(
        notificationId: notificationId,
        title: "Download cancelled",
        body: pdfModel.fileName!,
      );
      final cancelledPdf =
          pdfModel.copyWith(downloadStatus: DownloadStatus.cancelled.name);
      await addToTotalPdfList(cancelledPdf);
      notifyListeners();
      ToastUtils.showSuccessToast("File download cancelled");
    } catch (e) {
      debugPrint("Error while canceling the download: $e");
      ToastUtils.showErrorToast("Error canceling the download");
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setDownloadProgress(double value) {
    _downloadProgress = value;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setDownloadStatus(DownloadStatus status) {
    _downloadStatus = status;
    notifyListeners();
  }

  void setPdfToolsVisibility(bool status) {
    _showPdfTools = status;

    notifyListeners();
  }

  void setDownloadBtnLoading(bool value) {
    _downloadBtnLoading = value;
    notifyListeners();
  }

  void setMoreBtnLoading(bool value) {
    _downloadBtnLoading = value;
    notifyListeners();
  }

  void setAppBarVisibility(bool value) {
    _showAppbar = value;
    notifyListeners();
  }

  void setConsiderScroll(bool value) {
    _considerScroll = value;
    notifyListeners();
  }

  void setMultiSelect(bool value) {
    _isMultiSelected = value;
    notifyListeners();
  }

  Future<void> addToSelectedFiles(PdfModel pdf) async {
    log("i'm here in the add pdf ");
    if (!_selectedFiles.containsKey(pdf.fileName)) {
      setMultiSelect(true);
      pdf = pdf.copyWith(isSelected: true);

      _selectedFiles[pdf.id] = pdf;
      notifyListeners();
    }
    debugPrint("_selectedFiles ${_selectedFiles.length}");
  }

  Future<void> removeFromSelectedFiles(PdfModel pdf) async {
    log("i'm here in the add pdf ");

    if (_selectedFiles.isEmpty) {
      setMultiSelect(false);
    }
    if (_selectedFiles.containsKey(pdf.fileName)) {
      _selectedFiles.removeWhere((key, pdf) {
        return key == pdf.id;
      });
      removeFromTotalPdfList(pdf);
      notifyListeners();
    }
    debugPrint("_selectedFiles ${_selectedFiles.length}");
  }

  void clearSelectedFiles() {
    _selectedFiles.clear();
    setMultiSelect(false);
    notifyListeners();
  }

  Future<void> toggleFavorite(PdfModel pdf) async {
    try {
      await HiveHelper.toggleFavorite(pdf);

      _totalPdfList[pdf.id] = pdf.copyWith(isFav: !pdf.isFav);

      if (_totalPdfList[pdf.id]!.isFav) {
        _favoritesList[pdf.id] = _totalPdfList[pdf.id]!;
      } else {
        _favoritesList.removeWhere(
          (key, value) {
            return key == pdf.id;
          },
        );
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error while toggling favorite: $e");
    }
  }

  Future<void> addToTotalPdfList(PdfModel pdf) async {
    log("i'm here in the add pdf ");
    try {
      if (!_totalPdfList.containsKey(pdf.fileName)) {
        await HiveHelper.addOrUpdatePdf(pdf);
        _totalPdfList[pdf.id] = pdf;
        notifyListeners();
      } else {
        ToastUtils.showErrorToast("File already exists");
      }
    } catch (e) {
      debugPrint("adding file error $e");
      ToastUtils.showErrorToast("Error while adding file");
    }
  }

  Future<void> deletePdfFormLocalStorage(PdfModel pdf) async {
    try {
      final bool status = await mediaStorePlugin.deleteFile(
          fileName: pdf.fileName!,
          dirType: DirType.download,
          dirName: DirType.download.defaults);
      debugPrint("Delete Status: $status");

      if (status) {
        ToastUtils.showSuccessToast("File Deleted!");
      }
    } catch (e) {
      debugPrint("File deleted Error $e");
      ToastUtils.showErrorToast("Error while deleting file");
    }
  }

  Future<void> removeFromTotalPdfList(PdfModel pdf) async {
    setMoreBtnLoading(true);

    try {
      if (_totalPdfList.isNotEmpty) {
        await HiveHelper.removeFromCache(pdf.id);
        debugPrint("hive file deleted");
        _totalPdfList.removeWhere(
          (key, value) {
            return key == pdf.id;
          },
        );
        _favoritesList.removeWhere(
          (key, value) {
            return key == pdf.id;
          },
        );
        notifyListeners();
        if (pdf.networkUrl != null && !pdf.isSelected) {
          await deletePdfFormLocalStorage(pdf);
          debugPrint("downloads file deleted");
        }
      }
    } catch (e) {
      debugPrint("deleting file error $e");
      ToastUtils.showErrorToast("Error while deleting file");
    } finally {
      setMoreBtnLoading(false);
    }
  }

  setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setCurrentPDF(PdfModel pdf) {
    _currentPDF = pdf;
    notifyListeners();
  }

  Future<void> handleIntent() async {
    try {
      setLoading(true);

      _intentSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(
        (files) {
          _processSharedFiles(files);
        },
        onError: (err) {
          log("Error in media stream: $err");
          setLoading(false);
        },
      );

      final initialMedia =
          await ReceiveSharingIntent.instance.getInitialMedia();

      _processSharedFiles(initialMedia);

      setLoading(false);
    } catch (e) {
      log("Error handling intent: $e");
      setLoading(false);
    }
  }

  void _processSharedFiles(List<SharedMediaFile> files) async {
    if (files.isNotEmpty) {
      sharedFiles = files;
      final file = File(sharedFiles[0].path);
      final thumbnailBytes = await controlProvider.getPdfThumbNail(file.path);
      final pdf = PdfModel(
        id: getFileNameFromPath(file.path),
        filePath: file.path,
        fileSize: file.lengthSync().readableFileSize,
        fileName: getFileNameFromPath(file.path),
        pageNumber: 0,
        lastOpened: DateTime.now(),
        createdAt: DateTime.now(),
        thumbnail: thumbnailBytes,
      );

      addToTotalPdfList(pdf);
    }
  }

  void disposeIntentListener() {
    _intentSubscription.cancel();
  }

  String getFileNameFromPath(String url) {
    log("url $url");
    String fileName;
    if (url.contains("https") || url.contains("http")) {
      fileName = path.basename(Uri.parse(url).path);
    } else {
      fileName = url.split('/').last;
    }

    return fileName;
  }

  Future<void> pickFile() async {
    setLoading(true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final length = await file.length();
        debugPrint("length ${file.lengthSync()} $length");
        final thumbnailBytes = await controlProvider.getPdfThumbNail(file.path);

        final pdf = PdfModel(
            id: getFileNameFromPath(file.path),
            filePath: file.path,
            fileSize: file.lengthSync().readableFileSize,
            fileName: getFileNameFromPath(file.path),
            pageNumber: 0,
            downloadStatus: DownloadStatus.completed.name,
            lastOpened: DateTime.now(),
            createdAt: DateTime.now(),
            thumbnail: thumbnailBytes);
        addToTotalPdfList(pdf);

        setLoading(false);
      } else {
        ToastUtils.showErrorToast("No file selected");
        setLoading(false);
      }
    } catch (e) {
      ToastUtils.showErrorToast("Error while picking file");
      setLoading(false);
    }
  }
}
