import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/manager/audio_recorder_file_helper.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/home/Header.dart';
import 'package:memory_notes/views/home/note_card.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final notesBox = Hive.box<NoteModel>('notesBox');
  final AudioRecorderFileHelper _audioFileHelper = AudioRecorderFileHelper();

  Future<void> _deleteNoteWithAudio(NoteModel note) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(197, 0, 0, 0),
              Color.fromARGB(209, 16, 16, 18),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Header(noteCount: notesBox.values.length),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: notesBox.listenable(),
                  builder: (context, Box<NoteModel> box, _) {
                    final notes = box.values.toList();

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return NoteCard(
                          note: notes[index],
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete note?'),
                                content: const Text(
                                  'This will delete note data and its audio file.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _deleteNoteWithAudio(notes[index]);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.pushNamed(
            context,
            AppRoutes.addNote,
          );

          if (newNote != null) {
            await notesBox.add(newNote as NoteModel);
          }
        },
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
