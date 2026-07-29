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
  Future<void> updateNote(NoteModel existing, NoteModel edited) async {
    existing
      ..title = edited.title
      ..text = edited.text
      ..imagePaths = edited.imagePaths
      ..audioPath = edited.audioPath
      ..audioDurationMs = edited.audioDurationMs
      ..checklist = edited.checklist
      ..color = edited.color;
    await existing.save();
  }

  /// Deletes the note record and its audio file (if any).
  Future<void> deleteNoteWithAudio(NoteModel note) async {
    final audioPath = note.audioPath;

    if (audioPath != null && audioPath.isNotEmpty) {
      try {
        await _audioFileHelper.deleteRecord(audioPath);
      } catch (_) {
        // Ignore file-delete errors and continue deleting note record.
      }
    }

    await note.delete();
  }
}
