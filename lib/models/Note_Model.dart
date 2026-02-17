import 'task_model.dart';
import 'package:hive/hive.dart';

part  'Note_Model.g.dart';

enum NoteType { text, image, audio, checklist, mixed }

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

  @HiveField(6)
  int? audioDurationMs;

  @HiveField(7)
  List<TaskModel>? checklist;
  NoteModel({
    required this.title,
    this.text,
    this.imagePaths,
    this.audioPath,
    required this.createdAt,
    required this.color,
    this.audioDurationMs,
    this.checklist,
  });

  bool get hasAnyContent {
    return (text != null && text!.trim().isNotEmpty) ||
        (imagePaths != null && imagePaths!.isNotEmpty) ||
        audioPath != null ||
        (checklist != null && checklist!.isNotEmpty);
  }

  NoteType get type {
    final hasText = text != null && text!.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths!.isNotEmpty;
    final hasAudio = audioPath != null;
    final hasChecklist = checklist != null && checklist!.isNotEmpty;

    final count =
        [hasText, hasImage, hasAudio, hasChecklist].where((e) => e).length;

    if (count > 1) return NoteType.mixed;
    if (hasImage) return NoteType.image;
    if (hasAudio) return NoteType.audio;
    if (hasChecklist) return NoteType.checklist;
    return NoteType.text;
  }

  bool get isEmpty => !hasAnyContent;

  NoteModel copyWith({
    String? title,
    String? text,
    String? imagePath,
    String? audioPath,
    DateTime? createdAt,
    int? color,
    int? audioDurationMs,
    List<Map<String, dynamic>>? checklist,
  }) {
    return NoteModel(
      title: title ?? this.title,
      text: text ?? this.text,
      imagePaths: imagePath != null ? [imagePath] : this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,

      checklist:
          checklist != null
              ? checklist
                  .map((e) => TaskModel(title: e['title'], isDone: e['isDone']))
                  .toList()
              : this.checklist,
    );
  }
}
