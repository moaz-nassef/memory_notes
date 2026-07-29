import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';

/// Shows a floating snackbar with a consistent app style.
///
/// [color] sets the accent of the leading icon — the background stays
/// a dark glass surface so messages never look garish.
void showCustomSnack(
  BuildContext context,
  String message, {
  Color? color,
  IconData? icon,
}) {
  final accent = color ?? AppColors.primary;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.info_outline_rounded,
                color: accent,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
}
