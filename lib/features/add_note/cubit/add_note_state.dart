import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';

/// Immutable form state for the Add/Edit Note screen.
///
/// [snackMessage] and [savedNote] are one-shot events consumed by the
/// view's BlocListener, then cleared via [AddNoteCubit.clearMessages].
class AddNoteState {
  const AddNoteState({
    this.imagePaths = const [],
    this.checklistItems = const [],
    this.selectedColor = AppColors.defaultNoteColor,
    this.showColorPicker = false,
    this.audioPaths = const [],
    this.audioDurationsMs = const [],
    this.isRecording = false,
    this.showVoiceOverlay = false,
    this.dragOffset = Offset.zero,
    this.recordingDurationMs = 0,
    this.waveSamples = const [],
    this.snackMessage,
    this.snackColor,
    this.savedNote,
  });

  final List<String> imagePaths;
  final List<TaskModel> checklistItems;
  final Color selectedColor;
  final bool showColorPicker;

  /// All voice recordings attached to the note (paths + durations
  /// are aligned by index).
  final List<String> audioPaths;
  final List<int> audioDurationsMs;

  final bool isRecording;
  final bool showVoiceOverlay;
  final Offset dragOffset;
  final int recordingDurationMs;
  final List<double> waveSamples;

  /// One-shot snackbar event (null = nothing to show).
  final String? snackMessage;
  final Color? snackColor;

  /// One-shot "note is ready" event (null = still editing).
  final NoteModel? savedNote;

  bool get hasAudio => audioPaths.isNotEmpty;

  AddNoteState copyWith({
    List<String>? imagePaths,
    List<TaskModel>? checklistItems,
    Color? selectedColor,
    bool? showColorPicker,
    List<String>? audioPaths,
    List<int>? audioDurationsMs,
    bool? isRecording,
    bool? showVoiceOverlay,
    Offset? dragOffset,
    int? recordingDurationMs,
    List<double>? waveSamples,
    String? Function()? snackMessage,
    Color? Function()? snackColor,
    NoteModel? Function()? savedNote,
  }) {
    return AddNoteState(
      imagePaths: imagePaths ?? this.imagePaths,
      checklistItems: checklistItems ?? this.checklistItems,
      selectedColor: selectedColor ?? this.selectedColor,
      showColorPicker: showColorPicker ?? this.showColorPicker,
      audioPaths: audioPaths ?? this.audioPaths,
      audioDurationsMs: audioDurationsMs ?? this.audioDurationsMs,
      isRecording: isRecording ?? this.isRecording,
      showVoiceOverlay: showVoiceOverlay ?? this.showVoiceOverlay,
      dragOffset: dragOffset ?? this.dragOffset,
      recordingDurationMs: recordingDurationMs ?? this.recordingDurationMs,
      waveSamples: waveSamples ?? this.waveSamples,
      snackMessage: snackMessage != null ? snackMessage() : this.snackMessage,
      snackColor: snackColor != null ? snackColor() : this.snackColor,
      savedNote: savedNote != null ? savedNote() : this.savedNote,
    );
  }
}
