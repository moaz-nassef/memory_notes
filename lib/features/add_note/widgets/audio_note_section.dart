import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/shared/audio/audio_player_widget.dart';

/// Preview of one attached recording, with a remove button.
class AddNoteAudioPreview extends StatelessWidget {
  const AddNoteAudioPreview({
    super.key,
    required this.audioPath,
    required this.audioDurationMs,
    required this.index,
    required this.onRemoveAudio,
  });

  final String audioPath;
  final int? audioDurationMs;

  /// 1-based position shown as "Voice note 1", "Voice note 2", …
  final int index;
  final VoidCallback onRemoveAudio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Voice note $index',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        Stack(
          children: [
            AudioPlayerWidget(
              audioPath: audioPath,
              audioDurationMs: audioDurationMs,
            ),
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
                      color: AppColors.error.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                    color: Colors.purple.withValues(
                      alpha: isRecording ? 0.6 : 0.5,
                    ),
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
