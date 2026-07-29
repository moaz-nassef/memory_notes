import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/features/notes/data/notes_repo.dart';
import 'package:memory_notes/features/notes/cubit/notes_state.dart';
import 'package:memory_notes/models/note_model.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._notesRepo) : super(NotesInitial());

  final NotesRepo _notesRepo;
  StreamSubscription<List<NoteModel>>? _notesSub;

  /// Starts watching the notes box and emitting [NotesLoaded] on changes.
  void watchNotes() {
    emit(NotesLoading());
    _notesSub?.cancel();
    _notesSub = _notesRepo.watchNotes().listen(
      (notes) => emit(NotesLoaded(notes)),
      onError: (Object e) => emit(NotesError(e.toString())),
    );
  }

  Future<void> addNote(NoteModel note) => _notesRepo.addNote(note);

  Future<void> updateNote(NoteModel existing, NoteModel edited) =>
      _notesRepo.updateNote(existing, edited);

  Future<void> deleteNote(NoteModel note) =>
      _notesRepo.deleteNoteWithAudio(note);

  @override
  Future<void> close() {
    _notesSub?.cancel();
    return super.close();
  }
}
