import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';

part 'pdf_model.g.dart';

@HiveType(typeId: 0)
class PdfModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? taskId;
  @HiveField(2)
  final String? filePath;
  @HiveField(4)
  final String? fileName;
  @HiveField(5)
  final int? pageNumber;
  @HiveField(6)
  final DateTime? lastOpened;
  @HiveField(7)
  final DateTime? createdAt;
  @HiveField(8)
  final String? networkUrl;
  @HiveField(9)
  final String? fileSize;
  @HiveField(10)
  final double? downloadProgress;
  @HiveField(11)
  final bool isOpened;
  @HiveField(12)
  bool isFav;
  @HiveField(13)
  final String? downloadStatus;
  @HiveField(14)
  final Uint8List? thumbnail;
  @HiveField(15)
  final bool isSelected;

  final CancelToken? cancelToken;

  PdfModel({
    required this.id,
    this.taskId,
    this.filePath,
    this.fileName,
    this.pageNumber,
    this.lastOpened,
    this.createdAt,
    this.fileSize,
    this.networkUrl,
    this.downloadProgress = 0.0,
    this.isOpened = false,
    this.isFav = false,
    this.downloadStatus,
    this.thumbnail,
    this.isSelected = false,
    this.cancelToken,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      id: json['id'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      fileSize: json['fileSize'] ?? "",
      lastOpened: DateTime.parse(json['lastSeen']),
      createdAt: DateTime.parse(json['createdAt']),
      downloadProgress: json['downloadProgress'] ?? 0.0,
      networkUrl: json['networkUrl'] ?? '',
      isOpened: json['isOpened'] ?? false,
      isFav: json['isFav'] ?? false,
      downloadStatus:
          DownloadTaskStatus.values[json['downloadStatus'] ?? 0].name,
      thumbnail: json['thumbnail'],
      isSelected: json['isSelected'],
      cancelToken: json['cancelToken'],
      taskId: json['taskId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileName': fileName,
      'pageNumber': pageNumber,
      'lastSeen': lastOpened,
      'createdAt': createdAt,
      'networkUrl': networkUrl,
      'fileSize': fileSize,
      'downloadProgress': downloadProgress,
      'isOpened': isOpened,
      'isFav': isFav,
      'downloadStatus': downloadStatus,
      'taskId': taskId,
      // 'thumbnail': thumbnail,
      'isSelected': isSelected,
      'cancelToken': cancelToken,
    };
  }

  PdfModel copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? pageNumber,
    DateTime? lastOpened,
    DateTime? createdAt,
    String? networkUrl,
    String? fileSize,
    double? downloadProgress,
    bool? isOpened,
    bool? isFav,
    String? downloadStatus,
    String? taskId,
    Uint8List? thumbnail,
    bool? isSelected,
    CancelToken? cancelToken,
  }) {
    return PdfModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      pageNumber: pageNumber ?? this.pageNumber,
      lastOpened: lastOpened ?? this.lastOpened,
      createdAt: createdAt ?? this.createdAt,
      networkUrl: networkUrl ?? this.networkUrl,
      fileSize: fileSize ?? this.fileSize,
      taskId: taskId ?? this.taskId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isOpened: isOpened ?? this.isOpened,
      isFav: isFav ?? this.isFav,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      thumbnail: thumbnail ?? this.thumbnail,
      isSelected: isSelected ?? this.isSelected,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}
