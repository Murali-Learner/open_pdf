import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/download_progress.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_render/pdf_render.dart';

class DownloadProvider extends ChangeNotifier {
  DownloadProvider() {
    getPdfFromLocalStorage();
    _bindBackgroundIsolate();
    // _initializeTempFilePath();

    FlutterDownloader.registerCallback(downloadCallback);
  }

  final Dio dio = Dio();
  static final Map<String, PdfModel> _downloadedPdfMap = {};
  Map<String, PdfModel> get downloadedPdfMap => _downloadedPdfMap;
  final String _tempFilePath = Directory('/storage/emulated/0/Download/').path;
  Map<String, PdfModel> _selectedFiles = {};
  bool _isDownloadLoading = false;
  int _currentIndex = 0;
  bool _isMultiSelected = false;
  StreamSubscription<dynamic>? _portSubscription;
  final ReceivePort _port = ReceivePort();

  bool get isMultiSelected => _isMultiSelected;
  set isMultiSelected(bool value) {
    _isMultiSelected = value;
    notifyListeners();
  }

  bool get isDownloadLoading => _isDownloadLoading;
  set isDownloadLoading(bool value) {
    _isDownloadLoading = value;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
  void setTabIndex(int newIndex) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  Map<String, PdfModel> get selectedFiles => _selectedFiles;
  set selectedFiles(Map<String, PdfModel> list) {
    _selectedFiles = list;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelPortSubscription();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    } else {
      _listenFromPort();
    }
  }

  void _cancelPortSubscription() {
    _portSubscription?.cancel();
    _portSubscription = null;
  }

  void _listenFromPort() async {
    _cancelPortSubscription();
    _portSubscription = _port.listen(_handleDownloadProgress);
  }

  Future<void> _handleDownloadProgress(dynamic data) async {
    try {
      final progress = _parseDownloadProgress(data);
      debugPrint('Download Progress: ${progress.progress}');

      final model = await _findPdfModel(progress.taskId);
      PdfModel updatedModel = await _updatePdfModel(model, progress);
      updatedModel = updatedModel.copyWith(
          downloadProgress: (progress.progress).toDouble());
      await addToDownloadedMap(updatedModel);
      showToastAccordingToTheStatus(progress.status);
    } catch (e, stackTrace) {
      debugPrint('Error in download progress handler: $e');
      debugPrint('Stack trace: $stackTrace');
      ToastUtils.showErrorToast('Error updating download progress');
    }
  }

  DownloadProgress _parseDownloadProgress(dynamic data) {
    if (data is! List || data.length < 3) {
      throw const FormatException('Invalid download progress data format');
    }

    return DownloadProgress(
      taskId: data[0] as String,
      status: DownloadTaskStatus.fromInt(data[1] as int),
      progress: data[2] as int,
    );
  }

  Future<PdfModel> _findPdfModel(String taskId) async {
    try {
      return _downloadedPdfMap.values.firstWhere(
        (element) => element.taskId == taskId,
        orElse: () => throw StateError('No PDF found with taskId: $taskId'),
      );
    } catch (e) {
      debugPrint('Error finding PDF model: $e');
      rethrow;
    }
  }

  Future<PdfModel> _updatePdfModel(
    PdfModel model,
    DownloadProgress progress,
  ) async {
    Uint8List? thumbnailBytes;

    if (progress.progress == 100) {
      try {
        final filePath = '$_tempFilePath${model.fileName}';
        thumbnailBytes = await getPdfThumbNail(filePath);
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
        // Continue without thumbnail if generation fails
      }
    }

    return model.copyWith(
      taskId: progress.taskId,
      downloadProgress: progress.progress.toDouble(),
      thumbnail: thumbnailBytes,
      downloadStatus: progress.progress == 100
          ? DownloadTaskStatus.complete.name
          : progress.status.name,
      filePath: '$_tempFilePath${model.fileName}',
    );
  }

