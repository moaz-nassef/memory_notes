import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/presentation/checList/build_Checklist_widget.dart';
import 'package:memory_notes/views/presentation/common/audio/Audio%20Player%20Widget.dart';
import 'package:memory_notes/views/presentation/common/image/widget%20image.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(note.color).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(note.color).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title != null && note.title!.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title!,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildTypeIcon(),
                  ],
                ),

              const SizedBox(height: 8),

              //  Images
              if (note.imagePaths != null && note.imagePaths!.isNotEmpty)
                customImage(note: note),

              //  Text
              if (note.text != null && note.text!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    note.text!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),

              //  Audio
              if (note.audioPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AudioPlayerWidget(note: note),
                ),

              //  Checklist
              if (note.checklist != null &&
                      note.checklist!.isNotEmpty)
                    ChecklistPreview(note: note),
              const SizedBox(height: 12),

              //  Footer (Date + Actions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // _formatDate(note.createdAt),
                    DateFormat('yyyy/MM/dd – kk:mm').format(note.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 224, 224, 224),
                    ),
                  ),
                  Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit_rounded),
                          onPressed: onEdit,
                          color: Colors.greenAccent,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Type Icon
  Widget _buildTypeIcon() {
    late IconData icon;
    late Color color;

    switch (note.type) {
      case NoteType.image:
        icon = Icons.image_rounded;
        color = Colors.blue;
        break;
      case NoteType.audio:
        icon = Icons.audiotrack_rounded;
        color = Colors.purple;
        break;
      case NoteType.mixed:
        icon = Icons.view_module_rounded;
        color = Colors.orange;
        break;
      case NoteType.checklist:
        icon = Icons.checklist_rounded;
        color = Colors.teal;
        break;
      default:
        icon = Icons.text_fields_rounded;
        color = Colors.green;
    }


    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
  
  // 🔹 Date Formatter
  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}
