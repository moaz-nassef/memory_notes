import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/shared/audio/audio_player_widget.dart';
import 'package:memory_notes/shared/checklist/build_checklist_widget.dart';
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
    final noteColor = Color(note.color);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: noteColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: noteColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: color dot, title, type icon ──────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        color: noteColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: noteColor.withValues(alpha: 0.6),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.25,
                          color:
                              note.title.isEmpty
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildTypeIcon(),
                  ],
                ),

                // ── Images ───────────────────────────────────────────
                if (note.imagePaths != null && note.imagePaths!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: CustomImage(note: note),
                  ),

                // ── Text ─────────────────────────────────────────────
                if (note.text != null && note.text!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      note.text!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                // ── Audio recordings (a note can hold several) ───────
                for (var i = 0; i < note.allAudioPaths.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AudioPlayerWidget(
                      audioPath: note.allAudioPaths[i],
                      audioDurationMs: note.allAudioDurationsMs[i],
                    ),
                  ),

                // ── Checklist ────────────────────────────────────────
                if (note.checklist != null && note.checklist!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ChecklistPreview(note: note),
                  ),

                const SizedBox(height: 14),

                // ── Footer (date + actions) ──────────────────────────
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM d, yyyy · HH:mm').format(note.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    if (onEdit != null)
                      _ActionButton(
                        icon: Icons.edit_rounded,
                        color: AppColors.teal,
                        onPressed: onEdit!,
                      ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: AppColors.error,
                        onPressed: onDelete!,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Type Icon
  Widget _buildTypeIcon() {
    final (icon, color) = switch (note.type) {
      NoteType.image => (Icons.image_rounded, AppColors.teal),
      NoteType.audio => (Icons.audiotrack_rounded, AppColors.pink),
      NoteType.mixed => (Icons.dashboard_rounded, AppColors.warning),
      NoteType.checklist => (Icons.checklist_rounded, AppColors.success),
      _ => (Icons.notes_rounded, AppColors.accent),
    };

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }
}

/// Small, soft-toned icon button for card actions.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
