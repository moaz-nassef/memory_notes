import 'package:flutter/material.dart';
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rounded, size: 18, color: Colors.teal[200]),
              const SizedBox(width: 6),
              Text(
                'Tasks',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const Spacer(),
              Text(
                '$doneCount/${checklist.length}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ...List.generate(checklist.length, (index) {
            final item = checklist[index];

            return Row(
              children: [
                Checkbox(
                  value: item.isDone,
                  visualDensity: VisualDensity.compact,
                  activeColor: Colors.teal,
                  onChanged: (v) => _toggleItem(index, v),
                ),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      color: item.isDone ? Colors.grey[600] : Colors.grey[900],
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
