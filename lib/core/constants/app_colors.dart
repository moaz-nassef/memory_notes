import 'package:flutter/material.dart';

/// App-wide color palette.
class AppColors {
  AppColors._();

  // ── Base / background ──────────────────────────────────────────────
  static const Color backgroundTop = Color.fromARGB(197, 0, 0, 0);
  static const Color backgroundBottom = Color.fromARGB(209, 16, 16, 18);
  static const Color scaffoldDark = Color.fromARGB(255, 5, 5, 5);

  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primary = Colors.deepPurple;
  static const Color accent = Colors.purple;
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;

  // ── Note palette (color picker) ────────────────────────────────────
  static const List<Map<String, dynamic>> noteColors = [
    {'color': Color(0xFF667EEA), 'name': 'Purple'},
    {'color': Color(0xFFFF6B6B), 'name': 'Red'},
    {'color': Color(0xFF4ECDC4), 'name': 'Turquoise'},
    {'color': Color(0xFFFECA57), 'name': 'Yellow'},
    {'color': Color(0xFF95E1D3), 'name': 'Mint'},
    {'color': Color(0xFFEE5A6F), 'name': 'Pink'},
    {'color': Color(0xFF2ECC71), 'name': 'Green'},
  ];

  static const Color defaultNoteColor = Color(0xFF667EEA);

  // ── Home background gradient ───────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );
}
