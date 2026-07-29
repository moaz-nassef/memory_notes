import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';

class NoteTitleField extends StatelessWidget {
  const NoteTitleField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: AppColors.primary,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      decoration: const InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.textMuted,
        ),
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
    );
  }
}
