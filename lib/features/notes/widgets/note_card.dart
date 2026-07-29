import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/checklist/build_checklist_widget.dart';
import 'package:memory_notes/shared/audio/audio_player_widget.dart';
import 'package:intl/intl.dart';
import 'package:memory_notes/shared/image/widget_image.dart';

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
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(note.color).withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(note.color).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
              if (note.title.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
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
                CustomImage(note: note),

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
              const SizedBox(height: 8),

              //  Audio recordings (a note can hold several)
              for (var i = 0; i < note.allAudioPaths.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AudioPlayerWidget(
                    audioPath: note.allAudioPaths[i],
                    audioDurationMs: note.allAudioDurationsMs[i],
                  ),
                ),
              const SizedBox(height: 14),

              //  Checklist
              if (note.checklist != null && note.checklist!.isNotEmpty)
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
