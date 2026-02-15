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
  List<String>? imagePaths;

  @HiveField(3)
  String? audioPath;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  int color;

  NoteModel({
    required this.title,
    this.text,
    this.imagePaths,
    this.audioPath,
    required this.createdAt,
    required this.color,
  });

  bool get hasAnyContent {
    return (text != null && text!.trim().isNotEmpty) ||
        imagePaths != null && imagePaths!.isNotEmpty ||
        audioPath != null;
  }

  // نوع النوت
  NoteType get type {
    final hasText = text != null && text!.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths!.isNotEmpty;
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
      imagePaths: imagePath != null ? [imagePath] : this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
