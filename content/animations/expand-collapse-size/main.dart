// ✅ Recommended: pure implicit expand/collapse with AnimatedSize. No manual
// controller, no measuring — it tweens to the body's intrinsic height.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
    home: const _Demo(),
  );
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
      appBar: AppBar(title: const Text('Expand / collapse')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('What is AnimatedSize?'),
                  trailing: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.expand_more),
                  ),
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                // ✅ AnimatedSize tweens between zero-height and the body's
                // intrinsic height. No vsync argument — it uses the context.
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            'AnimatedSize automatically animates its own size '
                            'to whatever its child reports. Because the body '
                            'here has an intrinsic height we never have to '
                            'measure or hard-code it — toggling the child is '
                            'enough to drive a smooth expand/collapse.',
                          ),
                        )
                      // Collapsed: an empty, zero-height box.
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
