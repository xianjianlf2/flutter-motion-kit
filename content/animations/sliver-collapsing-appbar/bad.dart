// ❌ Anti-pattern: a plain AppBar + ListView with no sliver protocol, so the header
// never collapses or parallaxes. (A real SliverAppBar dropped into a Column/ListView
// would throw — here we show the equally-wrong "static bar that just doesn't collapse".)
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatelessWidget {
  const _Demo();

  static const _items = [
    'Overview',
    'Activity',
    'Photos',
    'Files',
    'Members',
    'Settings',
    'Billing',
    'Integrations',
    'Notifications',
    'Security',
    'Advanced',
    'About',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ❌ A fixed-height AppBar: it can never expand, collapse, or parallax on scroll.
      appBar: AppBar(title: const Text('Header (never collapses)')),
      body: Column(
        children: [
          // ❌ A static "hero" banner that scrolls with nothing and never shrinks.
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F51B5), Color(0xFF7E57C2)],
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'No parallax, no collapse',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // ❌ A nested ListView that owns a separate scroll, disconnected from the header.
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
