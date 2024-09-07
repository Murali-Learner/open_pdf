class PdfModel {
  final String id;
  final String filePath;
  final String fileName;
  final int pageNumber;
  final DateTime lastOpened;
  final DateTime createdAt;
  final String? networkUrl;
  final bool isOpened;
  final bool isFav;

  PdfModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.pageNumber,
    required this.lastOpened,
    required this.createdAt,
    this.networkUrl,
    this.isOpened = false,
    this.isFav = false,
  });
  factory PdfModel.fromJson(Map<String, dynamic> json) {
    return PdfModel(
      id: json['id'] ?? '',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      pageNumber: json['pageNumber'] ?? 0,
      lastOpened: DateTime.parse(json['lastSeen']),
      createdAt: DateTime.parse(json['createdAt']),
      networkUrl: json['networkUrl'] ?? '',
      isOpened: json['isOpened'] ?? false,
      isFav: json['isFav'] ?? false,
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
      'isOpened': isOpened,
      'isFav': isFav,
    };
  }

  @override
  String toString() {
    return 'PdfModel(id: $id, filePath: $filePath, pageNumber: $pageNumber, lastSeen: $lastOpened, createdAt: $createdAt, networkUrl: $networkUrl, isOpened: $isOpened fileName: $fileName )';
  }

  PdfModel copyWith({
    String? id,
    String? filePath,
    String? fileName,
    int? pageNumber,
    DateTime? lastOpened,
    DateTime? createdAt,
    String? networkUrl,
    bool? isOpened,
    bool? isFav,
  }) {
    return PdfModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: filePath ?? this.fileName,
      pageNumber: pageNumber ?? this.pageNumber,
      lastOpened: lastOpened ?? this.lastOpened,
      createdAt: createdAt ?? this.createdAt,
      networkUrl: networkUrl ?? this.networkUrl,
      isOpened: isOpened ?? this.isOpened,
      isFav: isFav ?? this.isFav,
    );
  }
}
