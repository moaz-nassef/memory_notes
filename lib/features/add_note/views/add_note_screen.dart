import 'dart:io';
import 'dart:ui';

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
  /// Content stays readable on tablets / desktop windows.
  static const double _maxContentWidth = 720;

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
                // Background: deep base + a soft glow of the note color
                // bleeding in from the top and bottom edges.
                const ColoredBox(
                  color: AppColors.scaffoldDark,
                  child: SizedBox.expand(),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -1.05),
                      radius: 1.25,
                      colors: [
                        state.selectedColor.withValues(alpha: 0.30),
                        state.selectedColor.withValues(alpha: 0.08),
                        AppColors.scaffoldDark.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.95, 1.05),
                      radius: 0.85,
                      colors: [
                        state.selectedColor.withValues(alpha: 0.15),
                        state.selectedColor.withValues(alpha: 0.08),
                        AppColors.scaffoldDark.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.95, 1.05),
                      radius: 0.85,
                      colors: [
                        state.selectedColor.withValues(alpha: 0.15),
                        state.selectedColor.withValues(alpha: 0.08),
                        AppColors.scaffoldDark.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),

                SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
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
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 140, // Space for bottom toolbar
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),

                                  // Title field
                                  NoteTitleField(controller: _titleController),
                                  const SizedBox(height: 8),

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
                                  for (
                                    var i = 0;
                                    i < state.audioPaths.length;
                                    i++
                                  )
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AddNoteAudioPreview(
                                        audioPath: state.audioPaths[i],
                                        audioDurationMs:
                                            state.audioDurationsMs[i],
                                        index: i + 1,
                                        onRemoveAudio:
                                            () => cubit.removeAudio(i),
                                      ),
                                    ),

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
                  ),
                ),

                // Bottom toolbar — floating glass pill.
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight.withValues(
                                    alpha: 0.7,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.borderStrong,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                      color: AppColors.teal,
                                      onTap: () => _pickImages(context, cubit),
                                    ),

                                    // Audio Recorder Button
                                    // Tap = hint only. Long press = record.
                                    // (Deletion happens via each preview's ✕ —
                                    // a stray tap must never destroy a
                                    // recording.)
                                    GestureDetector(
                                      onTap: cubit.showRecordHint,
                                      onLongPressStart:
                                          (_) => cubit.startRecording(),
                                      onLongPressMoveUpdate:
                                          (details) => cubit.updateDrag(
                                            details.offsetFromOrigin,
                                          ),
                                      onLongPressEnd:
                                          (_) => cubit.endRecording(),
                                      child: AnimatedScale(
                                        scale: state.isRecording ? 1.1 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return BuildToolbarButton(
                                              icon:
                                                  state.hasAudio
                                                      ? Icons.mic
                                                      : Icons.mic_none_rounded,
                                              label: 'Audio',
                                              color: AppColors.pink,
                                              onTap:
                                                  () {}, // Handled by GestureDetector
                                              isRecording: state.isRecording,
                                              pulseValue:
                                                  _pulseController.value,
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
                      ),
                    ),
                  ),
                ),

                // Tap-catcher that closes the color picker when tapping
                // anywhere outside of it.
                if (state.showColorPicker)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: cubit.closeColorPicker,
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox.expand(),
                    ),
                  ),

                // Color Picker Sheet — anchored above the toolbar.
                if (state.showColorPicker)
                  Positioned(
                    bottom: 110,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ColorPickerSheet(
                          noteColors: AppColors.noteColors,
                          selectedColor: state.selectedColor,
                          onColorSelected: cubit.selectColor,
                          onClose: cubit.closeColorPicker,
                        ),
                      ),
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
