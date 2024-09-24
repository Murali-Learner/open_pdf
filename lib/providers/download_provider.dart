import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_pdf/helpers/hive_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/providers/pdf_provider.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/extensions/size_extension.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';

class DownloadProvider extends ChangeNotifier {
  // final NotificationHelper notificationHelper = NotificationHelper();
  final Dio dio = Dio();

  Map<String, PdfModel> _onGoingList = {};
  Map<String, PdfModel> _completedList = {};
  Map<String, PdfModel> _cancelledList = {};
  final Map<String, int> _notificationIdMap = {};
  int notificationId = 0;
  var random = Random();

  Map<String, PdfModel> get onGoingList => _onGoingList;
  Map<String, PdfModel> get completedList => _completedList;
  Map<String, PdfModel> get cancelledList => _cancelledList;

  PdfProvider _pdfProvider;

  DownloadProvider(this._pdfProvider) {
    getHivePdfList();
  }
  set pdfProvider(PdfProvider value) {
    _pdfProvider = value;
    notifyListeners();
  }

  Future<void> getHivePdfList() async {
    final pdfMap = _pdfProvider.totalPdfList.entries;
    _onGoingList = Map.fromEntries(
      pdfMap.where(
        (entry) =>
            entry.value.downloadStatus == DownloadStatus.ongoing.name &&
            (entry.value.networkUrl != null),
      ),
    );
    _completedList = Map.fromEntries(
      pdfMap.where((entry) =>
          entry.value.downloadStatus == DownloadStatus.completed.name &&
          (entry.value.networkUrl != null)),
    );
    _cancelledList = Map.fromEntries(
      pdfMap.where((entry) =>
          entry.value.downloadStatus == DownloadStatus.cancelled.name &&
          (entry.value.networkUrl != null)),
    );
    notifyListeners();
  }

  List<PdfModel> getFilteredListByStatus(DownloadStatus status) {
    List<PdfModel> pdfList = (status == DownloadStatus.ongoing
            ? _onGoingList
            : status == DownloadStatus.completed
                ? _completedList
                : _cancelledList)
        .values
        .where((pdf) =>
            pdf.networkUrl != null &&
            pdf.networkUrl!.isNotEmpty &&
            pdf.lastOpened != null)
        .toList();

    pdfList.sort((a, b) => b.lastOpened!.compareTo(a.lastOpened!));

    return pdfList;
  }

