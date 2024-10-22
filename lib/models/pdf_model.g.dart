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
      taskId: fields[1] as String?,
      filePath: fields[2] as String?,
      fileName: fields[4] as String?,
      pageNumber: fields[5] as int?,
      lastOpened: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime?,
      fileSize: fields[9] as String?,
      networkUrl: fields[8] as String?,
      downloadProgress: fields[10] as double?,
      isOpened: fields[11] as bool,
      isFav: fields[12] as bool,
      downloadStatus: fields[13] as String?,
      thumbnail: fields[14] as Uint8List?,
      isSelected: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PdfModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.fileName)
      ..writeByte(5)
      ..write(obj.pageNumber)
      ..writeByte(6)
      ..write(obj.lastOpened)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.networkUrl)
      ..writeByte(9)
      ..write(obj.fileSize)
      ..writeByte(10)
      ..write(obj.downloadProgress)
      ..writeByte(11)
      ..write(obj.isOpened)
      ..writeByte(12)
      ..write(obj.isFav)
      ..writeByte(13)
      ..write(obj.downloadStatus)
      ..writeByte(14)
      ..write(obj.thumbnail)
      ..writeByte(15)
      ..write(obj.isSelected);
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
