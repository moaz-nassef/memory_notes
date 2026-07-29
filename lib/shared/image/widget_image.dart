import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/image/note_image_preview.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({super.key, required this.note});
  final NoteModel note;

  @override
  Widget build(BuildContext context) {
    if (note.imagePaths == null || note.imagePaths!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NoteImagesSlideshow(
        images: note.imagePaths!,
        shadowColor: Color(note.color),
        onRemove: null,
      ),
    );
  }
}
