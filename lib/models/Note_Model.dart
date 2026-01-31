import 'package:flutter/material.dart';

enum NoteType { text, image, audio, mixed }

class NoteModel {
  final String id;
  final String? title;
  final String? text;
  final String? imagePath;
  final String? audioPath;
  final DateTime createdAt;
  final Color color;

  NoteModel({
    required this.id,
    this.title,
    this.text,
    this.imagePath,
    this.audioPath,
    required this.createdAt,
    this.color = const Color(0xFFFFE082),
  });

  // ✅ Helper: تحديد نوع الـ Note
  NoteType get type {
    final hasText = text != null && text!.isNotEmpty;
    final hasImage = imagePath != null;
    final hasAudio = audioPath != null;

    final count = [hasText, hasImage, hasAudio].where((e) => e).length;

    if (count > 1) return NoteType.mixed;
    if (hasImage) return NoteType.image;
    if (hasAudio) return NoteType.audio;
    return NoteType.text;
  }

  // ✅ Helper: هل الـ Note فاضية؟
  bool get isEmpty {
    return (text == null || text!.isEmpty) &&
        imagePath == null &&
        audioPath == null;
  }

  // ✅ Copy with for updates
  NoteModel copyWith({
    String? id,
    String? title,
    String? text,
    String? imagePath,
    String? audioPath,
    DateTime? createdAt,
    Color? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
