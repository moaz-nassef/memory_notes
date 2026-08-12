class VoiceAnalysisTask {
  const VoiceAnalysisTask({required this.title, this.durationMinutes});

  final String title;
  final int? durationMinutes;

  factory VoiceAnalysisTask.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String? ?? '').trim();
    if (title.isEmpty) {
      throw const FormatException('A returned task has no title.');
    }
    final rawDuration = json['durationMinutes'];
    final durationMinutes =
        rawDuration is num && rawDuration > 0 ? rawDuration.toInt() : null;
    return VoiceAnalysisTask(title: title, durationMinutes: durationMinutes);
  }
}

class VoiceAnalysisResult {
  const VoiceAnalysisResult({
    required this.title,
    required this.text,
    required this.tasks,
  });

  final String title;
  final String text;
  final List<VoiceAnalysisTask> tasks;

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String? ?? '').trim();
    if (text.isEmpty) {
      throw const FormatException('The service returned an empty transcript.');
    }

    final rawTasks = json['tasks'];
    final tasks =
        rawTasks is List
            ? rawTasks
                .whereType<Map>()
                .map(
                  (task) => VoiceAnalysisTask.fromJson(
                    Map<String, dynamic>.from(task),
                  ),
                )
                .toList(growable: false)
            : const <VoiceAnalysisTask>[];

    final title = (json['title'] as String? ?? '').trim();
    return VoiceAnalysisResult(
      title: title.isEmpty ? 'Voice note' : title,
      text: text,
      tasks: tasks,
    );
  }
}
