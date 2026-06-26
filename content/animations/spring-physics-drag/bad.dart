// ❌ Anti-pattern: spring back with a fixed-duration CurvedAnimation Tween that
// throws away the release velocity, and never dispose() the controller.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  // ❌ A fixed duration — the motion always takes 400ms regardless of the fling.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _dragAlignment = _animation.value);
    });
  }

  // ❌ No dispose() — the Ticker held by the controller leaks.

  void _springBack() {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ).chain(CurveTween(curve: Curves.easeOut)),
    );
    _controller
      ..reset()
      ..forward(); // ❌ velocity is discarded — the spring-back feels detached.
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: GestureDetector(
        onPanDown: (_) => _controller.stop(),
        onPanUpdate: (details) {
          setState(() {
            _dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            );
          });
        },
        onPanEnd: (_) => _springBack(), // ❌ details.velocity ignored entirely
        child: Align(
          alignment: _dragAlignment,
          child: Container(
            width: 120,
            height: 120,
            color: Colors.indigo,
            child: const Center(
              child: Text('Drag me', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }
}