  void showToastAccordingToTheStatus(DownloadTaskStatus status) {
    switch (status) {
      case DownloadTaskStatus.complete:
        ToastUtils.showSuccessToast("Download Completed");
        break;
      case DownloadTaskStatus.canceled:
        ToastUtils.showErrorToast("Download Cancelled");
        break;
      case DownloadTaskStatus.failed:
        ToastUtils.showSuccessToast("Download Failed");
        break;
      case DownloadTaskStatus.paused:
        ToastUtils.showSuccessToast("Download Paused");
        break;
      case DownloadTaskStatus.running:
        ToastUtils.showSuccessToast("Download Running");
        break;
      default:
    }
  }

  void _unbindBackgroundIsolate() {
    _cancelPortSubscription();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
    String id,
    int status,
    int progress,
  ) {
    debugPrint(
      'Callback on background isolate: '
      'task ($id) is in status ($status) and process ($progress)',
    );

    final SendPort? sendPort =
        IsolateNameServer.lookupPortByName('downloader_send_port');

    sendPort?.send([id, status, progress]);
  }

  Future<void> getPdfFromLocalStorage() async {
    HiveHelper.getHivePdfList().forEach(
      (key, value) {
        if (value.networkUrl != null && value.networkUrl!.isNotEmpty) {
          _downloadedPdfMap[key] = value;
        }
      },
    );
    notifyListeners();
  }

