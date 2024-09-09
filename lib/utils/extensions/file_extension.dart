import 'dart:io';

extension FileExtension on File {
  double get sizeInKb {
    int sizeInBytes = lengthSync();
    double sizeInKb = sizeInBytes / 1024;
    return sizeInKb;
  }

  double get sizeInMb {
    int sizeInBytes = lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    return sizeInMb;
  }
}
