import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/presentation/common/audio/audio_player_widget.dart';


class AddNoteAudioPreview extends StatelessWidget {
  const AddNoteAudioPreview({
    super.key,
    required this.audioPath,
    required this.audioDurationMs,
    required this.selectedColor,
    required this.onRemoveAudio,
  });

  final String? audioPath;
  final int? audioDurationMs;
  final Color selectedColor;
  final VoidCallback onRemoveAudio;

  @override
  Widget build(BuildContext context) {
    final path = audioPath;
    if (path == null) return const SizedBox.shrink();

    final previewNote = NoteModel(
      title: 'Audio Preview',
      audioPath: path,
      audioDurationMs: audioDurationMs,
      createdAt: DateTime.now(),
      color: selectedColor.toARGB32(),
    );

    return Stack(
      children: [
        AudioPlayerWidget(note: previewNote),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onRemoveAudio,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddNoteAudioRecordButton extends StatelessWidget {
  const AddNoteAudioRecordButton({
    super.key,
    required this.hasAudio,
    required this.isRecording,
    required this.pulseController,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
  });

  final bool hasAudio;
  final bool isRecording;
  final AnimationController pulseController;
  final VoidCallback onTap;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  final GestureLongPressEndCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressEnd: onLongPressEnd,
      child: AnimatedScale(
        scale: isRecording ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: isRecording ? 0.6 : 0.5),
                    blurRadius:
                        isRecording ? 25 + (15 * pulseController.value) : 20,
                    offset: const Offset(0, 10),
                    spreadRadius:
                        isRecording ? 3 + (5 * pulseController.value) : 0,
                  ),
                ],
              ),
              child: Icon(
                hasAudio ? Icons.mic : Icons.mic_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }
}
