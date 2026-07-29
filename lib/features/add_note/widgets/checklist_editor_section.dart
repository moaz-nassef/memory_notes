import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/models/task_model.dart';

class ChecklistEditorSection extends StatelessWidget {
  const ChecklistEditorSection({
    super.key,
    required this.taskController,
    required this.checklistItems,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onRemoveTask,
  });

  final TextEditingController taskController;
  final List<TaskModel> checklistItems;
  final VoidCallback onAddTask;
  final void Function(int index, bool? value) onToggleTask;
  final void Function(int index) onRemoveTask;

  @override
  Widget build(BuildContext context) {
    final doneCount = checklistItems.where((e) => e.isDone).length;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Checklist',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (checklistItems.isNotEmpty)
                Text(
                  '$doneCount/${checklistItems.length} done',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Add-task row ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  onSubmitted: (_) => onAddTask(),
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a task…',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAddTask,
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Items ────────────────────────────────────────────────
          if (checklistItems.isNotEmpty) const SizedBox(height: 6),
          ...List.generate(checklistItems.length, (index) {
            final item = checklistItems[index];
            return Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: item.isDone,
                      onChanged: (value) => onToggleTask(index, value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            item.isDone
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                        decoration:
                            item.isDone ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onRemoveTask(index),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.textMuted,
                    visualDensity: VisualDensity.compact,
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
