import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_render/pdf_render.dart';

class DownloadProvider extends ChangeNotifier {
  DownloadProvider() {
    getHivePdfList();
    _bindBackgroundIsolate();
    // _initializeTempFilePath();

    FlutterDownloader.registerCallback(downloadCallback);
  }

  final Dio dio = Dio();
  static Map<String, PdfModel> _downloadedPdfMap = {};
  Map<String, PdfModel> get downloadedPdfMap => _downloadedPdfMap;
  final String _tempFilePath = Directory('/storage/emulated/0/Download/').path;
  var random = Random();
  int _currentIndex = 0;
  final TextEditingController searchController = TextEditingController();

  StreamSubscription<dynamic>? _portSubscription;
  final ReceivePort _port = ReceivePort();

  int get currentIndex => _currentIndex;
  void setTabIndex(int newIndex) {
    _currentIndex = newIndex;
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

    _portSubscription = _port.listen((dynamic data) async {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = DownloadTaskStatus.fromInt(data[1] as int);
      final progress = data[2] as int;

      debugPrint(
        'Callback on UI isolate: '
        'task ($taskId) is in status ($status) and progress ($progress)',
      );
      PdfModel model = _downloadedPdfMap.values
          .where((element) => element.taskId == taskId)
          .first;
      // listedFormPort(model);
      debugPrint("model ${model.toJson()}");
      Uint8List? thumbnailBytes;
      if (progress == 100) {
        thumbnailBytes = await getPdfThumbNail(_tempFilePath + model.fileName!);
      }
      model = model.copyWith(
        taskId: taskId,
        downloadProgress: progress.toDouble(),
        thumbnail: thumbnailBytes,
        downloadStatus:
            progress == 100 ? DownloadTaskStatus.complete.name : status.name,
        filePath: _tempFilePath + model.fileName!,
      );
      await addToDownloadedMap(model);
      showToastAccordingToTheStatus(status);
    });
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

  Future<void> getHivePdfList() async {
    _downloadedPdfMap = HiveHelper.getHivePdfList();
    notifyListeners();
    _downloadedPdfMap.forEach((key, pdf) {
      debugPrint("download pdfs ${pdf.toJson()}");
    });
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
      await HiveHelper.addOrUpdatePdf(updatedPdf);
      _downloadedPdfMap[pdf.id] = updatedPdf;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addToDownloadedMap(PdfModel pdf) async {
    try {
      if (_downloadedPdfMap.containsKey(pdf.id)) {
        debugPrint("I'm here delete");
        removeFromDownloadedMap(pdf);
      }
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

  Future<void> deleteSelectedFiles(Map<String, PdfModel> selectedFiles) async {
    // log("selectedFiles ${selectedFiles.length}");
    try {
      for (var entry in selectedFiles.entries) {
        final key = entry.key;
        final pdf = entry.value;

        await removeTaskFormDownloader(pdf.taskId!);
        await deletePdfFormLocalStorage(pdf);
        await removeFromDownloadedMap(pdf);
      }
      notifyListeners();
    } catch (e) {
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

  // Future<void> _initializeTempFilePath() async {
  //   Directory directory = await getApplicationSupportDirectory();
  //   _tempFilePath = directory.absolute.path;
  // }

  Future<bool> validateUrl(String url) async {
    try {
      final response = await dio.head(url);

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
    // log("url $url");
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

  Future<String> downloadPdfFile(
      String url, String fileName, PdfModel downloadPdf) async {
    final downloadedTaskId = await networkDownload(
      url: url,
      fileName: fileName,
    );

    if (downloadedTaskId != null && downloadedTaskId.isNotEmpty) {
      downloadPdf = downloadPdf.copyWith(taskId: downloadedTaskId);
      addToDownloadedMap(downloadPdf);
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
    String fileNameFromUrl = getFileNameFromPath(url);
    final bool localExists =
        await checkIfFileExistsInDownloads("$_tempFilePath/$fileNameFromUrl");
    if (localExists) {
      ToastUtils.showErrorToast("File Already Exists In Downloads");
      return;
    }

    final bool mapExists = checkIfFileExists(fileNameFromUrl);
    if (mapExists) {
      ToastUtils.showErrorToast("File Already Exists");
      return;
    }

    try {
      PdfModel downloadPdf = await setupOngoingDownload(url, fileNameFromUrl);
      String downloadTaskId =
          await downloadPdfFile(url, fileNameFromUrl, downloadPdf);
      log("download task ID $downloadTaskId");
    } catch (e) {
      debugPrint("File Download Error $e");
      ToastUtils.showErrorToast("Error while downloading file");
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
