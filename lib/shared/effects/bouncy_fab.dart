import 'package:flutter/material.dart';

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

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    // Squish down, then spring back.
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1), weight: 70),
    ]).animate(curved);
    // Little wiggle while it springs back.
    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -0.08), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -0.08, end: 0), weight: 70),
    ]).animate(curved);
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
    return ScaleTransition(
      scale: _scale,
      child: RotationTransition(
        turns: _rotation,
        child: FloatingActionButton(
          onPressed: _handleTap,
          backgroundColor: widget.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(widget.icon),
        ),
      ),
    );
  }
}
