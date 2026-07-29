import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/core/di_container.dart';
import 'package:memory_notes/core/services/audio_playback_coordinator.dart';
import 'package:audioplayers/audioplayers.dart';

/// Plays a single voice recording file.
///
/// Integrates with [AudioPlaybackCoordinator] so only one recording
/// plays at a time app-wide, and keeps its UI in sync by listening
/// to the player's real state stream (no more stuck "playing" UI).
class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.audioDurationMs,
  });

  final String audioPath;

  /// Fallback duration (ms) until the player reports the real one.
  final int? audioDurationMs;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _pulseController;

  final List<StreamSubscription<dynamic>> _subs = [];

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _subs.addAll([
      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted) setState(() => _duration = d);
      }),
      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      // Source of truth for play/pause UI — covers pause, stop,
      // and being interrupted by another player.
      _audioPlayer.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _playerState = s);
      }),
      _audioPlayer.onPlayerComplete.listen((_) {
        sl<AudioPlaybackCoordinator>().release(this);
        if (mounted) {
          setState(() {
            _playerState = PlayerState.stopped;
            _position = Duration.zero;
          });
        }
      }),
    ]);
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    sl<AudioPlaybackCoordinator>().release(this);
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Called by the coordinator when another player takes over.
  void _handleExternalStop() {
    _audioPlayer.pause();
    // State stream updates the UI; setState here is a safety net.
    if (mounted) setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    // Take over the single playback slot, then play/resume.
    sl<AudioPlaybackCoordinator>().acquire(this, _handleExternalStop);
    if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.audioPath));
    }
  }

  Duration get _effectiveDuration {
    if (_duration != Duration.zero) return _duration;
    final recordedMs = widget.audioDurationMs;
    if (recordedMs != null && recordedMs > 0) {
      return Duration(milliseconds: recordedMs);
    }
    return Duration.zero;
  }

  String get _statusText => switch (_playerState) {
    PlayerState.playing => 'Playing…',
    PlayerState.paused => 'Paused',
    _ => 'Ready to play',
  };

  @override
  Widget build(BuildContext context) {
    final totalDuration = _effectiveDuration;
    final remaining = totalDuration - _position;
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final sliderMax =
        totalDuration.inSeconds == 0 ? 1.0 : totalDuration.inSeconds.toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow:
                        _isPlaying
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.5 * _pulseController.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(safeRemaining),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _statusText,
                        key: ValueKey(_statusText),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 26,
                  child: Slider(
                    value: _position.inSeconds.toDouble().clamp(0.0, sliderMax),
                    max: sliderMax,
                    onChanged: (value) async {
                      await _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }
}
