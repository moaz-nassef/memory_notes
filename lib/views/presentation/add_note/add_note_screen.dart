import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_notes/manager/audio_recorder_controller.dart';
import 'package:memory_notes/manager/audio_recorder_file_helper.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';
import 'package:memory_notes/views/presentation/add_note/widgets/audio_note_section.dart';
import 'package:memory_notes/views/presentation/add_note/widgets/checklist_editor_section.dart';
import 'package:memory_notes/views/presentation/add_note/top_Bar_AddNote.dart';
import 'package:memory_notes/views/presentation/common/audio/buildVoiceOverlay.dart';
import 'package:memory_notes/views/presentation/common/build_Toolbar_Button.dart';
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
  final _taskController = TextEditingController();

  late final AudioRecorderController _audioRecorderController;
  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<int>? _durationSub;

  List<String> selectedImagePaths = [];
  List<TaskModel> checklistItems = [];
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
    List<TaskModel>? checklist,
  }) {
    final hasTitle = title.trim().isNotEmpty;
    final hasText = text != null && text.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths.isNotEmpty;
    final hasAudio = audioPath != null;
    final hasChecklist = checklist != null && checklist.isNotEmpty;

    return hasTitle || hasText || hasImage || hasAudio || hasChecklist;
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
      checklistItems = List<TaskModel>.from(note.checklist ?? []);
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
    _taskController.dispose();
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
      checklist: checklistItems.isEmpty ? null : checklistItems,
    );

    if (!isValid) {
      _showSnackBar(
        'Add a title and at least one content type',
        Colors.orange.withValues(alpha: 0.5),
      );
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
      checklist:
          checklistItems.isEmpty ? null : List<TaskModel>.from(checklistItems),
      createdAt: widget.initialNote?.createdAt ?? DateTime.now(),
      color: selectedColor.toARGB32(),
    );

    Navigator.pop(context, note);
  }

  void _addTask() {
    final taskTitle = _taskController.text.trim();
    if (taskTitle.isEmpty) return;

    setState(() {
      checklistItems = List<TaskModel>.from(checklistItems)
        ..add(TaskModel(title: taskTitle));
      _taskController.clear();
    });
  }

  void _toggleTask(int index, bool? value) {
    if (index < 0 || index >= checklistItems.length) return;
    setState(() {
      checklistItems = List<TaskModel>.from(checklistItems);
      checklistItems[index].isDone = value ?? false;
    });
  }

  void _removeTask(int index) {
    if (index < 0 || index >= checklistItems.length) return;
    setState(() {
      checklistItems = List<TaskModel>.from(checklistItems)..removeAt(index);
    });
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

  @override
  Widget build(BuildContext context) {
    return addNoteWidget(context);
  }

  Scaffold addNoteWidget(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  selectedColor.withOpacity(0.15),
                  const Color.fromARGB(255, 5, 5, 5),
                  selectedColor.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                TopBarAddnote(
                  saveNote: _saveNote,
                  selectedColor: selectedColor,
                  title: widget.initialNote == null ? 'New Note' : 'Edit Note',
                ),

                // Main Content with proper padding
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 120, // ✅ Space for bottom toolbar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Title field
                        NoteTitleField(controller: _titleController),
                        const SizedBox(height: 16),

                        // Image preview
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

                        // Text field
                        NoteTextField(controller: _textController),

                        // Audio preview
                        if (hasAudio)
                          AddNoteAudioPreview(
                            audioPath: recordedAudioPath,
                            audioDurationMs: recordedAudioDurationMs,
                            selectedColor: selectedColor,
                            onRemoveAudio: _removeAudio,
                          ),

                        const SizedBox(height: 10),

                        // Checklist
                        ChecklistEditorSection(
                          taskController: _taskController,
                          checklistItems: checklistItems,
                          onAddTask: _addTask,
                          onToggleTask: _toggleTask,
                          onRemoveTask: _removeTask,
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ PROFESSIONAL BOTTOM TOOLBAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(0.95),
                color: Colors.black.withOpacity(0.0000000001),

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Color Picker Button
                      BuildToolbarButton(
                        icon: Icons.palette_rounded,
                        label: 'Color',
                        color: selectedColor,
                        onTap: () {
                          setState(() => showColorPicker = !showColorPicker);
                        },
                      ),

                      // Image Picker Button
                      BuildToolbarButton(
                        icon: Icons.image_rounded,
                        label: 'Image',
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
                              selectedImagePaths =
                                  images.map((f) => f.path).toList();
                            });
                          }
                        },
                      ),

                      // Audio Recorder Button
                      GestureDetector(
                        onTap: () {
                          if (hasAudio) {
                            _removeAudio();
                          } else {
                            _showSnackBar(
                              'Long press to record',
                              Colors.purple,
                            );
                          }
                        },
                        onLongPressStart: (_) => _startVoiceRecording(),
                        onLongPressMoveUpdate: (details) {
                          setState(() {
                            dragOffset = details.offsetFromOrigin;
                          });
                        },
                        onLongPressEnd: (_) => _endVoiceRecording(),
                        child: AnimatedScale(
                          scale: isRecording ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return BuildToolbarButton(
                                icon:
                                    hasAudio
                                        ? Icons.mic
                                        : Icons.mic_none_rounded,
                                label: 'Audio',
                                color: Colors.purple,
                                onTap: () {}, // Handled by GestureDetector
                                isRecording: isRecording,
                                pulseValue: _pulseController.value,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Color Picker Sheet
          if (showColorPicker)
            Positioned(
              bottom: 90, // ✅ Above toolbar
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

          // Voice Recording Overlay
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
