import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/core/services/audio_recorder_controller.dart';
import 'package:memory_notes/features/add_note/cubit/add_note_state.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/models/task_model.dart';

class AddNoteCubit extends Cubit<AddNoteState> {
  AddNoteCubit(this._recorder) : super(const AddNoteState());

  final AudioRecorderController _recorder;

  StreamSubscription<double>? _amplitudeSub;
  StreamSubscription<int>? _durationSub;

  NoteModel? _initialNote;
  String? _previousAudioPath;
  int? _previousAudioDurationMs;

  // ── Init ───────────────────────────────────────────────────────────

  /// Pre-fills the form when editing an existing note.
  void init(NoteModel? initial) {
    _initialNote = initial;
    if (initial == null) return;

    emit(
      state.copyWith(
        imagePaths: List<String>.from(initial.imagePaths ?? []),
        checklistItems: List<TaskModel>.from(initial.checklist ?? []),
        audioPath: () => initial.audioPath,
        audioDurationMs: () => initial.audioDurationMs,
        selectedColor: Color(initial.color),
      ),
    );
  }

  // ── Color ──────────────────────────────────────────────────────────

  void toggleColorPicker() =>
      emit(state.copyWith(showColorPicker: !state.showColorPicker));

  void closeColorPicker() => emit(state.copyWith(showColorPicker: false));

  void selectColor(Color color) =>
      emit(state.copyWith(selectedColor: color, showColorPicker: false));

  // ── Images ─────────────────────────────────────────────────────────

  void setImages(List<String> paths) => emit(state.copyWith(imagePaths: paths));

  void removeImage(int index) {
    if (index < 0 || index >= state.imagePaths.length) return;
    emit(
      state.copyWith(
        imagePaths: List<String>.from(state.imagePaths)..removeAt(index),
      ),
    );
  }

  // ── Checklist ──────────────────────────────────────────────────────

  void addTask(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    emit(
      state.copyWith(
        checklistItems: [...state.checklistItems, TaskModel(title: trimmed)],
      ),
    );
  }

  void toggleTask(int index, bool? value) {
    if (index < 0 || index >= state.checklistItems.length) return;
    final items = List<TaskModel>.from(state.checklistItems);
    items[index].isDone = value ?? false;
    emit(state.copyWith(checklistItems: items));
  }

  void removeTask(int index) {
    if (index < 0 || index >= state.checklistItems.length) return;
    emit(
      state.copyWith(
        checklistItems: List<TaskModel>.from(state.checklistItems)
          ..removeAt(index),
      ),
    );
  }

  // ── Audio recording ────────────────────────────────────────────────

  Future<void> startRecording() async {
    _previousAudioPath = state.audioPath;
    _previousAudioDurationMs = state.audioDurationMs;

    emit(
      state.copyWith(
        isRecording: true,
        showVoiceOverlay: true,
        recordingDurationMs: 0,
        dragOffset: Offset.zero,
        waveSamples: List<double>.filled(18, 0),
      ),
    );

    try {
      await _recorder.startRecording();

      await _amplitudeSub?.cancel();
      await _durationSub?.cancel();

      _amplitudeSub = _recorder.amplitudeStream.listen((amp) {
        if (isClosed) return;
        final normalized = amp.clamp(0.0, 1.0);
        emit(
          state.copyWith(
            waveSamples: [...state.waveSamples.skip(1), normalized],
          ),
        );
      });

      _durationSub = _recorder.durationMsStream.listen((ms) {
        if (isClosed) return;
        emit(state.copyWith(recordingDurationMs: ms));
      });
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isRecording: false,
          showVoiceOverlay: false,
          snackMessage: () => 'Failed to start recording: $e',
          snackColor: () => AppColors.error,
        ),
      );
    }
  }

  void updateDrag(Offset offset) => emit(state.copyWith(dragOffset: offset));

  Future<void> endRecording() async {
    final isDelete = state.dragOffset.dx < -80;
    final isSend = state.dragOffset.dy < -80;

    String? snackMessage;
    Color? snackColor;
    String? newAudioPath = state.audioPath;
    int? newAudioDurationMs = state.audioDurationMs;

    try {
      if (isDelete) {
        await _recorder.cancelRecording();
        snackMessage = 'Current recording deleted';
        snackColor = AppColors.error;
      } else if (isSend) {
        final savedPath = await _recorder.stopRecording();
        if (savedPath != null) {
          newAudioPath = savedPath;
          newAudioDurationMs = state.recordingDurationMs;
          snackMessage = 'Recording saved';
          snackColor = AppColors.success;
        }
      } else {
        await _recorder.cancelRecording();
        snackMessage = 'Recording canceled';
        snackColor = AppColors.warning;
      }
    } catch (e) {
      snackMessage = 'Error while finishing recording: $e';
      snackColor = AppColors.error;
    }

    await _amplitudeSub?.cancel();
    await _durationSub?.cancel();
    _amplitudeSub = null;
    _durationSub = null;

    if (!isSend) {
      newAudioPath = _previousAudioPath;
      newAudioDurationMs = _previousAudioDurationMs;
    }

    if (isClosed) return;
    emit(
      state.copyWith(
        audioPath: () => newAudioPath,
        audioDurationMs: () => newAudioDurationMs,
        isRecording: false,
        showVoiceOverlay: false,
        dragOffset: Offset.zero,
        snackMessage: () => snackMessage,
        snackColor: () => snackColor,
      ),
    );
  }

  Future<void> removeAudio() async {
    final path = state.audioPath;
    if (path != null) {
      try {
        await _recorder.delete(path);
      } catch (_) {
        // keep UX stable even if file was already removed
      }
    }

    if (isClosed) return;
    emit(state.copyWith(audioPath: () => null, audioDurationMs: () => null));
  }

  void showRecordHint() => emit(
    state.copyWith(
      snackMessage: () => 'Long press to record',
      snackColor: () => AppColors.accent,
    ),
  );

  // ── Save ───────────────────────────────────────────────────────────

  void saveNote({required String title, required String text}) {
    if (!_canSave(title: title, text: text)) {
      emit(
        state.copyWith(
          snackMessage: () => 'Add a title and at least one content type',
          snackColor: () => AppColors.warning.withValues(alpha: 0.5),
        ),
      );
      return;
    }

    final note = NoteModel(
      title: title.trim(),
      text: text.trim().isEmpty ? null : text.trim(),
      imagePaths: state.imagePaths.isEmpty ? null : List.from(state.imagePaths),
      audioPath: state.audioPath,
      audioDurationMs: state.audioDurationMs,
      checklist:
          state.checklistItems.isEmpty
              ? null
              : List<TaskModel>.from(state.checklistItems),
      createdAt: _initialNote?.createdAt ?? DateTime.now(),
      color: state.selectedColor.toARGB32(),
    );

    emit(state.copyWith(savedNote: () => note));
  }

  bool _canSave({required String title, required String text}) {
    return title.trim().isNotEmpty ||
        text.trim().isNotEmpty ||
        state.imagePaths.isNotEmpty ||
        state.audioPath != null ||
        state.checklistItems.isNotEmpty;
  }

  // ── One-shot events ────────────────────────────────────────────────

  /// Clears the consumed snackbar event after the view displays it.
  void clearMessages() {
    if (isClosed) return;
    emit(state.copyWith(snackMessage: () => null, snackColor: () => null));
  }

  @override
  Future<void> close() async {
    await _amplitudeSub?.cancel();
    await _durationSub?.cancel();
    _recorder.dispose();
    return super.close();
  }
}
