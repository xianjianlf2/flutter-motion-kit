// ❌ Anti-pattern: hand-rolling an AnimationController for a trivial transition.
// Problems: ① twice the code ② easy to forget dispose and leak the ticker (intentionally leaked here)
//      ③ listening via setState rebuilds everything every frame. An implicit animation replaces all of this in one line.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..addListener(() => setState(() {})); // ❌ setState every frame

  // ❌ Deliberately no dispose() — in a real project this is a ticker / memory leak

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOutCubic.transform(_c.value);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _c.isCompleted ? _c.reverse() : _c.forward(),
          child: Container(
            width: 120 + 120 * t,
            height: 120 + 120 * t,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.indigo.shade200, Colors.indigo, t),
              borderRadius: BorderRadius.circular(12 + 20 * t),
            ),
          ),
        ),
      ),
    );
  }
}
