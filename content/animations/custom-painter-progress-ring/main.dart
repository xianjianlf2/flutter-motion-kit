// ✅ Recommended: repaint off the animation via super(repaint:), cache the
// Paint objects, and stroke an open ring with drawArc starting at 12 o'clock.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const _Demo(),
  );
}

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

// Single controller → SingleTickerProviderStateMixin.
class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose(); // ✅ release the Ticker to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter progress ring')),
      body: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: CustomPaint(
            // The painter listens to the controller itself, so the whole
            // CustomPaint subtree above it never rebuilds per frame.
            painter: _RingPainter(
              progress: _controller,
              arcColor: scheme.primary,
              trackColor: scheme.surfaceContainerHighest,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
  }) : super(repaint: progress); // ✅ repaint on each tick, not on rebuilds

  final Animation<double> progress;
  final Color arcColor;
  final Color trackColor;

  static const double _stroke = 14;

  // ✅ Paint cached as fields and mutated per frame — no per-frame allocation.
  final Paint _trackPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  // ✅ Rounded, anti-aliased ends for a smooth ring.
  final Paint _arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = _stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - _stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    _trackPaint.color = trackColor;
    canvas.drawCircle(center, radius, _trackPaint);

    _arcPaint.color = arcColor;
    const startAngle = -math.pi / 2; // ✅ -pi/2 → start at 12 o'clock
    final sweepAngle = 2 * math.pi * progress.value;
    // useCenter:false → an open ring stroke, not a filled pie wedge.
    canvas.drawArc(rect, startAngle, sweepAngle, false, _arcPaint);
  }

  // ✅ Only repaint when the configuration changes; the animation drives ticks.
  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.arcColor != arcColor || oldDelegate.trackColor != trackColor;
}
