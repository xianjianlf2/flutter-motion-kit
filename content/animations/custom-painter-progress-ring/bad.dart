// ❌ Anti-pattern: shouldRepaint returns true (repaints on every parent
// rebuild) and a fresh Paint is allocated inside paint() every frame.
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          // ❌ A new painter is built every frame, with no super(repaint:).
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) =>
                CustomPaint(painter: _RingPainter(_controller.value)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value); // ❌ no super(repaint:)

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    // ❌ Paint allocated on every frame → GC churn at 60fps.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = Colors.teal;
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - 14) / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      paint,
    );
  }

  // ❌ Always returns true → repaints on every parent rebuild, wasting CPU.
  @override
  bool shouldRepaint(_RingPainter oldDelegate) => true;
}
