import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/pages/pdfViewer/pdf_js_view.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/context_extension.dart';
import 'package:open_pdf/utils/extensions/size_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_render/pdf_render.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class PdfProvider with ChangeNotifier {
  PdfProvider() {
    loadPdfListFromHive();
  }

  PdfModel? _currentPDF;
  bool _isLoading = false;
  bool _isInternetConnected = false;
  List<SharedMediaFile> sharedFiles = [];
  Map<String, PdfModel> _localPdfList = {};
  Map<String, PdfModel> _selectedFiles = {};
  late StreamSubscription _intentSubscription;
  late StreamSubscription _internetSubscription;
  ViewMode _viewMode = ViewMode.grid;
  int _currentNavIndex = 0;
  bool _isMultiSelected = false;
  int _currentTabIndex = 1;
  CheckList _selectedCheckList = CheckList.all;
  CheckList get selectedCheckList => _selectedCheckList;

  void setSelectedCheckList(CheckList checkValue, {bool notify = true}) {
    _selectedCheckList = checkValue;
    notifyListeners();
  }

  PdfModel? get currentPDF => _currentPDF;
  set currentPDF(PdfModel? pdf) {
    _currentPDF = pdf;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool get isInternetConnected => _isInternetConnected;
  set isInternetConnected(bool value) {
    _isInternetConnected = value;
    notifyListeners();
  }

  Map<String, PdfModel> get localPdfList => _localPdfList;
  set localPdfList(Map<String, PdfModel> list) {
    _localPdfList = list;
    notifyListeners();
  }

  Map<String, PdfModel> get selectedFiles => _selectedFiles;
  set selectedFiles(Map<String, PdfModel> list) {
    _selectedFiles = list;
    notifyListeners();
  }

  ViewMode get viewMode => _viewMode;
  set viewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  bool get isMultiSelected => _isMultiSelected;
  set isMultiSelected(bool value) {
    _isMultiSelected = value;
    notifyListeners();
  }

  int get currentNavIndex => _currentNavIndex;

  void setCurrentNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  int get currentTabIndex => _currentTabIndex;

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  Future<void> clearData() async {
    _localPdfList.clear();

    notifyListeners();
    debugPrint("_total list ${_localPdfList.length}");
  }

  List<PdfModel> getFilteredAndSortedPdfList() {
    List<PdfModel> pdfList = _localPdfList.values
        .where(
          (pdf) =>
              pdf.downloadStatus == DownloadTaskStatus.complete.name &&
              pdf.lastOpened != null,
        )
        .toList();

    pdfList.sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));

    return pdfList;
  }

  Future<void> loadPdfListFromHive() async {
    HiveHelper.getHivePdfList().forEach(
      (key, value) {
        if (value.networkUrl == null) {
          _localPdfList[key] = value;
        }
      },
    );
    debugPrint("_totalPdfList ${_localPdfList.length}");
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

  Future<void> internetSubscription() async {
    final connectionChecker = InternetConnectionChecker();

    bool isConnectedNow = await connectionChecker.hasConnection;
    _isInternetConnected = isConnectedNow;
    notifyListeners();
    log("_isInternetConnected $_isInternetConnected");
    _internetSubscription = connectionChecker.onStatusChange.listen(
      //Todo: fix it
      (InternetConnectionStatus status) {
        if (status == InternetConnectionStatus.connected) {
          _isInternetConnected = true;
          notifyListeners();
        } else {
          _isInternetConnected = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> toggleSelectedFiles(PdfModel pdf) async {
    _localPdfList[pdf.id] = pdf.copyWith(isSelected: !pdf.isSelected);

    if (!pdf.isSelected) {
      isMultiSelected = true;

      _selectedFiles[pdf.id] = pdf;

      notifyListeners();
    } else {
      _selectedFiles.removeWhere((key, val) {
        return key == pdf.id;
      });
      isMultiSelected = true;

      if (_selectedFiles.isEmpty) {
        isMultiSelected = false;
      }
      notifyListeners();
    }

    debugPrint("_selectedFiles ${_selectedFiles.length}");
  }

  void clearSelectedFiles() {
    isMultiSelected = false;
    _selectedFiles.forEach((key, pdf) {
      _localPdfList[key] = pdf.copyWith(isSelected: false);
    });
    _selectedFiles.clear();
    notifyListeners();
  }

  void deleteSelectedFiles() {
    isMultiSelected = false;

    _selectedFiles.forEach((key, pdf) {
      removeFromTotalPdfList(pdf);
      _localPdfList.removeWhere((key, pdf) => key == pdf.id);
    });

    selectedFiles.clear();
    notifyListeners();
  }

  Future<void> toggleFavorite(PdfModel pdf) async {
    try {
      final updatedPdf = pdf.copyWith(isFav: !pdf.isFav);

      await addToTotalPdfList(updatedPdf);

      notifyListeners();
    } catch (e) {
      debugPrint("Error while toggling favorite: $e");
    }
  }

  Future<void> addToTotalPdfList(PdfModel pdf) async {
    log("i'm here in the add pdf  ${pdf.id}");
    final contain =
        _localPdfList.values.where((e) => e.fileName == pdf.fileName);
    if (contain.isEmpty) {
      await HiveHelper.addOrUpdatePdf(pdf);
      _localPdfList[pdf.id] = pdf;
      notifyListeners();
    } else {}
  }

  void deleteFormHistory(PdfModel pdf) {
    if (_localPdfList.isNotEmpty) {
      _localPdfList.remove(pdf.id);

      notifyListeners();
    }
  }

  Future<void> removeFromTotalPdfList(PdfModel pdf) async {
    await HiveHelper.removeFromCache(pdf.id);

    _localPdfList.removeWhere(
      (key, value) {
        return key == pdf.id;
      },
    );

    notifyListeners();
  }

  setViewMode(ViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setCurrentPDF(PdfModel? pdf) {
    _currentPDF = pdf;
    notifyListeners();
  }

  Future<PdfModel?> handleIntent(BuildContext context) async {
    try {
      isLoading = true;

      _intentSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(
        (files) {
          _processSharedFiles(files);
        },
        onError: (err) {
          log("Error in media stream: $err");
          isLoading = false;
        },
      );

      final initialMedia =
          await ReceiveSharingIntent.instance.getInitialMedia();

      final pdf = await _processSharedFiles(initialMedia);

      if (pdf != null) {
        final base64 = await convertBase64(pdf.filePath!);
        context.push(
          navigateTo: PdfJsView(base64: base64, pdfName: pdf.fileName!),
        );
      }
      isLoading = false;
      return pdf;
    } catch (e) {
      log("Error handling intent: $e");
      isLoading = false;
      return null;
    }
  }

  Future<Uint8List> getPdfThumbNail(String path) async {
    PdfDocument doc = await PdfDocument.openFile(path);

    PdfPage page = await doc.getPage(1);
    final pageImage = await page.render();
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);

    return pngData!.buffer.asUint8List();
  }

  Future<PdfModel?> _processSharedFiles(List<SharedMediaFile> files) async {
    if (files.isNotEmpty) {
      sharedFiles = files;
      final file = File(sharedFiles[0].path);
      final thumbnailBytes = await getPdfThumbNail(file.path);
      final pdf = PdfModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        filePath: file.path,
        fileSize: file.lengthSync().readableFileSize,
        fileName: getFileNameFromPath(file.path),
        pageNumber: 0,
        lastOpened: DateTime.now(),
        createdAt: DateTime.now(),
        thumbnail: thumbnailBytes,
        networkUrl: null,
      );
      await addToTotalPdfList(pdf);
      return pdf;
    } else {
      return null;
    }
  }

  void internetDispose() {
    _internetSubscription.cancel();
  }

  void disposeIntentListener() {
    _intentSubscription.cancel();
  }

  void updateLastOpenedValue(PdfModel pdf) {
    _localPdfList.remove(pdf.id);
    notifyListeners();
    final updatedPdf = pdf.copyWith(lastOpened: DateTime.now());
    debugPrint("updatedPdf ${updatedPdf.lastOpened}");
    _localPdfList[pdf.id] = updatedPdf;
    notifyListeners();
  }

  String getFileNameFromPath(String url) {
    // log("url $url");
    String fileName;
    if (url.contains("https") || url.contains("http")) {
      fileName = path.basename(Uri.parse(url).path);
    } else {
      fileName = url.split('/').last;
    }

    return fileName;
  }

  Future<String> convertBase64(String filePath) async {
    final File pdfFile = File(filePath);
    List<int> pdfBytes = await pdfFile.readAsBytes();
    String base64File = base64Encode(pdfBytes);
    return base64File;
  }

  Future<void> pickFile() async {
    setCurrentPDF(null);
    isLoading = true;
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
        final thumbnailBytes = await getPdfThumbNail(file.path);

        final pdf = PdfModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filePath: file.path,
            fileSize: file.lengthSync().readableFileSize,
            fileName: getFileNameFromPath(file.path),
            pageNumber: 0,
            downloadStatus: DownloadTaskStatus.complete.name,
            lastOpened: DateTime.now(),
            createdAt: DateTime.now(),
            thumbnail: thumbnailBytes);

        await addToTotalPdfList(pdf);
        setCurrentPDF(pdf);

        isLoading = false;
      } else {
        ToastUtils.showErrorToast("No file selected");
        isLoading = false;
      }
    } catch (e) {
      ToastUtils.showErrorToast("Error while picking file");
    } finally {
      isLoading = false;
    }
  }

  Future<void> printPdf(String filePath) async {
    File pdfFile = File(filePath);
    Uint8List pdfBytes = await pdfFile.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
    );
  }
}
