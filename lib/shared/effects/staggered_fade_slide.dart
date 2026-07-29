import 'package:flutter/material.dart';

/// Fades + slides its child in, delayed by [index] — wrapping list
/// items in this gives a cascading "staggered" entrance.
class StaggeredFadeSlide extends StatefulWidget {
  const StaggeredFadeSlide({
    super.key,
    required this.index,
    required this.child,
    this.stepDelay = const Duration(milliseconds: 70),
    this.maxDelay = const Duration(milliseconds: 600),
  });

  /// Position in the list — later items start later.
  final int index;
  final Widget child;

  /// Delay between consecutive items.
  final Duration stepDelay;

  /// Cap so items far down the list don't wait forever.
  final Duration maxDelay;

  @override
  State<StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curve);

    final delay = widget.stepDelay * widget.index;
    Future.delayed(delay > widget.maxDelay ? widget.maxDelay : delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
