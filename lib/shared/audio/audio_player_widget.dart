import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({super.key, required this.note});
  final NoteModel note;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = _effectiveDuration;
    final remaining = totalDuration - _position;
    final safeRemaining = remaining.isNegative ? Duration.zero : remaining;
    final sliderMax =
        totalDuration.inSeconds == 0 ? 1.0 : totalDuration.inSeconds.toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurple],
                    ),
                    boxShadow:
                        isPlaying
                            ? [
                              BoxShadow(
                                color: Colors.purple.withValues(
                                  alpha: 0.5 * _pulseController.value,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.audiotrack_rounded,
                      size: 18,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(safeRemaining),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPlaying ? 'is playing' : 'is paused',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                Slider(
                  value: _position.inSeconds.toDouble().clamp(0.0, sliderMax),
                  max: sliderMax,
                  onChanged: (value) async {
                    await _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                  activeColor: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Duration get _effectiveDuration {
    if (_duration != Duration.zero) return _duration;

    final recordedMs = widget.note.audioDurationMs;
    if (recordedMs != null && recordedMs > 0) {
      return Duration(milliseconds: recordedMs);
    }

    return Duration.zero;
  }

  Future<void> _togglePlay() async {
    if (widget.note.audioPath == null) return;

    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(widget.note.audioPath!));
    }

    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
  }
}
