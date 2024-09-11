import 'package:hive/hive.dart';
import 'package:open_pdf/utils/enumerates.dart';

part 'pdf_model.g.dart';

@HiveType(typeId: 0)
class PdfModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String filePath;
  @HiveField(3)
  final String fileName;
  @HiveField(4)
  final int pageNumber;
  @HiveField(5)
  final DateTime lastOpened;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final String? networkUrl;
  @HiveField(8)
  final double fileSize;
  @HiveField(9)
  final double? downloadProgress;
  @HiveField(10)
  final bool isOpened;
  @HiveField(11)
  final bool isFav;
  @HiveField(12)
  final String? downloadStatus;

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
      downloadStatus: DownloadStatus.values[json['downloadStatus'] ?? 0].name,
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
      'downloadStatus': downloadStatus,
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
    double? fileSize,
    double? downloadProgress,
    bool? isOpened,
    bool? isFav,
    String? downloadStatus,
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
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isOpened: isOpened ?? this.isOpened,
      isFav: isFav ?? this.isFav,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }
}
