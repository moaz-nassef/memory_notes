import 'package:flutter/material.dart';

class NoteTextField extends StatelessWidget {
  const NoteTextField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 8,
      style: TextStyle(
        fontSize: 16,
        height: 1.8,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        hintText: 'Record your thoughts here... 📝',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 15,
        ),
        border: InputBorder.none,
      ),
    );
  }
}

