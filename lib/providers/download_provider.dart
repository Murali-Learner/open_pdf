import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_pdf/helpers/notication_helper.dart';
import 'package:open_pdf/models/pdf_model.dart';
import 'package:open_pdf/utils/enumerates.dart';
import 'package:open_pdf/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

final mediaStorePlugin = MediaStore();

class DownloadProvider with ChangeNotifier {
  final Dio dio = Dio();
  final NotificationHelper notificationHelper = NotificationHelper();

  double _downloadProgress = 0.0;
  bool _downloadBtnLoading = false;
  String _uriPath = "";

  final DownloadStatus? _downloadStatus = DownloadStatus.ongoing;

  double get downloadProgress => _downloadProgress;
  bool get downloadBtnLoading => _downloadBtnLoading;
  DownloadStatus? get downloadStatus => _downloadStatus;

  void setDownloadBtnLoading(bool value) {
    _downloadBtnLoading = value;
    notifyListeners();
  }

  void setDownloadProgress(double value) {
    _downloadProgress = value;
    notifyListeners();
  }

  Future<File> getPdfDownloadDirectory(String fileName) async {
    final directory = await getApplicationSupportDirectory();
    return File("${directory.path}/$fileName");
  }

  Future<bool> isValidUrl(String url) async {
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

  Future<bool> checkIfFileExists(String fileName) async {
    try {
      final Uri? uri = await mediaStorePlugin.getFileUri(
        fileName: fileName,
        dirType: DirType.download,
        dirName: DirType.download.defaults,
      );
      if (uri != null) {
        _uriPath = uri.path;
        return true;
      }
    } catch (e) {
      ToastUtils.showErrorToast("Something went wrong, please try again!");
    }
    return false;
  }

  Future<void> downloadAndSavePdf(
    String url,
    Function(PdfModel) addToTotalPdfList,
    PdfModel pdfModel,
  ) async {
    setDownloadBtnLoading(true);
    setDownloadProgress(0.0);

    bool validUrl = await isValidUrl(url);
    if (url.isEmpty || !validUrl) {
      ToastUtils.showErrorToast("Enter a valid URL");
      setDownloadBtnLoading(false);
      return;
    }

    String fileName = getFileNameFromPath(url);
    final File filePath = await getPdfDownloadDirectory(fileName);

    int notificationId = notificationHelper.generateNotificationId();
    PdfModel downloadPdf = pdfModel.copyWith(
      fileName: fileName,
      downloadProgress: 0.0,
      downloadStatus: DownloadStatus.ongoing.name,
    );

    addToTotalPdfList(downloadPdf);

    bool fileExists = await checkIfFileExists(fileName);
    if (fileExists) {
      ToastUtils.showErrorToast("File already exists");
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
        filePath.path,
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
          tempFilePath: filePath.path,
          dirType: DirType.download,
          dirName: DirType.download.defaults,
        );

        if (saveInfo != null && saveInfo.isSuccessful) {
          final completedPdf = downloadPdf.copyWith(
            id: fileName,
            filePath: saveInfo.uri.path,
            downloadProgress: 1.0,
            downloadStatus: DownloadStatus.completed.name,
          );

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
      await notificationHelper.cancelNotification(notificationId);
      ToastUtils.showErrorToast("Error: $e");
    } finally {
      setDownloadBtnLoading(false);
    }
  }

  String getFileNameFromPath(String url) {
    return url.contains("https") || url.contains("http")
        ? path.basename(Uri.parse(url).path)
        : url.split('/').last;
  }
}
