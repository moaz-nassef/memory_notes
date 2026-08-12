import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/core/di_container.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_cubit.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_state.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_cubit.dart';
import 'package:memory_notes/features/voice_analysis/cubit/voice_analysis_state.dart';
import 'package:memory_notes/features/voice_analysis/data/voice_analysis_result.dart';
import 'package:memory_notes/features/voice_analysis/views/voice_review_screen.dart';
import 'package:memory_notes/features/voice_analysis/widgets/voice_analysis_loading_overlay.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/custom_snack.dart';

class VoiceAiCaptureScreen extends StatelessWidget {
  const VoiceAiCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddNoteCubit>(create: (_) => sl<AddNoteCubit>()),
        BlocProvider<VoiceAnalysisCubit>(
          create: (_) => sl<VoiceAnalysisCubit>(),
        ),
      ],
      child: const _VoiceAiCaptureView(),
    );
  }
}

class _VoiceAiCaptureView extends StatefulWidget {
  const _VoiceAiCaptureView();

  @override
  State<_VoiceAiCaptureView> createState() => _VoiceAiCaptureViewState();
}

class _VoiceAiCaptureViewState extends State<_VoiceAiCaptureView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceAnalysisCubit, VoiceAnalysisState>(
      listener: _onAnalysisStateChanged,
      child: BlocListener<AddNoteCubit, AddNoteState>(
        listenWhen: (previous, current) => current.snackMessage != null,
        listener: (context, state) {
          final message = state.snackMessage;
          if (message == null) return;
          showCustomSnack(context, message, color: state.snackColor);
          context.read<AddNoteCubit>().clearMessages();
        },
        child: BlocBuilder<AddNoteCubit, AddNoteState>(
          builder: (context, noteState) {
            return BlocBuilder<VoiceAnalysisCubit, VoiceAnalysisState>(
              builder: (context, analysisState) {
                final noteCubit = context.read<AddNoteCubit>();
                final isAnalyzing =
                    analysisState.status == VoiceAnalysisStatus.loading;

                return Scaffold(
                  backgroundColor: AppColors.scaffoldDark,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      tooltip: 'Close AI voice note',
                      onPressed: () => _close(noteCubit),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    title: const Text('Voice note with AI'),
                  ),
                  body: Stack(
                    children: [
                      SafeArea(
                        top: false,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 54,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    noteState.isRecording
                                        ? 'Listening…'
                                        : 'Turn your voice into a note',
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    noteState.isRecording
                                        ? _formatDuration(
                                          noteState.recordingDurationMs,
                                        )
                                        : 'Record, then review the title, text, and tasks before saving.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Semantics(
                                    label:
                                        noteState.isRecording
                                            ? 'Stop and analyze recording'
                                            : 'Start AI voice recording',
                                    button: true,
                                    child: FilledButton(
                                      key: const Key('voice_ai_record'),
                                      onPressed:
                                          isAnalyzing
                                              ? null
                                              : () =>
                                                  _toggleRecording(noteCubit),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            noteState.isRecording
                                                ? AppColors.error
                                                : AppColors.accent,
                                        shape: const CircleBorder(),
                                        padding: const EdgeInsets.all(28),
                                      ),
                                      child: Icon(
                                        noteState.isRecording
                                            ? Icons.stop_rounded
                                            : Icons.mic_rounded,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                  if (!noteState.isRecording &&
                                      noteState.audioPaths.isNotEmpty) ...[
                                    const SizedBox(height: 28),
                                    VoiceAiSavedRecordingActions(
                                      hasError:
                                          analysisState.status ==
                                          VoiceAnalysisStatus.failure,
                                      errorMessage: analysisState.errorMessage,
                                      onRetry:
                                          isAnalyzing
                                              ? null
                                              : () => context
                                                  .read<VoiceAnalysisCubit>()
                                                  .analyze(
                                                    File(
                                                      noteState.audioPaths.last,
                                                    ),
                                                  ),
                                      onSaveAudioOnly:
                                          () => _saveAudioOnly(noteState),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (isAnalyzing) const VoiceAnalysisLoadingOverlay(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleRecording(AddNoteCubit cubit) async {
    if (!cubit.state.isRecording) {
      await cubit.startRecording();
      return;
    }

    final audioPath = await cubit.endRecording(saveRegardlessOfDrag: true);
    if (audioPath != null && mounted) {
      await context.read<VoiceAnalysisCubit>().analyze(File(audioPath));
    }
  }

  void _onAnalysisStateChanged(BuildContext context, VoiceAnalysisState state) {
    if (state.status == VoiceAnalysisStatus.success && state.result != null) {
      final result = state.result!;
      context.read<VoiceAnalysisCubit>().clearEvent();
      unawaited(_openReview(result));
    }
    if (state.status == VoiceAnalysisStatus.failure &&
        state.errorMessage != null) {
      showCustomSnack(context, state.errorMessage!, color: AppColors.error);
    }
  }

  Future<void> _openReview(VoiceAnalysisResult result) async {
    final noteState = context.read<AddNoteCubit>().state;
    final reviewedNote = await Navigator.of(context).push<NoteModel>(
      MaterialPageRoute(
        builder:
            (_) => MultiBlocProvider(
              providers: [
                BlocProvider<AddNoteCubit>.value(
                  value: context.read<AddNoteCubit>(),
                ),
                BlocProvider<VoiceAnalysisCubit>.value(
                  value: sl<VoiceAnalysisCubit>(),
                ),
              ],
              child: VoiceReviewScreen(
                analysis: result,
                audioPaths: noteState.audioPaths,
                audioDurationsMs: noteState.audioDurationsMs,
                imagePaths: const [],
                initialTitle: '',
                initialText: '',
                initialTasks: const [],
                color: AppColors.defaultNoteColor,
                enableFollowUps: true,
              ),
            ),
      ),
    );
    if (reviewedNote != null && mounted) {
      Navigator.pop(context, reviewedNote);
    }
  }

  Future<void> _close(AddNoteCubit cubit) async {
    await cubit.cancelActiveRecording();
    if (mounted) Navigator.pop(context);
  }

  void _saveAudioOnly(AddNoteState state) {
    Navigator.pop(
      context,
      NoteModel(
        title: 'Voice note',
        audioPaths: List.from(state.audioPaths),
        audioDurationsMs: List.from(state.audioDurationsMs),
        createdAt: DateTime.now(),
        color: AppColors.defaultNoteColor.toARGB32(),
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

class VoiceAiSavedRecordingActions extends StatelessWidget {
  const VoiceAiSavedRecordingActions({
    super.key,
    required this.hasError,
    required this.errorMessage,
    required this.onRetry,
    required this.onSaveAudioOnly,
  });

  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback onSaveAudioOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (hasError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        FilledButton.icon(
          key: const Key('voice_ai_retry'),
          onPressed: onRetry,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: const Text('Analyze recording'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const Key('voice_ai_save_audio_only'),
          onPressed: onSaveAudioOnly,
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text('Save audio only'),
        ),
      ],
    );
  }
}
