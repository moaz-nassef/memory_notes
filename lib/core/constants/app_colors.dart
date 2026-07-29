import 'package:flutter/material.dart';

/// App-wide color palette — a modern, deep-space dark theme with
/// violet as the brand color and soft glass surfaces on top.
class AppColors {
  AppColors._();

  // ── Base / background ──────────────────────────────────────────────
  /// Near-black with a hint of blue — easier on the eyes than #000.
  static const Color scaffoldDark = Color(0xFF0B0B13);
  static const Color backgroundTop = Color(0xFF101018);
  static const Color backgroundBottom = Color(0xFF0B0B13);

  // ── Surfaces (glass layers on top of the background) ───────────────
  static const Color surface = Color(0xFF15151F);
  static const Color surfaceLight = Color(0xFF1D1D2A);

  // ── Brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF7C6CFF);
  static const Color primaryDark = Color(0xFF5B4BE0);
  static const Color accent = Color(0xFF9D8CFF);
  static const Color teal = Color(0xFF4ECDC4);
  static const Color pink = Color(0xFFFF5CA8);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFECA57);

  // ── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5F5FA);
  static const Color textSecondary = Color(0xB3FFFFFF); // white 70%
  static const Color textMuted = Color(0x61FFFFFF); // white 38%

  // ── Lines / borders on glass ───────────────────────────────────────
  static const Color border = Color(0x14FFFFFF); // white 8%
  static const Color borderStrong = Color(0x29FFFFFF); // white 16%

  // ── Brand gradient (buttons, FAB, highlights) ──────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  // ── Note palette (color picker) ────────────────────────────────────
  static const List<Map<String, dynamic>> noteColors = [
    {'color': Color(0xFF7C6CFF), 'name': 'Violet'},
    {'color': Color(0xFFFF6B6B), 'name': 'Coral'},
    {'color': Color(0xFF4ECDC4), 'name': 'Teal'},
    {'color': Color(0xFFFECA57), 'name': 'Amber'},
    {'color': Color(0xFF95E1D3), 'name': 'Mint'},
    {'color': Color(0xFFFF5CA8), 'name': 'Pink'},
    {'color': Color(0xFF2ECC71), 'name': 'Green'},
  ];

  static const Color defaultNoteColor = Color(0xFF7C6CFF);

  // ── Home background gradient ───────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );
}
