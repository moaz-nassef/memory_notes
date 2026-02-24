import 'package:flutter/material.dart';

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
    // ✅ TOOLBAR BUTTON WIDGET
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow:
                  isRecording
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.4 * (1 - pulseValue)),
                          blurRadius: 15 + (10 * pulseValue),
                          spreadRadius: 3 * pulseValue,
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
