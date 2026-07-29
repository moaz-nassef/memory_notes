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

  /// All voice recordings attached to this note.
  /// (Replaces the legacy single [audioPath] — old notes still work,
  /// see [allAudioPaths].)
  @HiveField(8)
  List<String>? audioPaths;

  /// Duration (ms) for each entry in [audioPaths], same order.
  @HiveField(9)
  List<int>? audioDurationsMs;

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
    this.audioPaths,
    this.audioDurationsMs,
    List<TaskModel>? checklist,
  }) : rawChecklist = checklist;

  /// Every recording on this note — new list first, falling back to
  /// the legacy single [audioPath] so notes saved by older app
  /// versions still show their audio.
  List<String> get allAudioPaths {
    final paths = audioPaths;
    if (paths != null && paths.isNotEmpty) return paths;
    final legacy = audioPath;
    return legacy == null ? const [] : [legacy];
  }

  /// Durations aligned with [allAudioPaths] (0 = unknown).
  List<int> get allAudioDurationsMs {
    final paths = allAudioPaths;
    final durations = audioDurationsMs;
    if (durations == null || durations.isEmpty) {
      // Legacy single-audio note.
      if (audioPath != null && paths.length == 1) {
        return [audioDurationMs ?? 0];
      }
      return List<int>.filled(paths.length, 0);
    }
    // Pad/truncate so indices always align with paths.
    return List<int>.generate(
      paths.length,
      (i) => i < durations.length ? durations[i] : 0,
    );
  }

  bool get hasAudio => allAudioPaths.isNotEmpty;

  bool get hasAnyContent {
    return (text != null && text!.trim().isNotEmpty) ||
        (imagePaths != null && imagePaths!.isNotEmpty) ||
        hasAudio ||
        (checklist != null && checklist!.isNotEmpty);
  }

  NoteType get type {
    final hasText = text != null && text!.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths!.isNotEmpty;
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
    List<String>? imagePaths,
    String? audioPath,
    DateTime? createdAt,
    int? color,
    int? audioDurationMs,
    List<String>? audioPaths,
    List<int>? audioDurationsMs,
    List<TaskModel>? checklist,
  }) {
    return NoteModel(
      title: title ?? this.title,
      text: text ?? this.text,
      imagePaths: imagePaths ?? this.imagePaths,
      audioPath: audioPath ?? this.audioPath,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      audioPaths: audioPaths ?? this.audioPaths,
      audioDurationsMs: audioDurationsMs ?? this.audioDurationsMs,
      checklist: checklist ?? this.checklist,
    );
  }
}
