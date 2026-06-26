// ❌ Anti-pattern: a flat rotateY with NO perspective term, and the back face
// left mirrored. The "card" just squashes horizontally and the back text reads
// backwards. (Compiles and runs — it just looks wrong.)
import 'dart:math';

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
    duration: const Duration(milliseconds: 500),
  );

  void _toggle() {
    if (_controller.value < 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  // ❌ No dispose() — the Ticker leaks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: Center(
        child: GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final angle = _controller.value * pi;
              return Transform(
                alignment: Alignment.center,
                // ❌ no setEntry(3, 2, ...) → no depth, just a flat squash
                transform: Matrix4.rotationY(angle),
                // ❌ back face never counter-rotated → its text stays mirrored
                child: Container(
                  width: 220,
                  height: 140,
                  alignment: Alignment.center,
                  color: Colors.indigo,
                  child: const Text(
                    'FLIP ME',
                    style: TextStyle(color: Colors.white, fontSize: 22),
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
