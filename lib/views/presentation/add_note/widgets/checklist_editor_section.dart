import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Checklist',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: taskController,
                  onSubmitted: (_) => onAddTask(),
                  decoration: InputDecoration(
                    hintText: 'Add task...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAddTask,
                icon: const Icon(Icons.add_circle_rounded),
              ),
            ],
          ),
          if (checklistItems.isNotEmpty) const SizedBox(height: 10),
          ...List.generate(checklistItems.length, (index) {
            final item = checklistItems[index];
            return Row(
              children: [
                Checkbox(
                  value: item.isDone,
                  onChanged: (value) => onToggleTask(index, value),
                ),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemoveTask(index),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