  Future<void> updateLastOpenedValue(PdfModel pdf) async {
    try {
      final updatedPdf = pdf.copyWith(lastOpened: DateTime.now());
      await HiveHelper.addOrUpdatePdf(updatedPdf);
      _completedList[pdf.id] = updatedPdf;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addToOngoingList(PdfModel pdf) async {
    await HiveHelper.addOrUpdatePdf(pdf);
    _onGoingList[pdf.id] = pdf;
    notifyListeners();
  }

  Future<void> addToCompletedList(PdfModel pdf) async {
    try {
      await HiveHelper.addOrUpdatePdf(pdf);
      _pdfProvider.addToTotalPdfList(pdf);
      _completedList[pdf.id] = pdf;
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to add the file to completed list.");
    }
  }

  Future<void> clearFavorites() async {
    _completedList.forEach((key, pdf) {
      pdf.isFav = false;
    });
    notifyListeners();
  }

  Future<void> toggleFavoritePdf(PdfModel pdf) async {
    try {
      pdf = pdf.copyWith(isFav: !pdf.isFav);

      addToCompletedList(pdf);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to add the file to completed list.");
    }
  }

  Future<void> addToCancelledList(PdfModel pdf) async {
    try {
      await HiveHelper.addOrUpdatePdf(pdf);
      _cancelledList[pdf.id] = pdf;
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast("Failed to add the file to cancelled list.");
    }
  }

  Future<void> removeFromOngoingList(PdfModel pdf) async {
    try {
      await HiveHelper.removeFromCache(pdf.id);
      _onGoingList.remove(pdf.id);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast(
          "Error while removing the file from ongoing list.");
    }
  }

  Future<void> deleteSelectedFiles(Map<String, PdfModel> selectedFiles) async {
    log("selectedFiles ${selectedFiles.length}");
    try {
      for (var entry in selectedFiles.entries) {
        final key = entry.key;
        final value = entry.value;

        await HiveHelper.removeFromCache(value.id);
        _completedList.remove(key);
      }
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast(
          "Failed to remove the file from completed list.");
    }
  }

  Future<void> removeFromCompletedList(PdfModel pdf) async {
    try {
      log("selectedFiles ${pdf.id}");
      await HiveHelper.removeFromCache(pdf.id);
      _completedList.remove(pdf.id);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast(
          "Failed to remove the file from completed list.");
    }
  }

  Future<void> deleteCompletely(PdfModel pdf) async {
    log("deleteCompletely ${pdf.id} ${pdf.fileName} ");
    await deletePdfFormLocalStorage(pdf);
    await removeFromCompletedList(pdf);
  }

  Future<void> removeFromCancelledList(PdfModel pdf) async {
    try {
      await HiveHelper.removeFromCache(pdf.id);
      _cancelledList.remove(pdf.id);
      notifyListeners();
    } catch (e) {
      ToastUtils.showErrorToast(
          "Failed to remove the file from cancelled list.");
    }
  }

  Future<void> deletePdfFormLocalStorage(PdfModel pdf) async {
    log(" pdf.fileName! ${pdf.fileName!}  ${DirType.download.defaults}");
    try {
      final bool status = await mediaStorePlugin.deleteFile(
        fileName: pdf.fileName!,
        dirType: DirType.download,
        dirName: DirType.download.defaults,
      );
      debugPrint("Delete Status: $status");

      if (status) {
        ToastUtils.showSuccessToast("File Deleted!");
      }
    } catch (e) {
      debugPrint("File deleted Error $e");
      ToastUtils.showErrorToast("Error while deleting file");
    }
  }

  File getDownloadedFilePath({
    String? relativePath,
    required String fileName,
    required DirType dirType,
    required DirName dirName,
  }) {
    return File(
        "${dirType.fullPath(relativePath: relativePath.orAppFolder, dirName: dirName)}/$fileName");
  }

  Future<bool> checkIfFileExists(String fileName) async {
    try {
      final Uri? uri = await mediaStorePlugin.getFileUri(
          fileName: fileName,
          dirType: DirType.download,
          dirName: DirType.download.defaults);
      return uri != null;
    } catch (e) {
      ToastUtils.showErrorToast("Error while checking file");
    }
    return false;
  }

  Future<void> clearData() async {
    await HiveHelper.clearAllData();
    _onGoingList.clear();
    _cancelledList.clear();
    _completedList.clear();
    notifyListeners();
    debugPrint(
        "_onGoingList ${_cancelledList.length}${_onGoingList.length}${_completedList.length}");
  }

  Future<bool> validateUrl(String url) async {
    try {
      final response = await dio.head(url);
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

  Future<String> getDownloadFileName(String url, String fileName) async {
    int randomNum = random.nextInt(100);
    final bool localFileExists = await checkIfFileExists(fileName);
    // log("localFileExists $localFileExists $fileName");
    if (localFileExists ||
        _completedList.containsKey(fileName) ||
        _onGoingList.containsKey(fileName) ||
        _cancelledList.containsKey(fileName)) {
      fileName = "${fileName.split(".").first}$randomNum.pdf";
    }
    return fileName;
  }

  Future<String> prepareDownloadFileName(String url) async {
    String fileNameFromUrl = getFileNameFromPath(url);
    String downloadFileName = await getDownloadFileName(url, fileNameFromUrl);
    return downloadFileName;
  }

  Future<PdfModel> setupOngoingDownload(String url, String fileName) async {
    // notificationId = notificationHelper.generateNotificationId();
    _notificationIdMap[url] = notificationId;
    final token = CancelToken();

    PdfModel downloadPdf = PdfModel(
      id: fileName,
      filePath: '',
      fileName: fileName,
      pageNumber: 0,
      lastOpened: DateTime.now(),
      createdAt: DateTime.now(),
      downloadProgress: 0.0,
      networkUrl: url,
      downloadStatus: DownloadStatus.ongoing.name,
      fileSize: "",
      cancelToken: token,
    );

    await addToOngoingList(downloadPdf);
    // await notificationHelper.showProgressNotification(
    //   notificationId: notificationId,
    //   title: "Downloading PDF",
    //   body: fileName,
    //   progress: 0,
    // );

    return downloadPdf;
  }

  Future<File> downloadPdfFile(
      String url, String fileName, PdfModel downloadPdf) async {
    final File tempFilePath = await getPdfDownloadDirectory(fileName);

    final downloadResponse = await networkDownload(
      downloadPdf: downloadPdf,
      url: url,
      tempFilePath: tempFilePath,
    );

    if (downloadResponse.statusCode == 200) {
      return tempFilePath;
    } else {
      throw Exception("Failed to download the file");
    }
  }

  Future<PdfModel> saveDownloadedFile(
      File tempFilePath, PdfModel downloadPdf) async {
    final SaveInfo? savedFileInfo = await saveFileInLocalStorage(tempFilePath);

    if (savedFileInfo != null &&
        (savedFileInfo.isSuccessful || savedFileInfo.isDuplicated)) {
      File downloadedFilePath = getDownloadedFilePath(
        fileName: savedFileInfo.name,
        dirType: DirType.download,
        dirName: DirType.download.defaults,
      );

      final thumbnailBytes = await getPdfThumbNail(downloadedFilePath.path);

      downloadPdf = downloadPdf.copyWith(
        id: savedFileInfo.name,
        fileSize: downloadedFilePath.lengthSync().readableFileSize,
        filePath: downloadedFilePath.path,
        fileName: savedFileInfo.name,
        downloadStatus: DownloadStatus.completed.name,
        downloadProgress: 1,
        lastOpened: DateTime.now(),
        createdAt: DateTime.now(),
        thumbnail: thumbnailBytes,
      );

      return downloadPdf;
    } else {
      throw Exception("Failed to save the file");
    }
  }

  Future<void> toggleFavorite(PdfModel pdf) async {
    try {
      _completedList[pdf.id] = pdf.copyWith(isFav: !pdf.isFav);

      notifyListeners();
    } catch (e) {
      debugPrint("Error while toggling favorite: $e");
    }
  }

  Future<void> updateDownloadCompletion(PdfModel downloadPdf) async {
    removeFromOngoingList(downloadPdf);
    addToCompletedList(downloadPdf);

    // await notificationHelper.cancelNotification(notificationId);
    // await notificationHelper.showDownloadCompleteNotification(
    //   notificationId: notificationId,
    //   title: "Download Complete",
    //   body: downloadPdf.fileName!,
    // );

    ToastUtils.showSuccessToast("File downloaded successfully");
  }

  Future<void> handleDownloadError(PdfModel downloadPdf, Object e) async {
    // downloadPdf =
    //     downloadPdf.copyWith(downloadStatus: DownloadStatus.cancelled.name);
    // addToCancelledList(downloadPdf);

    // await notificationHelper.cancelNotification(notificationId);
    debugPrint("Download Error $e");
    // ToastUtils.showErrorToast("Error while downloading file");
  }

  Future<void> downloadAndSavePdf(String url) async {
    bool validUrl = await validateUrl(url);
    if (validUrl == false) {
      ToastUtils.showErrorToast("Enter a valid URL");
      return;
    }
    log("validUrl $validUrl");

    log("fileNameFromUrl $url ");
    String fileNameFromUrl = getFileNameFromPath(url);

    String downloadFileName = await getDownloadFileName(url, fileNameFromUrl);

    await startDownload(url, downloadFileName);
  }

  Future<File> getPdfDownloadDirectory(String fileName) async {
    final directory = await getApplicationSupportDirectory();
    return File("${directory.path}/$fileName");
  }

  Future<Uint8List> getPdfThumbNail(String path) async {
    PdfDocument doc = await PdfDocument.openFile(path);

    PdfPage page = await doc.getPage(1);
    final pageImage = await page.render();
    final image = await pageImage.createImageDetached();
    final pngData = await image.toByteData(format: ImageByteFormat.png);

    return pngData!.buffer.asUint8List();
  }

  Future<SaveInfo?> saveFileInLocalStorage(tempFilePath) async {
    final SaveInfo? saveInfo = await mediaStorePlugin.saveFile(
      tempFilePath: tempFilePath.path,
      dirType: DirType.download,
      dirName: DirType.download.defaults,
    );
    return saveInfo;
  }

  Future<void> startDownload(String url, String fileName) async {
    if (!await validateUrl(url)) {
      ToastUtils.showErrorToast("Not a valid url");
      return;
    }

    try {
      String downloadFileName = await prepareDownloadFileName(url);
      PdfModel downloadPdf = await setupOngoingDownload(url, downloadFileName);
      log("downloadPdf $downloadPdf");
      File tempFilePath =
          await downloadPdfFile(url, downloadFileName, downloadPdf);

      downloadPdf = await saveDownloadedFile(tempFilePath, downloadPdf);
      await updateDownloadCompletion(downloadPdf);
    } catch (e) {
      await handleDownloadError(PdfModel(id: fileName), e);
    }
  }

  Future<Response> networkDownload({
    required PdfModel downloadPdf,
    required String url,
    required tempFilePath,
  }) async {
    try {
      return await dio.download(
        url,
        tempFilePath.path,
        cancelToken: downloadPdf.cancelToken,
        onReceiveProgress: (count, total) {
          if (downloadPdf.cancelToken!.isCancelled) {
            throw Exception("Download canceled");
          }
          double progress = count / total;
          downloadPdf = downloadPdf.copyWith(downloadProgress: progress);
          if (progress == 1) {
            _onGoingList.remove(downloadPdf.id);
          } else {
            _onGoingList[downloadPdf.id] = downloadPdf;
          }
          notifyListeners();
        },
      );
    } catch (e) {
      if (downloadPdf.cancelToken!.isCancelled) {
        log("Download was cancelled");
      }
      throw Exception(e);
    }
  }

  Future<void> restartDownload(PdfModel pdfModel) async {
    // Check if the download can be restarted
    if (pdfModel.downloadStatus == DownloadStatus.cancelled.name) {
      log("Restarting download for: ${pdfModel.networkUrl}");

      // Call startDownload with the same URL and file name
      await startDownload(pdfModel.networkUrl!, pdfModel.id);
    } else {
      ToastUtils.showErrorToast("Cannot restart this download.");
    }
  }

  Future<void> cancelDownload(PdfModel pdfModel) async {
    try {
      log("Canceling download... ${pdfModel.toJson()}");
      pdfModel.cancelToken!.cancel();

      await removeFromOngoingList(pdfModel);

      pdfModel = pdfModel.copyWith(
        downloadStatus: DownloadStatus.cancelled.name,
        downloadProgress: 0.0,
      );
      await addToCancelledList(pdfModel);

      notifyListeners(); // Ensure UI updates
      ToastUtils.showSuccessToast("File download cancelled");
    } catch (e) {
      debugPrint("Error while canceling the download: $e");
      ToastUtils.showErrorToast("Error canceling the download");
    }
  }

  // Future<void> cancelDownload(PdfModel pdfModel) async {
  //   try {
  //     log("Canceling download... ${pdfModel.toJson()}");
  //     _cancelToken.cancel();

  //     // int? previousNotificationId = _notificationIdMap[pdfModel.networkUrl];
  //     // if (previousNotificationId != null) {
  //     //   // await notificationHelper.cancelNotification(previousNotificationId);
  //     //   // _notificationIdMap.remove(pdfModel.networkUrl);
  //     // }

  //     // notificationId = notificationHelper.generateNotificationId();
  //     await removeFromOngoingList(pdfModel);

  //     pdfModel = pdfModel.copyWith(
  //       downloadStatus: DownloadStatus.cancelled.name,
  //       downloadProgress: 0.0,
  //     );
  //     await addToCancelledList(pdfModel);
  //     // await notificationHelper.showDownloadCancelNotification(
  //     //   // notificationId: notificationId,
  //     //   title: "Download cancelled",
  //     //   body: pdfModel.fileName!,
  //     // );

  //     ToastUtils.showSuccessToast("File download cancelled");
  //   } catch (e) {
  //     debugPrint("Error while canceling the download: $e");
  //     ToastUtils.showErrorToast("Error canceling the download");
  //   }
  // }
}
