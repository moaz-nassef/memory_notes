import 'package:flutter/material.dart';

/// Text with a gradient that slowly sweeps across it — a shimmer
/// effect for headlines.
class AnimatedGradientText extends StatefulWidget {
  const AnimatedGradientText(
    this.text, {
    super.key,
    required this.style,
    this.colors = const [
      Color(0xFFB388FF),
      Color(0xFF7C4DFF),
      Color(0xFF40C4FF),
      Color(0xFFB388FF),
    ],
  });

  final String text;
  final TextStyle style;
  final List<Color> colors;

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback:
              (bounds) => LinearGradient(
                colors: widget.colors,
                tileMode: TileMode.mirror,
                transform: _SlidingGradient(_controller.value),
              ).createShader(bounds),
          child: child,
        );
      },
      child: Text(widget.text, style: widget.style),
    );
  }
}

/// Slides the gradient horizontally as [t] goes from 0 → 1.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.t);

  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
  }
}
