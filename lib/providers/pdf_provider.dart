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
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/file_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

final mediaStorePlugin = MediaStore();

class PdfProvider with ChangeNotifier {
  PdfProvider() {
    loadPdfListFromHive();
  }

  PdfModel? _currentPDF = PdfModel(
    id: "1",
    filePath: "assets/dart_flutter.pdf",
    fileName: "dart_flutter.pdf",
    pageNumber: 1,
    fileSize: 5.0,
    lastOpened: DateTime.now(),
    createdAt: DateTime.now(),
  );
  bool _isLoading = false;
  bool _downloadBtnLoading = false;
  bool _moreBtnLoading = false;
  bool _isInternetConnected = false;
  PDFViewController? _pdfController;
  List<SharedMediaFile> sharedFiles = [];
  Map<String, PdfModel> _totalPdfList = {};
  Map<String, PdfModel> _downloadPdfList = {};
  Map<String, PdfModel> _favoritesList = {};
  late StreamSubscription _intentSubscription;
  late StreamSubscription _internetSubscription;
  ViewMode _viewMode = ViewMode.grid;
  int _pdfCurrentPage = 0;
  int _totalPages = 0;
  String _errorMessage = '';
  final double _currentZoomLevel = 0;
  int _currentIndex = 0;
  double _downloadProgress = 0.0;
  String _uriPath = "";
  DownloadStatus? _downloadStatus = DownloadStatus.ongoing;

  PdfModel? get currentPDF => _currentPDF;
  bool get isLoading => _isLoading;
  DownloadStatus? get downloadStatus => _downloadStatus!;
  bool get downloadBtnLoading => _downloadBtnLoading;
  bool get moreBtnLoading => _moreBtnLoading;
  int get pdfCurrentPage => _pdfCurrentPage;
  int get totalPage => _totalPages;
  double get curentZoomLevel => _currentZoomLevel;
  String get errorMessage => _errorMessage;
  bool get isInternetConnected => _isInternetConnected;
  PDFViewController get pdfController => _pdfController!;
  Map<String, PdfModel> get totalPdfList => _totalPdfList;
  Map<String, PdfModel> get downloadPdfList => _downloadPdfList;
  Map<String, PdfModel> get favoritesList => _favoritesList;
  double get downloadProgress => _downloadProgress;
  ViewMode get selectedViewMode => _viewMode;
  int get currentIndex => _currentIndex;

  Dio dio = Dio();

  Future<void> loadPdfListFromHive() async {
    _totalPdfList = HiveHelper.getHivePdfList();
    _favoritesList = HiveHelper.getFavoritePdfList();
    debugPrint("_totalPdfList ${_totalPdfList.length}");
    notifyListeners();
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
      debugPrint("url headers ${response.headers}");
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
    // setDownloadStatus();

    bool validUrl = await isValidUrl(url);
    debugPrint("validUrl $validUrl");
    if (url.isEmpty || !validUrl) {
      ToastUtils.showErrorToast("Enter a valid URL");
      resetValues();
      setDownloadBtnLoading(false);

      return;
    }

    String fileName = getFileNameFromPath(url);

    final File filePath = await getPdfDownloadDirectory(fileName);

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
      fileSize: 0,
    );

    addToTotalPdfList(downloadPdf);

    bool fileExists = await checkIfFileExists(fileName);
    log("fileExists: $fileExists, fileName: $filePath fileName $fileName ");

    if (fileExists || _totalPdfList.containsKey(fileName)) {
      ToastUtils.showErrorToast("File already exists");
      resetValues();
      setDownloadBtnLoading(false);
      return;
    }

