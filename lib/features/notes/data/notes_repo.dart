import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:memory_notes/core/services/audio_recorder_file_helper.dart';
import 'package:memory_notes/models/note_model.dart';

/// Data layer for notes.
///
/// Wraps the Hive box and owns every read/write/delete operation,
/// including cleaning up the audio file attached to a note.
class NotesRepo {
  NotesRepo(this._notesBox, this._audioFileHelper);

  final Box<NoteModel> _notesBox;
  final AudioRecorderFileHelper _audioFileHelper;

  /// Emits the current notes immediately, then again on every box change.
  Stream<List<NoteModel>> watchNotes() {
    late StreamController<List<NoteModel>> controller;

    void emitCurrent() => controller.add(_notesBox.values.toList());

    controller = StreamController<List<NoteModel>>(
      onListen: () {
        emitCurrent();
        _notesBox.listenable().addListener(emitCurrent);
      },
      onCancel: () => _notesBox.listenable().removeListener(emitCurrent),
    );

    return controller.stream;
  }

  Future<void> addNote(NoteModel note) => _notesBox.add(note);

  /// Copies the edited fields into the existing (Hive-managed) note.
  ///
  /// Any recording that was removed during the edit gets its file
  /// deleted, so no orphaned audio piles up on disk.
  Future<void> updateNote(NoteModel existing, NoteModel edited) async {
    final removedPaths =
        existing.allAudioPaths
            .where((path) => !edited.allAudioPaths.contains(path))
            .toList();

    existing
      ..title = edited.title
      ..text = edited.text
      ..imagePaths = edited.imagePaths
      ..audioPath =
          null // legacy field — list fields are the source of truth
      ..audioDurationMs = null
      ..audioPaths = edited.audioPaths
      ..audioDurationsMs = edited.audioDurationsMs
      ..checklist = edited.checklist
      ..color = edited.color;
    await existing.save();

    for (final path in removedPaths) {
      try {
        await _audioFileHelper.deleteRecord(path);
      } catch (_) {
        // Ignore file-delete errors; the note is already saved.
      }
    }
  }

  /// Deletes the note record and all of its audio files (if any).
  Future<void> deleteNoteWithAudio(NoteModel note) async {
    for (final path in note.allAudioPaths) {
      try {
        await _audioFileHelper.deleteRecord(path);
      } catch (_) {
        // Ignore file-delete errors and continue deleting note record.
      }
    }

    await note.delete();
  }
}