  List<PdfModel> getFilteredListByStatus(List<DownloadTaskStatus> statuses) {
    List<String> statusNames = statuses.map((status) => status.name).toList();
    List<PdfModel> pdfList = _downloadedPdfMap.values
        .where((pdf) =>
            pdf.networkUrl != null &&
            pdf.networkUrl!.isNotEmpty &&
            pdf.lastOpened != null)
        .where((element) => statusNames.contains(element.downloadStatus))
        .toList();

    pdfList.sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));

    return pdfList;
  }

  Map<String, PdfModel> getSpecificStatusDownloads(DownloadTaskStatus status) {
    final pdfMap = Map<String, PdfModel>.fromEntries(
        _downloadedPdfMap.entries.where((element) {
      return element.value.downloadStatus == status.name;
    }));
    return pdfMap;
  }

  Future<void> updateLastOpenedValue(PdfModel pdf) async {
    try {
      final updatedPdf = pdf.copyWith(lastOpened: DateTime.now());
      HiveHelper.addOrUpdatePdf(updatedPdf).whenComplete(
        () {
          _downloadedPdfMap[pdf.id] = updatedPdf;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addToDownloadedMap(PdfModel pdf) async {
    try {
      await HiveHelper.addOrUpdatePdf(pdf);
      _downloadedPdfMap[pdf.id] = pdf;
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to add the file to completed list.");
    }
  }

  Future<void> clearFavorites() async {
    _downloadedPdfMap.forEach((key, pdf) {
      pdf.isFav = false;
    });
    notifyListeners();
  }

  Future<void> toggleFavoritePdf(PdfModel pdf) async {
    try {
      pdf = pdf.copyWith(isFav: !pdf.isFav);

      addToDownloadedMap(pdf);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to add the file to completed list.");
    }
  }

  Future<void> deleteSelectedFiles() async {
    // log("selectedFiles ${selectedFiles.length}");
    try {
      for (var entry in selectedFiles.entries) {
        final pdf = entry.value;
        debugPrint("selected file delete ${pdf.networkUrl}");

        await removeTaskFormDownloader(pdf.taskId!).whenComplete(
          () async {
            await deletePdfFormLocalStorage(pdf).whenComplete(
              () async {
                await removeFromDownloadedMap(pdf);
              },
            );
          },
        );
        debugPrint("selected file delete complete");
      }
      notifyListeners();
    } catch (e) {
      debugPrint("error while deleting selected files $e");
      ToastUtils.showErrorToast("Failed to delete selected files.");
    }
  }

  Future<void> removeFromDownloadedMap(PdfModel pdf) async {
    try {
      await HiveHelper.removeFromCache(pdf.id);
      _downloadedPdfMap.remove(pdf.id);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to remove the file from list.");
    }
  }

  Future<void> removeTaskFormDownloader(String taskId) async {
    await FlutterDownloader.remove(taskId: taskId);
  }

  Future<void> deleteCompletely(PdfModel pdf) async {
    await deletePdfFormLocalStorage(pdf);
    await removeFromDownloadedMap(pdf);
  }

  Future<void> deletePdfFormLocalStorage(PdfModel pdf) async {
    try {
      final file = File("${pdf.filePath}");

      if (await file.exists()) {
        await file.delete();
        ToastUtils.showSuccessToast("File Deleted!");
        debugPrint('File deleted successfully.');
      } else {
        debugPrint('File not found.');
      }
    } catch (e) {
      debugPrint("File deleted Error $e");
      ToastUtils.showErrorToast("Error while deleting file");
    }
  }

  bool checkIfFileExists(String fileName) {
    final exists = _downloadedPdfMap.values.any((element) {
      return element.fileName == fileName;
    });

    debugPrint("exists $exists $fileName");
    return exists;
  }

  Future<bool> checkIfFileExistsInDownloads(String filePath) async {
    try {
      File file = File(filePath);
      return await file.exists();
    } catch (e) {
      ToastUtils.showErrorToast("Error while checking file in downloads");
    }
    return false;
  }

  Future<void> clearData() async {
    await HiveHelper.clearAllData();
    _downloadedPdfMap.clear();

    notifyListeners();
    debugPrint("_downloadedPdfMap ${_downloadedPdfMap.length}");
  }

  Future<bool> validateUrl(String url) async {
    try {
      final response = await dio.head(url);
      debugPrint("url valid response $response");
      if (response.statusCode == 200 &&
          response.headers.value("content-type") == "application/pdf") {
        return true;
      }
    } catch (e) {
      debugPrint("Error while checking URL $e");
    }
    return false;
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

  Future<PdfModel> setupOngoingDownload(String url, String fileName) async {
    PdfModel downloadPdf = PdfModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: '',
      fileName: fileName,
      pageNumber: 0,
      lastOpened: DateTime.now(),
      createdAt: DateTime.now(),
      downloadProgress: 0.0,
      networkUrl: url,
      downloadStatus: DownloadTaskStatus.running.name,
      fileSize: "",
      taskId: '',
    );

    await addToDownloadedMap(downloadPdf);

    return downloadPdf;
  }

  Future<String> downloadPdfFile(String url, String fileName) async {
    isDownloadLoading = true;
    notifyListeners();
    final downloadedTaskId = await networkDownload(
      url: url,
      fileName: fileName,
    );
    isDownloadLoading = false;
    notifyListeners();
    if (downloadedTaskId != null && downloadedTaskId.isNotEmpty) {
      return downloadedTaskId;
    } else {
      throw Exception("Failed to download the file");
    }
  }

  Future<void> toggleFavorite(PdfModel pdf) async {
    try {
      _downloadedPdfMap[pdf.id] = pdf.copyWith(isFav: !pdf.isFav);

      notifyListeners();
    } catch (e) {
      debugPrint("Error while toggling favorite: $e");
    }
  }

  Future<void> downloadAndSavePdf(String url) async {
    bool validUrl = await validateUrl(url);
    if (!validUrl) {
      ToastUtils.showErrorToast("Enter a valid URL");
      return;
    }
    log("valid url $validUrl $url");
    String fileNameFromUrl = getFileNameFromPath(url);

    final bool localExists =
        await checkIfFileExistsInDownloads("$_tempFilePath/$fileNameFromUrl");
    final bool mapExists = checkIfFileExists(fileNameFromUrl);

    if (mapExists) {
      ToastUtils.showErrorToast("File Already Exists");
      return;
    }

    if (localExists) {
      ToastUtils.showErrorToast("File Already Exists In Downloads");
      return;
    }

    try {
      await downloadPdfFile(url, fileNameFromUrl).then(
        (downloadTaskId) async {
          PdfModel downloadPdf =
              await setupOngoingDownload(url, fileNameFromUrl);

          log("download first task id $downloadTaskId");
          downloadPdf = downloadPdf.copyWith(taskId: downloadTaskId);
          await addToDownloadedMap(downloadPdf);
          log("download task ID $downloadTaskId");
        },
      );
    } catch (e) {
      debugPrint("File Download Error $e");
      ToastUtils.showErrorToast("Error while downloading file");
    }
  }

  Future<void> toggleSelectedFiles(PdfModel pdf) async {
    _downloadedPdfMap[pdf.id] = pdf.copyWith(isSelected: !pdf.isSelected);

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
      _downloadedPdfMap[key] = pdf.copyWith(isSelected: false);
    });
    _selectedFiles.clear();
    notifyListeners();
  }

  Future<Uint8List> getPdfThumbNail(String path) async {
    PdfDocument doc = await PdfDocument.openFile(path);

    PdfPage page = await doc.getPage(1);
    final pageImage = await page.render();
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);

    return pngData!.buffer.asUint8List();
  }

  Future<String?> networkDownload({
    required String url,
    required String fileName,
  }) async {
    try {
      String? taskId = await FlutterDownloader.enqueue(
        url: url,
        // "https://upload.wikimedia.org/wikipedia/commons/b/b2/Sand_Dunes_in_Death_Valley_National_Park.jpg",
        savedDir: _tempFilePath,
        saveInPublicStorage: true,
        fileName: fileName,
        showNotification: true,
      );

      log('task Id $taskId');
      return taskId;

// http://www.pdf995.com/samples/pdf.pdf
    } catch (e) {
      log(e.toString());
      // if (e is DioException )
      throw Exception(e);
    }
  }

  Future<void> restartDownload(PdfModel pdfModel) async {
    if (pdfModel.downloadStatus == DownloadTaskStatus.canceled.name ||
        pdfModel.downloadStatus == DownloadTaskStatus.failed.name) {
      debugPrint("Restarting download for: ${pdfModel.downloadStatus}");
      final String? newTaskId =
          await FlutterDownloader.retry(taskId: pdfModel.taskId!);

      pdfModel = pdfModel.copyWith(
        taskId: newTaskId ?? pdfModel.taskId,
        downloadStatus: DownloadTaskStatus.running.name,
      );
      await addToDownloadedMap(pdfModel);
    } else {
      ToastUtils.showErrorToast("Cannot restart this download.");
    }
  }

  Future<void> cancelDownload(PdfModel pdfModel) async {
    try {
      debugPrint("Canceling download... ${pdfModel.toJson()}");
      await FlutterDownloader.cancel(taskId: pdfModel.taskId!);

      pdfModel = pdfModel.copyWith(
        downloadStatus: DownloadTaskStatus.canceled.name,
        downloadProgress: 0.0,
      );
      await addToDownloadedMap(pdfModel);

      notifyListeners();
      ToastUtils.showSuccessToast("File download canceled");
    } catch (e) {
      debugPrint("Error while canceling the download: $e");
      ToastUtils.showErrorToast("Error canceling the download");
    }
  }

  Future<void> pauseDownload(PdfModel pdfModel) async {
    try {
      debugPrint("Paused download... ${pdfModel.toJson()}");
      await FlutterDownloader.pause(taskId: pdfModel.taskId!);

      pdfModel = pdfModel.copyWith(
        downloadStatus: DownloadTaskStatus.paused.name,
      );
      await addToDownloadedMap(pdfModel);

      notifyListeners();
      ToastUtils.showSuccessToast("File download paused");
    } catch (e) {
      debugPrint("Error while pausing the download: $e");
      ToastUtils.showErrorToast("Error while pausing the download");
    }
  }

  Future<void> resumeDownload(PdfModel pdfModel) async {
    try {
      log("resume download... ${pdfModel.toJson()}");
      final downloadedTaskId =
          await FlutterDownloader.resume(taskId: pdfModel.taskId!);

      pdfModel = pdfModel.copyWith(
        downloadStatus: DownloadTaskStatus.running.name,
        downloadProgress: 0.0,
        taskId: downloadedTaskId ?? pdfModel.taskId,
      );
      await addToDownloadedMap(pdfModel);

      notifyListeners();
      ToastUtils.showSuccessToast("File download resumed");
    } catch (e) {
      debugPrint("Error while resuming the download: $e");
      ToastUtils.showErrorToast("Error resuming the download");
    }
  }
}
