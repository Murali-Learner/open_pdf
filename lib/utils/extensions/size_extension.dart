extension SizeExtension on int {
  double get sizeInKb => this / 1024;

  double get sizeInMb => this / (1024 * 1024);

  String get readableFileSize {
    if (this >= 1024 * 1024) {
      return "${sizeInMb.toStringAsFixed(2)} MB";
    } else if (this >= 1024) {
      return "${sizeInKb.toStringAsFixed(2)} KB";
    } else {
      return "$this bytes";
    }
  }
}
