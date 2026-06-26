// ✅ Recommended: AnimationController + AnimatedBuilder + Transform with a real
// perspective term, the back face counter-rotated, and proper dispose().
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const _Demo(),
  );
}

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

// Single controller → SingleTickerProviderStateMixin
class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  void _toggle() {
    // Flip toward whichever face is currently hidden.
    if (_controller.value < 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ release the Ticker to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D card flip')),
      body: Center(
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // 0 → 0.5 shows the front, 0.5 → 1 shows the back.
              final angle = _controller.value * pi;
              final showFront = _controller.value < 0.5;
              return Transform(
                alignment: Alignment.center, // ✅ flip about the card's center
                // ✅ perspective term gives the rotation real depth
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY(angle),
                child: showFront
                    ? const _CardFace(
                        color: Colors.indigo,
                        label: 'FRONT',
                        icon: Icons.credit_card,
                      )
                    // ✅ counter-rotate the back so its content isn't mirrored
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: const _CardFace(
                          color: Colors.teal,
                          label: 'BACK',
                          icon: Icons.qr_code_2,
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.color,
    required this.label,
    required this.icon,
  });

  final Color color;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
