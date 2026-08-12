import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_state.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_cubit.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_state.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';
import 'package:memory_notes/features/voice_analysis/widgets/voice_analysis_loading_overlay.dart';
import 'package:memory_notes/features/voice_analysis/views/voice_review_standalone_body.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';
import 'package:memory_notes/shared/audio/audio_player_widget.dart';
import 'package:memory_notes/shared/custom_snack.dart';

class VoiceReviewScreen extends StatefulWidget {
  const VoiceReviewScreen({
    super.key,
    required this.analysis,
    required this.audioPaths,
    required this.audioDurationsMs,
    required this.imagePaths,
    required this.initialTitle,
    required this.initialText,
    required this.initialTasks,
    required this.color,
    this.enableFollowUps = false,
  });

  final VoiceAnalysisResult analysis;
  final List<String> audioPaths;
  final List<int> audioDurationsMs;
  final List<String> imagePaths;
  final String initialTitle;
  final String initialText;
  final List<TaskModel> initialTasks;
  final Color color;
  final bool enableFollowUps;

  @override
  State<VoiceReviewScreen> createState() => _VoiceReviewScreenState();
}

class _VoiceReviewScreenState extends State<VoiceReviewScreen> {
  static const _maxContentWidth = 720.0;

  late final TextEditingController _titleController;
  late final TextEditingController _textController;
  final List<TextEditingController> _taskControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text:
          widget.initialTitle.trim().isEmpty
              ? widget.analysis.title
              : widget.initialTitle.trim(),
    );
    _textController = TextEditingController(
      text: _combinedText(widget.initialText, widget.analysis.text),
    );
    for (final task in widget.initialTasks) {
      _taskControllers.add(TextEditingController(text: task.title));
    }
    for (final task in widget.analysis.tasks) {
      _taskControllers.add(TextEditingController(text: _taskText(task)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    for (final controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Review voice note'),
        actions: [
          TextButton.icon(
            key: const Key('voice_review_save'),
            onPressed: _save,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          widget.enableFollowUps
              ? Stack(
                children: [
                  BlocConsumer<VoiceAnalysisCubit, VoiceAnalysisState>(
                    listener: _onAnalysisStateChanged,
                    builder: (context, analysisState) {
                      final isAnalyzing =
                          analysisState.status == VoiceAnalysisStatus.loading;
                      return BlocBuilder<AddNoteCubit, AddNoteState>(
                        builder: (context, noteState) {
                          return SafeArea(
                            top: false,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: _maxContentWidth,
                                ),
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    12,
                                    20,
                                    32,
                                  ),
                                  children: [
                                    VoiceReviewInfoCard(color: widget.color),
                                    const SizedBox(height: 20),
                                    for (
                                      var index = 0;
                                      index < noteState.audioPaths.length;
                                      index++
                                    )
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: AudioPlayerWidget(
                                          audioPath:
                                              noteState.audioPaths[index],
                                          audioDurationMs:
                                              index <
                                                      noteState
                                                          .audioDurationsMs
                                                          .length
                                                  ? noteState
                                                      .audioDurationsMs[index]
                                                  : null,
                                        ),
                                      ),
                                    VoiceReviewFollowUpSection(
                                      isRecording: noteState.isRecording,
                                      isAnalyzing: isAnalyzing,
                                      recordingDurationMs:
                                          noteState.recordingDurationMs,
                                      onToggle:
                                          isAnalyzing
                                              ? null
                                              : () => _toggleFollowUpRecording(
                                                context,
                                              ),
                                    ),
                                    const SizedBox(height: 8),
                                    VoiceReviewTextField(
                                      key: const Key('voice_review_title'),
                                      controller: _titleController,
                                      label: 'Title',
                                      hint: 'Give this note a title',
                                      minLines: 1,
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 16),
                                    VoiceReviewTextField(
                                      key: const Key('voice_review_text'),
                                      controller: _textController,
                                      label: 'Transcript',
                                      hint:
                                          'The extracted text will appear here',
                                      minLines: 7,
                                      maxLines: null,
                                    ),
                                    const SizedBox(height: 20),
                                    VoiceReviewTasksSection(
                                      controllers: _taskControllers,
                                      onAdd: _addTask,
                                      onRemove: _removeTask,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<VoiceAnalysisCubit, VoiceAnalysisState>(
                    builder: (context, state) {
                      if (state.status == VoiceAnalysisStatus.loading) {
                        return const VoiceAnalysisLoadingOverlay();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              )
              : VoiceReviewStandaloneBody(
                audioPaths: widget.audioPaths,
                audioDurationsMs: widget.audioDurationsMs,
                color: widget.color,
                titleController: _titleController,
                textController: _textController,
                taskControllers: _taskControllers,
                onAddTask: _addTask,
                onRemoveTask: _removeTask,
              ),
    );
  }

  String _combinedText(String existing, String transcript) {
    final values = [
      existing.trim(),
      transcript.trim(),
    ].where((value) => value.isNotEmpty);
    return values.join('\n\n');
  }

  void _addTask() {
    setState(() => _taskControllers.add(TextEditingController()));
  }

  void _removeTask(int index) {
    final controller = _taskControllers.removeAt(index);
    controller.dispose();
    setState(() {});
  }

  Future<void> _toggleFollowUpRecording(BuildContext context) async {
    final noteCubit = context.read<AddNoteCubit>();
    final analysisCubit = context.read<VoiceAnalysisCubit>();
    if (!noteCubit.state.isRecording) {
      await noteCubit.startRecording();
      return;
    }

    final audioPath = await noteCubit.endRecording(saveRegardlessOfDrag: true);
    noteCubit.clearMessages();
    if (audioPath == null || !mounted) return;

    await analysisCubit.analyze(File(audioPath), previous: _currentResult());
  }

  VoiceAnalysisResult _currentResult() {
    final tasks = _taskControllers
        .map((controller) => controller.text.trim())
        .where((title) => title.isNotEmpty)
        .map((title) => VoiceAnalysisTask(title: title))
        .toList(growable: false);
    return VoiceAnalysisResult(
      title: _titleController.text.trim(),
      text: _textController.text.trim(),
      tasks: tasks,
    );
  }

  String _taskText(VoiceAnalysisTask task) {
    final duration = task.durationMinutes;
    return duration == null ? task.title : '$duration min - ${task.title}';
  }

  Future<void> _onAnalysisStateChanged(
    BuildContext context,
    VoiceAnalysisState state,
  ) async {
    final result = state.result;
    if (state.status == VoiceAnalysisStatus.success && result != null) {
      context.read<VoiceAnalysisCubit>().clearEvent();
      _applyMergedResult(result);
      if (mounted) {
        showCustomSnack(
          context,
          'Follow-up merged into this note.',
          color: AppColors.success,
        );
      }
    }
    if (state.status == VoiceAnalysisStatus.failure &&
        state.errorMessage != null) {
      showCustomSnack(context, state.errorMessage!, color: AppColors.error);
    }
  }

  void _applyMergedResult(VoiceAnalysisResult result) {
    setState(() {
      if (result.title.trim().isNotEmpty) {
        _titleController.text = result.title.trim();
      }
      if (result.text.trim().isNotEmpty) {
        _textController.text = result.text.trim();
      }
      for (final controller in _taskControllers) {
        controller.dispose();
      }
      _taskControllers.clear();
      for (final task in result.tasks) {
        _taskControllers.add(TextEditingController(text: task.title));
      }
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();
    final tasks = _taskControllers
        .map((controller) => controller.text.trim())
        .where((title) => title.isNotEmpty)
        .map((title) => TaskModel(title: title))
        .toList(growable: false);

    if (title.isEmpty && text.isEmpty && tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a title, text, or task before saving.'),
        ),
      );
      return;
    }

    final noteState = context.read<AddNoteCubit>().state;
    final audioPaths =
        noteState.audioPaths.isEmpty ? widget.audioPaths : noteState.audioPaths;
    final audioDurationsMs =
        noteState.audioDurationsMs.isEmpty
            ? widget.audioDurationsMs
            : noteState.audioDurationsMs;

    Navigator.pop(
      context,
      NoteModel(
        title: title.isEmpty ? 'Voice note' : title,
        text: text.isEmpty ? null : text,
        imagePaths:
            widget.imagePaths.isEmpty ? null : List.from(widget.imagePaths),
        audioPaths: audioPaths.isEmpty ? null : List.from(audioPaths),
        audioDurationsMs:
            audioDurationsMs.isEmpty ? null : List.from(audioDurationsMs),
        checklist: tasks.isEmpty ? null : tasks,
        createdAt: DateTime.now(),
        color: widget.color.toARGB32(),
      ),
    );
  }
}

class VoiceReviewFollowUpSection extends StatelessWidget {
  const VoiceReviewFollowUpSection({
    super.key,
    required this.isRecording,
    required this.isAnalyzing,
    required this.recordingDurationMs,
    required this.onToggle,
  });

  final bool isRecording;
  final bool isAnalyzing;
  final int recordingDurationMs;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final title =
        isRecording
            ? 'Recording follow-up…'
            : isAnalyzing
            ? 'Merging with AI…'
            : 'Add a follow-up voice';

    final subtitle =
        isRecording
            ? _formatDuration(recordingDurationMs)
            : isAnalyzing
            ? 'Your recordings stay on this device.'
            : 'Record extra details and they will be merged into this note without re-analyzing the first voice.';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.40)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: isRecording ? AppColors.error : AppColors.accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            key: const Key('voice_review_followup'),
            tooltip:
                isRecording ? 'Stop and merge with AI' : 'Record follow-up',
            onPressed: onToggle,
            style: IconButton.styleFrom(
              backgroundColor: isRecording ? AppColors.error : AppColors.accent,
            ),
            icon: Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class VoiceReviewInfoCard extends StatelessWidget {
  const VoiceReviewInfoCard({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Check and edit the title, transcript, and suggested tasks before saving.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceReviewTextField extends StatelessWidget {
  const VoiceReviewTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.minLines,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int minLines;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      textField: true,
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

class VoiceReviewTasksSection extends StatelessWidget {
  const VoiceReviewTasksSection({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Suggested tasks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                key: const Key('voice_review_add_task'),
                tooltip: 'Add task',
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          for (var index = 0; index < controllers.length; index++)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_unchecked_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      key: Key('voice_review_task_$index'),
                      controller: controllers[index],
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Task',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove task',
                    onPressed: () => onRemove(index),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
