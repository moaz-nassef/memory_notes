import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A living background: soft, blurred color blobs that drift around
/// slowly, like a northern-lights effect behind the content.
///
/// Cheap to render — one [CustomPaint] with 3 blurred circles,
/// repainted by a single [AnimationController].
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key, required this.child, this.colors});

  final Widget child;

  /// Blob colors. Defaults to a purple/teal/pink aurora.
  final List<Color>? colors;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors =
        widget.colors ??
        const [Color(0xFF7C4DFF), Color(0xFF00E5FF), Color(0xFFFF5CA8)];

    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(
          animation: _controller,
          colors: colors,
          baseColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: widget.child,
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.animation,
    required this.colors,
    required this.baseColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<Color> colors;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Base wash.
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    final t = animation.value * 2 * math.pi;

    for (var i = 0; i < colors.length; i++) {
      // Each blob follows its own lazy orbit.
      final phase = t + i * (2 * math.pi / colors.length);
      final center = Offset(
        size.width * (0.5 + 0.38 * math.sin(phase * 0.7 + i)),
        size.height * (0.35 + 0.3 * math.cos(phase * 0.5 + i * 2)),
      );
      final radius = size.shortestSide * (0.55 + 0.1 * math.sin(phase));

      final paint =
          Paint()
            ..color = colors[i].withValues(alpha: 0.16)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.colors != colors || oldDelegate.baseColor != baseColor;
}
