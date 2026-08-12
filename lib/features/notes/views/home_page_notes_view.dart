import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/features/notes/cubit/notes_state.dart';
import 'package:memory_notes/features/notes/widgets/header.dart';
import 'package:memory_notes/features/notes/widgets/note_card.dart';
import 'package:memory_notes/features/notes/widgets/notes_search_delegate.dart';
import 'package:memory_notes/features/voice_analysis/views/voice_ai_capture_screen.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/effects/aurora_background.dart';
import 'package:memory_notes/shared/effects/bouncy_fab.dart';
import 'package:memory_notes/shared/effects/staggered_fade_slide.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  /// Content stays centered and readable on tablets / desktop windows.
  static const double _maxContentWidth = 720;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: BlocBuilder<NotesCubit, NotesState>(
                builder: (context, state) {
                  return switch (state) {
                    NotesInitial() || NotesLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    NotesError(message: final message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    NotesLoaded(notes: final notes) => _buildNotesList(
                      context,
                      notes,
                    ),
                  };
                },
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Create note with voice AI',
            button: true,
            child: BouncyFab(
              key: const Key('home_voice_ai_note'),
              onPressed: () => _openVoiceAiNote(context),
              icon: Icons.mic_rounded,
              backgroundColor: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          BouncyFab(
            key: const Key('home_new_note'),
            onPressed: () => _openAddNote(context),
            icon: Icons.add_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<NoteModel> notes) {
    return Column(
      children: [
        Header(
          noteCount: notes.length,
          onSearchTap: () => _openSearch(context),
        ),
        Expanded(
          child:
              notes.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return StaggeredFadeSlide(
                        index: index,
                        child: NoteCard(
                          note: note,
                          onTap: () => _openEditNote(context, note),
                          onEdit: () => _openEditNote(context, note),
                          onDelete: () => _confirmDelete(context, note),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder:
                  (context, value, child) =>
                      Transform.scale(scale: value, child: child),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 60,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 60,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'All quiet in here',
              style: theme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your brain\'s external drive is empty.\nTap + to offload a thought.',
              style: theme.bodyLarge?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the full-screen search page; picking a note opens it
  /// in the editor, exactly like tapping it in the list.
  Future<void> _openSearch(BuildContext context) async {
    final selected = await showSearch<NoteModel?>(
      context: context,
      delegate: NotesSearchDelegate(),
    );
    if (selected != null && context.mounted) {
      await _openEditNote(context, selected);
    }
  }

  Future<void> _openAddNote(BuildContext context) async {
    final newNote = await Navigator.pushNamed(context, AppRoutes.addNote);
    if (newNote is NoteModel && context.mounted) {
      await context.read<NotesCubit>().addNote(newNote);
    }
  }

  Future<void> _openVoiceAiNote(BuildContext context) async {
    final newNote = await Navigator.of(context).push<NoteModel>(
      MaterialPageRoute(builder: (_) => const VoiceAiCaptureScreen()),
    );
    if (newNote != null && context.mounted) {
      await context.read<NotesCubit>().addNote(newNote);
    }
  }

  Future<void> _openEditNote(BuildContext context, NoteModel note) async {
    final editedNote = await Navigator.pushNamed(
      context,
      AppRoutes.addNote,
      arguments: note,
    );
    if (editedNote is NoteModel && context.mounted) {
      await context.read<NotesCubit>().updateNote(note, editedNote);
    }
  }

  Future<void> _confirmDelete(BuildContext context, NoteModel note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            title: const Text('Delete note?'),
            content: const Text(
              'This will delete note data and its audio file.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      await context.read<NotesCubit>().deleteNote(note);
    }
  }
}
