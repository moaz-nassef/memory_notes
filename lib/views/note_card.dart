import 'package:flutter/material.dart';
import 'dart:io';
import 'package:memory_notes/models/Note%20Model.dart';
import 'package:memory_notes/views/Audio%20Player%20Widget.dart';

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard>
    with SingleTickerProviderStateMixin {
  bool isPlaying = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.note.color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.note.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.note.color.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Title (if exists)
                  if (widget.note.title != null &&
                      widget.note.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.note.title!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[900],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildTypeIcon(),
                        ],
                      ),
                    ),

                  // ✅ Image (if exists)
                  if (widget.note.imagePath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: Image.network(
                            widget.note.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'صورة',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // ✅ Text (if exists)
                  if (widget.note.text != null && widget.note.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        widget.note.text!,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // ✅ Audio Player (if exists)
                  if (widget.note.audioPath != null)
                    AudioPlayerWidget(note: widget.note),

                  SizedBox(height: 8),

                  // ✅ Date & Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(widget.note.createdAt),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      if (widget.onDelete != null)
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20),
                          color: Colors.red[400],
                          onPressed: widget.onDelete,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Type Icon
  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (widget.note.type) {
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
      default:
        icon = Icons.text_fields_rounded;
        color = Colors.green;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  // ✅ Format Date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';

    return '${date.day}/${date.month}/${date.year}';
  }
}
