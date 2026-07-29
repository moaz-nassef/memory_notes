import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';

class BuildToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isRecording;
  final double pulseValue;

  const BuildToolbarButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isRecording = false,
    this.pulseValue = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isRecording ? 0.3 : 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: isRecording ? 0.8 : 0.35),
                width: 1.5,
              ),
              boxShadow:
                  isRecording
                      ? [
                        BoxShadow(
                          color: color.withValues(
                            alpha: 0.45 * (1 - pulseValue),
                          ),
                          blurRadius: 18 + (12 * pulseValue),
                          spreadRadius: 3 * pulseValue,
                        ),
                      ]
                      : null,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
