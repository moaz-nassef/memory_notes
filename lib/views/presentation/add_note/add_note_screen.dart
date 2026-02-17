import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_notes/manager/audio_recorder_controller.dart';
import 'package:memory_notes/manager/audio_recorder_file_helper.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/presentation/add_note/top_Bar_AddNote.dart';
import 'package:memory_notes/views/presentation/common/audio/Audio%20Player%20Widget.dart';
import 'package:memory_notes/views/presentation/common/audio/buildVoiceOverlay.dart';
import 'package:memory_notes/views/presentation/common/build_Floating_Button.dart';
import 'package:memory_notes/views/presentation/common/color/color_picker_sheet.dart';
import 'package:memory_notes/views/presentation/common/image/Image_Picker_Page.dart';
import 'package:memory_notes/views/presentation/common/image/note_image_preview.dart';
import 'package:memory_notes/views/presentation/common/text/note_text_field.dart';
import 'package:memory_notes/views/presentation/common/text/note_title_field.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key, this.initialNote});
  final NoteModel? initialNote;
  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  late final AudioRecorderController _audioRecorderController;
  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<int>? _durationSub;

  List<String> selectedImagePaths = [];
  bool hasAudio = false;
  String? recordedAudioPath;
  int? recordedAudioDurationMs;
  String? _previousAudioPathBeforeRecording;
  int? _previousAudioDurationBeforeRecording;

  Color selectedColor = const Color(0xFF667EEA);
  bool showColorPicker = false;

  bool isRecording = false;
  bool showVoiceOverlay = false;
  Offset dragOffset = Offset.zero;

  late AnimationController _pulseController;

  int recordingDurationMs = 0;
  List<double> waveSamples = List<double>.filled(18, 0);

  bool canSaveNote({
    required String title,
    String? text,
    List<String>? imagePaths,
    String? audioPath,
  }) {
    if (title.trim().isEmpty) return false;

    final hasText = text != null && text.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths.isNotEmpty;
    final hasAudio = audioPath != null;

    return hasText || hasImage || hasAudio;
  }

  final List<Map<String, dynamic>> noteColors = const [
    {'color': Color(0xFF667EEA), 'name': 'Purple'},
    {'color': Color(0xFFFF6B6B), 'name': 'Red'},
    {'color': Color(0xFF4ECDC4), 'name': 'Turquoise'},
    {'color': Color(0xFFFECA57), 'name': 'Yellow'},
    {'color': Color(0xFF95E1D3), 'name': 'Mint'},
    {'color': Color(0xFFEE5A6F), 'name': 'Pink'},
    {'color': Color(0xFF2ECC71), 'name': 'Green'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _audioRecorderController = AudioRecorderController(
      AudioRecorderFileHelper(),
    );
    // If we're editing an existing note, pre-fill the fields
    if (widget.initialNote != null) {
      final note = widget.initialNote!;
      _titleController.text = note.title;
      _textController.text = note.text ?? '';
      selectedImagePaths = List<String>.from(note.imagePaths ?? []);
      recordedAudioPath = note.audioPath;
      hasAudio = note.audioPath != null;
      selectedColor = Color(note.color);
    }
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _durationSub?.cancel();
    _audioRecorderController.dispose();
    _pulseController.dispose();
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceRecording() async {
    _previousAudioPathBeforeRecording = recordedAudioPath;
    _previousAudioDurationBeforeRecording = recordedAudioDurationMs;

    setState(() {
      isRecording = true;
      showVoiceOverlay = true;
      recordingDurationMs = 0;
      dragOffset = Offset.zero;
      waveSamples = List<double>.filled(18, 0);
    });

    try {
      await _audioRecorderController.startRecording();

      _amplitudeSub?.cancel();
      _durationSub?.cancel();

      _amplitudeSub = _audioRecorderController.amplitudeStream.listen((amp) {
        if (!mounted) return;
        final normalized = amp.clamp(0.0, 1.0);
        setState(() {
          waveSamples = [...waveSamples.skip(1), normalized];
        });
      });

      _durationSub = _audioRecorderController.durationMsStream.listen((ms) {
        if (!mounted) return;
        setState(() {
          recordingDurationMs = ms;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isRecording = false;
        showVoiceOverlay = false;
      });
      _showSnackBar('Failed to start recording: $e', Colors.red);
    }
  }

  Future<void> _endVoiceRecording() async {
    final isDelete = dragOffset.dx < -80;
    final isSend = dragOffset.dy < -80;

    try {
      if (isDelete) {
        await _audioRecorderController.cancelRecording();
        _showSnackBar('Current recording deleted', Colors.red);
      } else if (isSend) {
        final savedPath = await _audioRecorderController.stopRecording();
        if (savedPath != null) {
          setState(() {
            recordedAudioPath = savedPath;
            recordedAudioDurationMs = recordingDurationMs;
            hasAudio = true;
          });
          _showSnackBar('Recording saved', Colors.green);
        }
      } else {
        await _audioRecorderController.cancelRecording();
        _showSnackBar('Recording canceled', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Error while finishing recording: $e', Colors.red);
    } finally {
      await _amplitudeSub?.cancel();
      await _durationSub?.cancel();

      if (!isSend) {
        setState(() {
          recordedAudioPath = _previousAudioPathBeforeRecording;
          recordedAudioDurationMs = _previousAudioDurationBeforeRecording;
          hasAudio = recordedAudioPath != null;
        });
      }

      if (mounted) {
        setState(() {
          isRecording = false;
          showVoiceOverlay = false;
          dragOffset = Offset.zero;
        });
      }
    }
  }

  Future<void> _removeAudio() async {
    final path = recordedAudioPath;
    if (path != null) {
      try {
        await _audioRecorderController.delete(path);
      } catch (_) {
        // keep UX stable even if file was already removed
      }
    }

    if (!mounted) return;
    setState(() {
      recordedAudioPath = null;
      recordedAudioDurationMs = null;
      hasAudio = false;
    });
  }

  void _saveNote() {
    final isValid = canSaveNote(
      title: _titleController.text,
      text: _textController.text,
      imagePaths: selectedImagePaths.isEmpty ? null : selectedImagePaths,
      audioPath: recordedAudioPath,
    );

    if (!isValid) {
      _showSnackBar('Add a title and at least one content type', Colors.orange);
      return;
    }

    final note = NoteModel(
      title: _titleController.text.trim(),
      text:
          _textController.text.trim().isEmpty
              ? null
              : _textController.text.trim(),
      imagePaths:
          selectedImagePaths.isEmpty ? null : List.from(selectedImagePaths),
      audioPath: recordedAudioPath,
      audioDurationMs: recordedAudioDurationMs,
      createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
      color: selectedColor.toARGB32(),
    );

    Navigator.pop(context, note);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAudioPreviewCard() {
    final path = recordedAudioPath;
    if (path == null) return const SizedBox.shrink();

    final previewNote = NoteModel(
      title: 'Audio Preview',
      audioPath: path,
      audioDurationMs: recordedAudioDurationMs,
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
              onTap: _removeAudio,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  selectedColor.withOpacity(0.15),
                  const Color.fromARGB(255, 5, 5, 5),
                  selectedColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                TopBarAddnote(
                  saveNote: _saveNote,
                  selectedColor: selectedColor,
                  title: widget.initialNote == null ? 'New Note' : 'Edit Note',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        NoteTitleField(controller: _titleController),
                        const SizedBox(height: 16),
                        if (selectedImagePaths.isNotEmpty)
                          NoteImagesSlideshow(
                            images: selectedImagePaths,
                            shadowColor: selectedColor,
                            onRemove: (index) {
                              if (!mounted) return;
                              if (index >= 0 &&
                                  index < selectedImagePaths.length) {
                                setState(() {
                                  selectedImagePaths = List.from(
                                    selectedImagePaths,
                                  )..removeAt(index);
                                });
                              }
                            },
                          ),
                        NoteTextField(controller: _textController),
                        if (hasAudio) _buildAudioPreviewCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingButton(
                  icon: Icons.palette_rounded,
                  color: selectedColor,
                  onTap: () {
                    setState(() => showColorPicker = !showColorPicker);
                  },
                ),
                const SizedBox(height: 12),
                FloatingButton(
                  icon: Icons.image_rounded,
                  color: Colors.blue,
                  onTap: () async {
                    final images = await Navigator.push<List<File>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ImagePickerPage(),
                      ),
                    );
                    if (images != null && images.isNotEmpty) {
                      setState(() {
                        selectedImagePaths = images.map((f) => f.path).toList();
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    if (hasAudio) {
                      _removeAudio();
                    } else {
                      _showSnackBar(
                        'Long press to start recording',
                        Colors.purple,
                      );
                    }
                  },
                  onLongPressStart: (_) {
                    _startVoiceRecording();
                  },
                  onLongPressMoveUpdate: (details) {
                    setState(() {
                      dragOffset = details.offsetFromOrigin;
                    });
                  },
                  onLongPressEnd: (_) {
                    _endVoiceRecording();
                  },
                  child: AnimatedScale(
                    scale: isRecording ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedBuilder(
                      animation: _pulseController,
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
                                color: Colors.purple.withOpacity(
                                  isRecording ? 0.6 : 0.5,
                                ),
                                blurRadius:
                                    isRecording
                                        ? 25 + (15 * _pulseController.value)
                                        : 20,
                                offset: const Offset(0, 10),
                                spreadRadius:
                                    isRecording
                                        ? 3 + (5 * _pulseController.value)
                                        : 0,
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
                ),
              ],
            ),
          ),
          if (showColorPicker)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColorPickerSheet(
                noteColors: noteColors,
                selectedColor: selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                    showColorPicker = false;
                  });
                },
                onClose: () => setState(() => showColorPicker = false),
              ),
            ),
          if (showVoiceOverlay)
            Positioned.fill(
              child: BuildVoiceOverlay(
                dragOffset: dragOffset,
                pulseController: _pulseController,
                recordingDurationMs: recordingDurationMs,
                waveSamples: waveSamples,
              ),
            ),
        ],
      ),
    );
  }
}
