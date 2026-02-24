import 'package:flutter/material.dart';

class NoteTextField extends StatelessWidget {
  const NoteTextField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 4,
      style: TextStyle(
        fontSize: 20,
        height: 1.8,
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      decoration: InputDecoration(
        hintText: 'Record your thoughts here... 📝',
        hintStyle: TextStyle(
          color: const Color.fromARGB(255, 193, 192, 192),
          fontSize: 15,
        ),
        border: InputBorder.none,
      ),
    );
  }
}
