import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';

class NoteTextField extends StatelessWidget {
  const NoteTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 4,
      cursorColor: AppColors.primary,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 16,
        height: 1.7,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        hintText: 'Start writing…',
        hintStyle: TextStyle(fontSize: 16, color: AppColors.textMuted),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }
}
