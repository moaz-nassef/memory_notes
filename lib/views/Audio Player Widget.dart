import 'package:flutter/material.dart';
import 'package:memory_notes/models/Note Model.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({Key? key, required this.note}) : super(key: key);
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlay,

            // TODO: Implement actual audio playback
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
                                color: Colors.purple.withOpacity(
                                  0.5 * _pulseController.value,
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

          // Audio Info
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
                      _formatDuration(_duration - _position),
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

                // const SizedBox(height: 5),
                Slider(
                  value: _position.inSeconds.toDouble(),
                  max:
                      _duration.inSeconds.toDouble() == 0
                          ? 1
                          : _duration.inSeconds.toDouble(),
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
