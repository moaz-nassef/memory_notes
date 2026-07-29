import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/core/di_container.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_state.dart';
import 'package:memory_notes/features/add_note/widgets/audio_note_section.dart';
import 'package:memory_notes/features/add_note/widgets/checklist_editor_section.dart';
import 'package:memory_notes/features/add_note/widgets/top_bar_add_note.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/audio/build_voice_overlay.dart';
import 'package:memory_notes/shared/build_toolbar_button.dart';
import 'package:memory_notes/shared/color/color_picker_sheet.dart';
import 'package:memory_notes/shared/custom_snack.dart';
import 'package:memory_notes/shared/image/image_picker_page.dart';
import 'package:memory_notes/shared/image/note_image_preview.dart';
import 'package:memory_notes/shared/text/note_text_field.dart';
import 'package:memory_notes/shared/text/note_title_field.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({super.key, this.initialNote});

  final NoteModel? initialNote;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddNoteCubit>(
      create: (_) => sl<AddNoteCubit>()..init(initialNote),
      child: _AddNoteView(initialNote: initialNote),
    );
  }
}

class _AddNoteView extends StatefulWidget {
  const _AddNoteView({this.initialNote});

  final NoteModel? initialNote;

  @override
  State<_AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<_AddNoteView>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _taskController = TextEditingController();

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    final note = widget.initialNote;
    if (note != null) {
      _titleController.text = note.title;
      _textController.text = note.text ?? '';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _titleController.dispose();
    _textController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddNoteCubit, AddNoteState>(
      listenWhen:
          (previous, current) =>
              current.snackMessage != null || current.savedNote != null,
      listener: (context, state) {
        final message = state.snackMessage;
        if (message != null) {
          showCustomSnack(context, message, color: state.snackColor);
          context.read<AddNoteCubit>().clearMessages();
        }
        final savedNote = state.savedNote;
        if (savedNote != null) {
          Navigator.pop(context, savedNote);
        }
      },
      child: BlocBuilder<AddNoteCubit, AddNoteState>(
        builder: (context, state) {
          final cubit = context.read<AddNoteCubit>();

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
                        state.selectedColor.withValues(alpha: 0.15),
                        AppColors.scaffoldDark,
                        state.selectedColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      // Top Bar
                      TopBarAddnote(
                        saveNote:
                            () => cubit.saveNote(
                              title: _titleController.text,
                              text: _textController.text,
                            ),
                        selectedColor: state.selectedColor,
                        title:
                            widget.initialNote == null
                                ? 'New Note'
                                : 'Edit Note',
                      ),

                      // Main Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 120, // Space for bottom toolbar
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // Title field
                              NoteTitleField(controller: _titleController),
                              const SizedBox(height: 16),

                              // Image preview
                              if (state.imagePaths.isNotEmpty)
                                NoteImagesSlideshow(
                                  images: state.imagePaths,
                                  shadowColor: state.selectedColor,
                                  onRemove: cubit.removeImage,
                                ),

                              // Text field
                              NoteTextField(controller: _textController),

                              // Audio recordings (a note can hold several)
                              for (var i = 0; i < state.audioPaths.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: AddNoteAudioPreview(
                                    audioPath: state.audioPaths[i],
                                    audioDurationMs: state.audioDurationsMs[i],
                                    index: i + 1,
                                    onRemoveAudio: () => cubit.removeAudio(i),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // Checklist
                              ChecklistEditorSection(
                                taskController: _taskController,
                                checklistItems: state.checklistItems,
                                onAddTask: () {
                                  cubit.addTask(_taskController.text);
                                  _taskController.clear();
                                },
                                onToggleTask: cubit.toggleTask,
                                onRemoveTask: cubit.removeTask,
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom toolbar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.0000000001),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                              color: state.selectedColor,
                              onTap: cubit.toggleColorPicker,
                            ),

                            // Image Picker Button
                            BuildToolbarButton(
                              icon: Icons.image_rounded,
                              label: 'Image',
                              color: Colors.blue,
                              onTap: () => _pickImages(context, cubit),
                            ),

                            // Audio Recorder Button
                            // Tap = hint only. Long press = record.
                            // (Deletion happens via each preview's ✕ —
                            // a stray tap must never destroy a recording.)
                            GestureDetector(
                              onTap: cubit.showRecordHint,
                              onLongPressStart: (_) => cubit.startRecording(),
                              onLongPressMoveUpdate:
                                  (details) => cubit.updateDrag(
                                    details.offsetFromOrigin,
                                  ),
                              onLongPressEnd: (_) => cubit.endRecording(),
                              child: AnimatedScale(
                                scale: state.isRecording ? 1.1 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return BuildToolbarButton(
                                      icon:
                                          state.hasAudio
                                              ? Icons.mic
                                              : Icons.mic_none_rounded,
                                      label: 'Audio',
                                      color: AppColors.accent,
                                      onTap:
                                          () {}, // Handled by GestureDetector
                                      isRecording: state.isRecording,
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
                if (state.showColorPicker)
                  Positioned(
                    bottom: 90, // Above toolbar
                    left: 0,
                    right: 0,
                    child: ColorPickerSheet(
                      noteColors: AppColors.noteColors,
                      selectedColor: state.selectedColor,
                      onColorSelected: cubit.selectColor,
                      onClose: cubit.closeColorPicker,
                    ),
                  ),

                // Voice Recording Overlay
                if (state.showVoiceOverlay)
                  Positioned.fill(
                    child: BuildVoiceOverlay(
                      dragOffset: state.dragOffset,
                      pulseController: _pulseController,
                      recordingDurationMs: state.recordingDurationMs,
                      waveSamples: state.waveSamples,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImages(BuildContext context, AddNoteCubit cubit) async {
    final images = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(builder: (_) => const ImagePickerPage()),
    );
    if (images != null && images.isNotEmpty) {
      cubit.setImages(images.map((f) => f.path).toList());
    }
  }
}
