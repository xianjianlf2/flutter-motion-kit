// ❌ Anti-pattern: the child has no Key.
// AnimatedSwitcher thinks it's the same Text widget before and after, just with changed parameters ->
// the number jumps instantly, with no transition animation at all.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            '$_count', // ❌ no key -> the swap animation never triggers
            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
