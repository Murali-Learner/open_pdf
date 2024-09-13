// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfModelAdapter extends TypeAdapter<PdfModel> {
  @override
  final int typeId = 0;

  @override
  PdfModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfModel(
      id: fields[0] as String,
      filePath: fields[1] as String?,
      fileName: fields[3] as String?,
      pageNumber: fields[4] as int?,
      lastOpened: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime?,
      fileSize: fields[8] as double?,
      networkUrl: fields[7] as String?,
      downloadProgress: fields[9] as double?,
      isOpened: fields[10] as bool,
      isFav: fields[11] as bool,
      downloadStatus: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PdfModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.pageNumber)
      ..writeByte(5)
      ..write(obj.lastOpened)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.networkUrl)
      ..writeByte(8)
      ..write(obj.fileSize)
      ..writeByte(9)
      ..write(obj.downloadProgress)
      ..writeByte(10)
      ..write(obj.isOpened)
      ..writeByte(11)
      ..write(obj.isFav)
      ..writeByte(12)
      ..write(obj.downloadStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
