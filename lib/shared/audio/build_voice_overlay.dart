import 'dart:ui';

import 'package:flutter/material.dart';

class BuildVoiceOverlay extends StatelessWidget {
  const BuildVoiceOverlay({
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
    final isNearDelete = dragOffset.dx < -50;
    final isNearSend = dragOffset.dy < -50;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Stack(
        children: [
          Positioned(
            bottom: 40,
            right: 30,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                final scale = 1.0 + (pulseController.value * 0.15);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.6),
                      blurRadius: 25 + (15 * pulseController.value),
                      spreadRadius: 3 + (5 * pulseController.value),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 28),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.3),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(
                                      alpha: 0.6 * (1 - pulseController.value),
                                    ),
                                    blurRadius: 10 * pulseController.value,
                                    spreadRadius: 3 * pulseController.value,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _formatDuration(recordingDurationMs),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _RecordingWaveform(samples: waveSamples),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isNearDelete ? 210 : 180,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    isNearDelete
                        ? Colors.red.withValues(alpha: 0.9)
                        : Colors.red.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isNearDelete ? 16 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isNearDelete ? 1.0 : 0.9,
                        ),
                        shape: BoxShape.circle,
                        boxShadow:
                            isNearDelete
                                ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: isNearDelete ? 32 : 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (isNearDelete)
                      const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            right: 30,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: isNearSend ? 210 : 180,
              // child: ClipRRect(
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(50),
              //   bottomRight: Radius.circular(50),
              // ),
              // child: BackdropFilter(
              // filter: ImageFilter.blur(
              // sigmaX: isNearSend ? 20 : 15,

              // sigmaY: isNearSend ? 20 : 15,
              // ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
                      Colors.green.withValues(alpha: isNearSend ? 0.9 : 0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isNearSend ? 16 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isNearSend ? 1.0 : 0.9,
                        ),
                        shape: BoxShape.circle,
                        boxShadow:
                            isNearSend
                                ? [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.green,
                        size: isNearSend ? 32 : 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 36,
                    ),
                    if (isNearSend)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Send',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).floor();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _RecordingWaveform extends StatelessWidget {
  const _RecordingWaveform({required this.samples});

  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    final bars = samples.isEmpty ? List<double>.filled(18, 0) : samples;

    return SizedBox(
      height: 42,
      width: 130,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:
            bars.map((sample) {
              final clamped = sample.clamp(0.0, 1.0);
              final isSilent = clamped < 0.08;
              final barHeight = isSilent ? 4.0 : 8.0 + (clamped * 30);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.4),
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 90),
                    curve: Curves.easeOut,
                    width: 3,
                    height: barHeight * 2,

                    decoration: BoxDecoration(
                      color:
                          isSilent
                              ? Colors.purple.withValues(alpha: 0.55)
                              : Colors.deepPurple,
                      borderRadius: BorderRadius.circular(isSilent ? 8 : 2),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
