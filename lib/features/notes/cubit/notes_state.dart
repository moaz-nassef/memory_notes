import 'package:memory_notes/models/note_model.dart';

sealed class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  NotesLoaded(this.notes);

  final List<NoteModel> notes;
}

class NotesError extends NotesState {
  NotesError(this.message);

  final String message;
}
