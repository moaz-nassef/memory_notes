import 'package:flutter/material.dart';
import 'package:memory_notes/views/presentation/common/audio/build_voice_overlay.dart';

class AudioRecorderView extends StatelessWidget {
  const AudioRecorderView({
    super.key,
    required this.dragOffset,
    required this.pulseController,
    required this.recordingDurationMs,
    required this.waveSamples,
  });

  final Offset dragOffset;
  final AnimationController pulseController;
  final int recordingDurationMs;
  final List<double> waveSamples;

  @override
  Widget build(BuildContext context) {
    return BuildVoiceOverlay(
      dragOffset: dragOffset,
      pulseController: pulseController,
      recordingDurationMs: recordingDurationMs,
      waveSamples: waveSamples,
    );
  }
}
