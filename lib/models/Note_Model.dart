import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'note_model.g.dart';

enum NoteType { text, image, audio, mixed }

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? text;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  String? audioPath;

  @HiveField(4)
  DateTime createdAt;

  // نخزن اللون كـ int
  @HiveField(5)
  int color;

  NoteModel({
    required this.title,
    this.text,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
    required this.color,
  });

  // هل في أي محتوى؟
  bool get hasAnyContent {
    return (text != null && text!.trim().isNotEmpty) ||
        imagePath != null ||
        audioPath != null;
  }

  // نوع النوت
  NoteType get type {
    final hasText = text != null && text!.trim().isNotEmpty;
    final hasImage = imagePath != null;
    final hasAudio = audioPath != null;

    final count = [hasText, hasImage, hasAudio].where((e) => e).length;

    if (count > 1) return NoteType.mixed;
    if (hasImage) return NoteType.image;
    if (hasAudio) return NoteType.audio;
    return NoteType.text;
  }

  // هل فاضية؟
  bool get isEmpty => !hasAnyContent;

  // copyWith (مصحح)
  NoteModel copyWith({
    String? title,
    String? text,
    String? imagePath,
    String? audioPath,
    DateTime? createdAt,
    int? color,
  }) {
    return NoteModel(
      title: title ?? this.title,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
