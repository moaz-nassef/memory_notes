import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  const FloatingButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class FloatingDialAction {
  const FloatingDialAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class FloatingSpeedDial extends StatelessWidget {
  const FloatingSpeedDial({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.mainColor,
    required this.actions,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final Color mainColor;
  final List<FloatingDialAction> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...actions.map((action) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                isOpen
                    ? Padding(
                      key: ValueKey(action.icon),
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FloatingButton(
                        icon: action.icon,
                        color: action.color,
                        onTap: action.onTap,
                      ),
                    )
                    : const SizedBox.shrink(),
          );
        }),
        FloatingButton(
          icon: isOpen ? Icons.close_rounded : Icons.add_rounded,
          color: mainColor,
          onTap: onToggle,
        ),
      ],
    );
  }
}
