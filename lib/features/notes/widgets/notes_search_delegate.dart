import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/features/notes/cubit/notes_state.dart';
import 'package:memory_notes/features/notes/data/notes_search.dart';
import 'package:memory_notes/features/notes/widgets/note_card.dart';
import 'package:memory_notes/models/note_model.dart';

/// Full-screen search page opened from the header search icon.
///
/// Shows live results while typing (titles, body text and checklist
/// items are searched) and returns the selected note via [close].
class NotesSearchDelegate extends SearchDelegate<NoteModel?> {
  @override
  String get searchFieldLabel => 'Search notes…';

  /// Keep the search page on the app's dark glass theme.
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: AppColors.scaffoldDark,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 18),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: Color(0x557C6CFF),
        selectionHandleColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      color: AppColors.textSecondary,
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.close_rounded),
          color: AppColors.textSecondary,
          tooltip: 'Clear',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) => _SearchResults(
    query: query,
    onNoteSelected: (note) => close(context, note),
  );

  // Suggestions == results: the list updates live on every keystroke.
  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(
    query: query,
    onNoteSelected: (note) => close(context, note),
  );
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.query, required this.onNoteSelected});

  final String query;
  final ValueChanged<NoteModel> onNoteSelected;

  @override
  Widget build(BuildContext context) {
    if (normalizeSearchText(query).isEmpty) {
      return const _SearchHint();
    }

    return BlocBuilder<NotesCubit, NotesState>(
      builder: (context, state) {
        if (state is! NotesLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = filterNotes(state.notes, query);
        if (results.isEmpty) {
          return _NoResults(query: query);
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final note = results[index];
            return NoteCard(note: note, onTap: () => onNoteSelected(note));
          },
        );
      },
    );
  }
}

/// Friendly placeholder shown before the user types anything.
class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 52,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search your memory',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Type words from a title, note text,\nor a checklist item.',
              style: TextStyle(color: AppColors.textMuted, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when nothing matches the query.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 52,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No matches for "$query"',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try different or fewer words.',
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
