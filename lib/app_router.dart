import 'package:flutter/material.dart';
import 'package:memory_notes/features/add_note/views/add_note_screen.dart';
import 'package:memory_notes/features/notes/views/home_page_notes_view.dart';
import 'package:memory_notes/features/onboarding/views/onboarding_screen.dart';
import 'package:memory_notes/models/note_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String notesList = '/notes';
  static const String addNote = '/add-note';
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _smoothRoute(const OnboardingScreen(), settings);
      case AppRoutes.notesList:
        return _smoothRoute(const NotesListScreen(), settings);
      case AppRoutes.addNote:
        final initialNote = settings.arguments as NoteModel?;
        return _smoothRoute(AddNoteScreen(initialNote: initialNote), settings);
      default:
        return _smoothRoute(const NotesListScreen(), settings);
    }
  }

  /// Soft fade + slight slide — every screen change feels buttery.
  static Route<dynamic> _smoothRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
