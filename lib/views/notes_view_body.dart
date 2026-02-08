import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/NoteItem.dart';

import 'custom_app_bar.dart';
// import 'note_item.dart';
// import 'notes_list_view.dart';

class NotesViewBody extends StatelessWidget {
  const NotesViewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notes = [
      NoteModel(
        title: "رحلة إلى البحر",
        color: Color.fromARGB(169, 129, 212, 250).value,
        text: "ذكرى حلوة من السفر",
        createdAt: DateTime.now(),
      ),

      NoteModel(
        title: "قائمة التسوق",
        color: Color.fromARGB(166, 165, 214, 167).value,
        imagePath: "assets/images/Screenshot 2026-01-02 025428.png",
        createdAt: DateTime.now(),
      ),

      NoteModel(
        title: "اجتماع العمل",
        color: Color.fromARGB(168, 206, 147, 216).value,
        text: "صوت ماما",
        audioPath: "assets/audio/7447224752172845840.mp3",
        createdAt: DateTime.now(),
      ),

      NoteModel(
        title: "شوب اونلاين",
        color: Color.fromARGB(161, 255, 171, 145).value,
        text: "يوم مهم",
        imagePath: "assets/images/download (3).jpg",
        audioPath: "assets/audio/7498607310344866576.mp3",
        createdAt: DateTime.now(),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 50),
          CustomAppBar(),
          Expanded(child: NotesListView(notes: notes)),
        ],
      ),
    );
  }
}

class NotesListView extends StatelessWidget {
  final List<NoteModel> notes;

  const NotesListView({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: NoteItem(note: notes[index]),
        );
      },
    );
  }
}
