import 'dart:math' as math;

import 'package:flutter/material.dart';

class GradientCircularProgressIndicator extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const GradientCircularProgressIndicator({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  @override
  State<GradientCircularProgressIndicator> createState() =>
      _GradientCircularProgressIndicatorState();
}

class _GradientCircularProgressIndicatorState
    extends State<GradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _GradientCircularProgressPainter(
            strokeWidth: widget.strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _GradientCircularProgressPainter extends CustomPainter {
  final double strokeWidth;

  _GradientCircularProgressPainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = SweepGradient(
      colors: const [
        Color(0xFF5C16FF), // основной цвет
        Colors.white,      // кончик
        Color(0xFF5C16FF), // возврат к начальному (чтобы замкнуть)
      ],
      stops: const [0.0, 0.9, 1.0],
      transform: GradientRotation(-math.pi / 2), // начало сверху
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt; // без скругления — иначе будет утолщение на стыке

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi, // полный круг
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}