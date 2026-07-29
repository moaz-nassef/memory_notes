import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/models/note_model.dart';

class ChecklistPreview extends StatefulWidget {
  final NoteModel note;

  const ChecklistPreview({super.key, required this.note});

  @override
  State<ChecklistPreview> createState() => _ChecklistPreviewState();
}

class _ChecklistPreviewState extends State<ChecklistPreview> {
  Future<void> _toggleItem(int index, bool? value) async {
    final list = widget.note.checklist;
    if (list == null) return;

    list[index].isDone = value ?? false;

    setState(() {});
    await widget.note.save();
  }

  @override
  Widget build(BuildContext context) {
    final checklist = widget.note.checklist ?? [];

    if (checklist.isEmpty) {
      return const SizedBox.shrink();
    }

    final doneCount = checklist.where((e) => e.isDone).length;
    final progress = doneCount / checklist.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.checklist_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$doneCount/${checklist.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
          const SizedBox(height: 8),

          ...List.generate(checklist.length, (index) {
            final item = checklist[index];

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: item.isDone,
                      visualDensity: VisualDensity.compact,
                      activeColor: AppColors.success,
                      onChanged: (v) => _toggleItem(index, v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        color:
                            item.isDone
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                        decoration:
                            item.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
