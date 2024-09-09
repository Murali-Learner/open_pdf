import 'package:open_pdf/utils/enumerates.dart';

class PdfModel {
  final String id;
  final String filePath;
  final String fileName;
  final int pageNumber;
  final DateTime lastOpened;
  final DateTime createdAt;
  final String? networkUrl;
  final double fileSize;
  final double? downloadProgress;
  final bool isOpened;
  final bool isFav;
  final DownloadStatus? downloadStatus;

  PdfModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.pageNumber,
    required this.lastOpened,
    required this.createdAt,
    required this.fileSize,
    this.networkUrl,
    this.downloadProgress,
    this.isOpened = false,
    this.isFav = false,
    this.downloadStatus,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      id: json['id'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      fileSize: json['fileSize'] ?? 0.0,
      lastOpened: DateTime.parse(json['lastSeen']),
      createdAt: DateTime.parse(json['createdAt']),
      downloadProgress: json['downloadProgress'] ?? 0.0,
      networkUrl: json['networkUrl'] ?? '',
      isOpened: json['isOpened'] ?? false,
      isFav: json['isFav'] ?? false,
      downloadStatus: DownloadStatus.values[json['downloadStatus'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'pageNumber': pageNumber,
      'lastSeen': lastOpened.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'networkUrl': networkUrl,
      'fileSize': fileSize,
      'downloadProgress': downloadProgress,
      'isOpened': isOpened,
      'isFav': isFav,
      'downloadStatus': downloadStatus!.index,
    };
  }
}
