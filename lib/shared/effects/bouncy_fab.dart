import 'package:flutter/material.dart';
import 'package:memory_notes/core/constants/app_colors.dart';

/// A FAB that squishes and wiggles when pressed — pure joy in
/// button form. Drop-in replacement for [FloatingActionButton].
class BouncyFab extends StatefulWidget {
  const BouncyFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color? backgroundColor;

  @override
  State<BouncyFab> createState() => _BouncyFabState();
}

class _BouncyFabState extends State<BouncyFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // NOTE: the curves live *inside* each sequence item — wrapping the
    // whole TweenSequence in Curves.elasticOut would feed it values > 1
    // (elastic overshoot) and trip its `t <= 1.0` assertion.
    //
    // Squish down, then spring back.
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_controller);
    // Little wiggle while it springs back.
    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -0.08,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -0.08,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.backgroundColor ?? AppColors.primary;

    return ScaleTransition(
      scale: _scale,
      child: RotationTransition(
        turns: _rotation,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _handleTap,
            child: Ink(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient:
                    widget.backgroundColor == null
                        ? AppColors.primaryGradient
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.backgroundColor!,
                            widget.backgroundColor!.withValues(alpha: 0.75),
                          ],
                        ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
