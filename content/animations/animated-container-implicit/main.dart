// ✅ Recommended: use an implicit animation for simple property transitions — zero controllers, zero dispose burden.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const _Demo(),
    );
  }
}

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            // Key idea: just declare the "target state"; the framework handles the tween.
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: _expanded ? 240 : 120,
            height: _expanded ? 240 : 120,
            decoration: BoxDecoration(
              color: _expanded ? Colors.indigo : Colors.indigo.shade200,
              borderRadius: BorderRadius.circular(_expanded ? 32 : 12),
            ),
            alignment: Alignment.center,
            child: const Text('Tap me', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
