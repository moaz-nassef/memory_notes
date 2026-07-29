import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/features/notes/cubit/notes_cubit.dart';
import 'package:memory_notes/features/notes/cubit/notes_state.dart';
import 'package:memory_notes/features/notes/widgets/header.dart';
import 'package:memory_notes/features/notes/widgets/note_card.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/effects/aurora_background.dart';
import 'package:memory_notes/shared/effects/bouncy_fab.dart';
import 'package:memory_notes/shared/effects/staggered_fade_slide.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              return switch (state) {
                NotesInitial() || NotesLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                NotesError(message: final message) => Center(
                  child: Text(message),
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
      floatingActionButton: BouncyFab(
        onPressed: () => _openAddNote(context),
        backgroundColor: AppColors.primary,
        icon: Icons.add_rounded,
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<NoteModel> notes) {
    return Column(
      children: [
        Header(noteCount: notes.length),
        Expanded(
          child:
              notes.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return StaggeredFadeSlide(
                        index: index,
                        child: NoteCard(
                          note: note,
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
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All quiet in here',
              style: theme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your brain\'s external drive is empty.\nTap + to offload a thought.',
              style: theme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddNote(BuildContext context) async {
    final newNote = await Navigator.pushNamed(context, AppRoutes.addNote);
    if (newNote is NoteModel && context.mounted) {
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
            title: const Text('Delete note?'),
            content: const Text(
              'This will delete note data and its audio file.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
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
