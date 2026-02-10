import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:memory_notes/app_router.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/Header.dart';
import 'package:memory_notes/views/note_card.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {


  final notesBox = Hive.box<NoteModel>('notesBox');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(197, 45, 48, 53),
              Color.fromARGB(209, 175, 182, 221),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Header(noteCount: notesBox.values.length),

              // ✅ Notes List
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: notesBox.listenable(),
                  builder: (context, Box<NoteModel> box, _) {
                    final notes = box.values.toList();

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 80),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return NoteCard(
                          note: notes[index],
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: Text('حذف الملاحظة؟'),
                                    content: Text('هل أنت متأكد؟'),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: Text('إلغاء'),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: Text('حذف'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              await notes[index].delete();
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
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
