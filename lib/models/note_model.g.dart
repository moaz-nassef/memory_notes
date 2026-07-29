// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      title: fields[0] as String,
      text: fields[1] as String?,
      imagePaths: (fields[2] as List?)?.cast<String>(),
      audioPath: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      color: fields[5] as int,
      audioDurationMs: fields[6] as int?,
      audioPaths: (fields[8] as List?)?.cast<String>(),
      audioDurationsMs: (fields[9] as List?)?.cast<int>(),
    )..rawChecklist = fields[7] as dynamic;
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.imagePaths)
      ..writeByte(3)
      ..write(obj.audioPath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.audioDurationMs)
      ..writeByte(7)
      ..write(obj.rawChecklist)
      ..writeByte(8)
      ..write(obj.audioPaths)
      ..writeByte(9)
      ..write(obj.audioDurationsMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
