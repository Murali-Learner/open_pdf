import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadProgress {
  final String taskId;
  final DownloadTaskStatus status;
  final int progress;

  DownloadProgress({
    required this.taskId,
    required this.status,
    required this.progress,
  });

  @override
  String toString() =>
      'DownloadProgress(taskId: $taskId, status: $status, progress: $progress)';
}
