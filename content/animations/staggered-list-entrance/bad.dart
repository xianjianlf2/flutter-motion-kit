// ❌ Anti-pattern: setState in the listener rebuilds everything + AnimatedBuilder without a child + missing dispose.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  static const _items = [
    'Inbox',
    'Drafts',
    'Sent',
    'Starred',
    'Archive',
    'Trash'
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )
    ..addListener(
        () => setState(() {})) // ❌ setState every frame rebuilds the whole page
    ..forward();

  // ❌ No dispose() — the Ticker leaks

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final v = _controller.value;
          // ❌ the subtree (ListTile) is rebuilt on every frame
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - v)),
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}
