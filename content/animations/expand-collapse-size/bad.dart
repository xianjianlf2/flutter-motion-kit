// ❌ Anti-pattern: toggle the body with setState but NO AnimatedSize, so the
// height jumps instantly with no animation. (Compiles and runs — it's just the
// un-animated version this entry is contrasted against.)
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

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
      appBar: AppBar(title: const Text('BAD example')),
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
                  trailing: const Icon(Icons.expand_more),
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                // ❌ No AnimatedSize wrapper → the height snaps instantly.
                if (_expanded)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'This body appears and disappears with no animation at '
                      'all — the panel just jumps between heights.',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
