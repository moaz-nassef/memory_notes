import 'package:flutter/material.dart';
import 'package:memory_notes/models/Note%20Model.dart';

class NoteItem extends StatelessWidget {
  final NoteModel note;

  const NoteItem({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TEXT
            if (note.text != null)
              Text(note.text!, style: const TextStyle(fontSize: 16)),

            // IMAGE
            if (note.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    note.imagePath!,
                    // Image.file(
                    //   File(note.imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // AUDIO
            if (note.audioPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: const [Icon(Icons.play_arrow), Text("تشغيل الصوت")],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
