// ❌ Anti-pattern: onDismissed never removes the item from the data source, and
// the key is the list index instead of the item's identity. At runtime Flutter
// throws "A dismissed Dismissible widget is still part of the tree" because the
// next build keeps producing the same widget, and index keys retarget the wrong
// row once items shift. (Dismissible.key is required, so it must be present to
// compile — but an index key is still the classic mistake.)
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final List<String> _items = List<String>.generate(
    8,
    (i) => 'Message ${i + 1}',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Dismissible(
            // ❌ Index key, not identity — wrong row after items shift.
            key: ValueKey<int>(index),
            onDismissed: (direction) {
              // ❌ Nothing removed → widget stays in the tree → assertion.
            },
            background: const ColoredBox(color: Colors.red),
            child: ListTile(title: Text(_items[index])),
          );
        },
      ),
    );
  }
}
