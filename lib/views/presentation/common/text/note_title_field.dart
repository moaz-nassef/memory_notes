import 'package:flutter/material.dart';

class NoteTitleField extends StatelessWidget {
  const NoteTitleField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        fillColor: Colors.white.withValues(alpha: 0.009),
        filled: true,
        hintText: '✨ title...',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontWeight: FontWeight.w600,
        ),
        border: InputBorder.none,
      ),
    );
  }
}

