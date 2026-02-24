import 'task_model.dart';
import 'package:hive/hive.dart';

part 'note_model.g.dart';

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
  dynamic rawChecklist;

  List<TaskModel>? get checklist {
    if (rawChecklist == null) return null;
    if (rawChecklist is List) {
      return rawChecklist!.map<TaskModel>((item) {
        if (item is TaskModel) return item;
        if (item is Map) {
          final title = (item['title'] ?? '').toString();
          final isDone = item['isDone'] == true || item['done'] == true;
          return TaskModel(title: title, isDone: isDone);
        }
        return TaskModel(title: item.toString(), isDone: false);
      }).toList();
    }
    return null;
  }

  set checklist(List<TaskModel>? value) {
    rawChecklist = value;
  }

  NoteModel({
    required this.title,
    this.text,
    this.imagePaths,
    this.audioPath,
    required this.createdAt,
    required this.color,
    this.audioDurationMs,
    List<TaskModel>? checklist,
  }) : rawChecklist = checklist;

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
    List<TaskModel>? checklist,
  }) {
    return NoteModel(
      title: title ?? this.title,
      text: text ?? this.text,
      imagePaths: imagePath != null ? [imagePath] : this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      checklist: checklist ?? this.checklist,
    );
  }
}
