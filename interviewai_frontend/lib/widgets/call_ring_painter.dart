// lib/widgets/call_ring_painter.dart
import 'package:flutter/material.dart';

class CallRingPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  CallRingPainter({required this.animation, this.color = Colors.white})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 1.0 - animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + (animation.value * 3.0);

    canvas.drawCircle(center, maxRadius * animation.value, paint);
  }

  @override
  bool shouldRepaint(covariant CallRingPainter oldDelegate) {
    return false;
  }
}
