// ============================================
// 📁 lib/screens/notes_list_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:memory_notes/models/Note_Model.dart';
import 'package:memory_notes/views/Header.dart';
import 'package:memory_notes/views/add_note_screen.dart';
import 'package:memory_notes/views/note_card.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  // ✅ Sample Data
  List<NoteModel> notes = [
    NoteModel(
      id: '1',
      title: 'رحلة إلى البحر',
      text:
          'يوم رائع على الشاطئ مع العائلة. الجو كان مثالي والمياه صافية جداً!',
      imagePath: 'assets/images/download (3).jpg',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      color: Color(0xFF81D4FA),
    ),
    NoteModel(
      id: '2',
      title: 'قائمة التسوق',
      text: 'خبز\nحليب\nبيض\nجبنة\nخضروات\nفواكه',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      color: Color(0xFFA5D6A7),
    ),
    NoteModel(
      id: '3',
      title: 'اجتماع العمل',
      audioPath: 'assets/audio/7447224752172845840.mp3',
      text: 'نقاط مهمة من الاجتماع اليوم',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      color: Color(0xFFCE93D8),
    ),
    NoteModel(
      id: '4',
      imagePath: "assets/images/Screenshot 2026-01-02 025428.png",
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      color: Color(0xFFFFAB91),
    ),
    NoteModel(
      id: '5',
      title: 'أفكار المشروع',
      text:
          'تطبيق ملاحظات مع دعم الصور والصوت والنص. يجب أن يكون التصميم بسيط وسهل الاستخدام.',
      imagePath: 'assets/images/WhatsApp Image 2026-01-06 at 8.20.51 PM.jpeg',
      audioPath: 'assets/audio/7498607310344866576.mp3',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      color: Color(0xFFF48FB1),
    ),
  ];
  void _addNewNote(NoteModel newNote) {
    setState(() {
      notes.insert(0, newNote);
    });
  }

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
              Header(notes: notes),

              // ✅ Notes List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 80),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return NoteCard(
                      note: notes[index],
                      onTap: () {
                        // TODO: Navigate to detail screen
                      },
                      onLongPress: () {
                        // TODO: Show options
                      },
                      onDelete: () {
                        setState(() {
                          notes.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Note deleted ✅'),
                            behavior: SnackBarBehavior.floating,
                          ),
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
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );

          if (newNote != null) {
            _addNewNote(newNote);
          }
        },
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