    try {
      final response = await dio.download(
        url,
        filePath.path,
        onReceiveProgress: (count, total) {
          setDownloadProgress(count / total);
        },
      );

      if (response.statusCode == 200) {
        final SaveInfo? saveInfo = await mediaStorePlugin.saveFile(
          tempFilePath: filePath.path,
          dirType: DirType.download,
          dirName: DirType.download.defaults,
        );

        if (saveInfo != null && saveInfo.isSuccessful) {
          debugPrint(
              "here in the save info not null ${saveInfo.uri} $downloadProgress");
          final completedPdf = downloadPdf.copyWith(
            id: fileName,
            fileSize: 0.0,
            filePath: _uriPath,
            fileName: saveInfo.name,
            networkUrl: url,
            pageNumber: 0,
            downloadStatus: DownloadStatus.completed.name,
            downloadProgress: downloadProgress,
            lastOpened: DateTime.now(),
            createdAt: DateTime.now(),
          );

          debugPrint("download pdf ${downloadPdf.toJson()}");
          removeFromTotalPdfList(downloadPdf);
          addToTotalPdfList(completedPdf);

          ToastUtils.showSuccessToast("File downloaded successfully");
          return;
        } else {
          removeFromTotalPdfList(downloadPdf);

          ToastUtils.showErrorToast("File downloading error");
        }
      } else {
        removeFromTotalPdfList(downloadPdf);

        ToastUtils.showErrorToast("Failed to download file");
      }
    } catch (e) {
      removeFromTotalPdfList(downloadPdf);

      log("file download error $e");
      ToastUtils.showErrorToast("Unexpected file error: $e");
      setDownloadBtnLoading(false);
    } finally {
      setDownloadBtnLoading(false);
      resetValues();
    }
  }

  void nextPage() {
    if (_pdfController != null && _pdfCurrentPage < _totalPages - 1) {
      _pdfCurrentPage++;
      notifyListeners();
      _pdfController!.setPage(_pdfCurrentPage);
    }
  }

  void gotoFirstPage() {
    if (_pdfController != null && _pdfCurrentPage > 0) {
      _pdfCurrentPage = 0;
      notifyListeners();
      _pdfController!.setPage(_pdfCurrentPage);
    }
  }

  void gotoLastPage() {
    if (_pdfController != null && _pdfCurrentPage < _totalPages - 1) {
      _pdfCurrentPage = _totalPages;
      notifyListeners();
      _pdfController!.setPage(_pdfCurrentPage);
    }
  }

  void zoomUp() async {
    if (_pdfController != null) {}
  }

  void zoomDown() {}

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

  void setDownloadBtnLoading(bool value) {
    _downloadBtnLoading = value;
    notifyListeners();
  }

  void setMoreBtnLoading(bool value) {
    _downloadBtnLoading = value;
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

  void addToTotalPdfList(PdfModel pdf) async {
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

  void addToDownloadPdfList(PdfModel pdf) {
    _downloadPdfList[pdf.id] = pdf;
    notifyListeners();
  }

  void removeFromDownloadPdfList(PdfModel pdf) {
    _downloadPdfList.removeWhere(
      (key, value) => key == pdf.id,
    );
    notifyListeners();
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
        if (pdf.networkUrl != null) {
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

  void setCurrentPage(int page) async {
    try {
      _pdfCurrentPage = page;
      if (_currentPDF != null) {
        _currentPDF = _currentPDF!.copyWith(pageNumber: page);
        await HiveHelper.addOrUpdatePdf(_currentPDF!);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("deleting file error $e");
      ToastUtils.showErrorToast("Error while setting page");
    }
  }

  Future<void> setTotalPages(int pages) async {
    await Future.delayed(Duration.zero).whenComplete(() {
      setLoading(true);
      _totalPages = pages;

      setLoading(false);
    });
  }

  void setPdfController(PDFViewController controller) {
    _pdfController = controller;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setZoomControl() {
    if (currentPDF != null) {
      log("message");
    }
  }

  void handlePDF() {}

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

  void _processSharedFiles(List<SharedMediaFile> files) {
    if (files.isNotEmpty) {
      sharedFiles = files;
      final file = File(sharedFiles[0].path);

      final pdf = PdfModel(
        id: getFileNameFromPath(file.path),
        filePath: file.path,
        fileSize: file.sizeInKb,
        fileName: getFileNameFromPath(file.path),
        pageNumber: 0,
        lastOpened: DateTime.now(),
        createdAt: DateTime.now(),
      );

      addToTotalPdfList(pdf);
      handlePDF();
    }
  }

  void disposeIntentListener() {
    _intentSubscription.cancel();
  }

  String getFileNameFromPath(String url) {
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
        debugPrint("length ${file.lengthSync()} ${length}");
        final pdf = PdfModel(
          id: getFileNameFromPath(file.path),
          filePath: file.path,
          fileSize: file.sizeInKb,
          fileName: getFileNameFromPath(file.path),
          pageNumber: 0,
          lastOpened: DateTime.now(),
          createdAt: DateTime.now(),
        );
        addToTotalPdfList(pdf);

        handlePDF();
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
