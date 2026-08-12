import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';
import 'package:memory_notes/shared/effects/animated_gradient_text.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.noteCount, required this.onSearchTap});

  final int noteCount;

  /// Called when the search icon is tapped.
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedGradientText(
                'memorys',
                style:
                    Theme.of(context).textTheme.headlineMedium ??
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          _GlassIconButton(icon: Icons.search_rounded, onPressed: onSearchTap),
        ],
      ),
    );
  }
}

/// A soft, frosted circular icon button used in app headers.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 22, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
