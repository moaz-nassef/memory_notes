import 'package:flutter/material.dart';
import 'package:memory_notes/views/presentation/Home_page_notesView.dart';
import 'package:memory_notes/views/presentation/add_note/add_note_screen.dart';

class AppRoutes {
  static const String notesList = '/';
  static const String addNote = '/add-note';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.notesList:
        return MaterialPageRoute(
          builder: (_) => const NotesListScreen(),
        );
      case AppRoutes.addNote:
        return MaterialPageRoute(
          builder: (_) => const AddNoteScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotesListScreen(),
        );
    }
  }
}

