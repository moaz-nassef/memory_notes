import 'package:flutter/material.dart';
import 'package:memory_notes/features/voice_analysis/views/voice_review_screen.dart';
import 'package:memory_notes/shared/audio/audio_player_widget.dart';

class VoiceReviewStandaloneBody extends StatelessWidget {
  const VoiceReviewStandaloneBody({
    super.key,
    required this.audioPaths,
    required this.audioDurationsMs,
    required this.color,
    required this.titleController,
    required this.textController,
    required this.taskControllers,
    required this.onAddTask,
    required this.onRemoveTask,
  });

  final List<String> audioPaths;
  final List<int> audioDurationsMs;
  final Color color;
  final TextEditingController titleController;
  final TextEditingController textController;
  final List<TextEditingController> taskControllers;
  final VoidCallback onAddTask;
  final ValueChanged<int> onRemoveTask;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              VoiceReviewInfoCard(color: color),
              const SizedBox(height: 20),
              for (var index = 0; index < audioPaths.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AudioPlayerWidget(
                    audioPath: audioPaths[index],
                    audioDurationMs:
                        index < audioDurationsMs.length
                            ? audioDurationsMs[index]
                            : null,
                  ),
                ),
              VoiceReviewTextField(
                key: const Key('voice_review_title'),
                controller: titleController,
                label: 'Title',
                hint: 'Give this note a title',
                minLines: 1,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              VoiceReviewTextField(
                key: const Key('voice_review_text'),
                controller: textController,
                label: 'Plan and explanation',
                hint: 'The organized explanation will appear here',
                minLines: 7,
                maxLines: null,
              ),
              const SizedBox(height: 20),
              VoiceReviewTasksSection(
                controllers: taskControllers,
                onAdd: onAddTask,
                onRemove: onRemoveTask,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
