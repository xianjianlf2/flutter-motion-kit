// ❌ Anti-pattern: removing straight from the data list with setState and never
// calling AnimatedListState.removeItem. The row vanishes with no exit animation,
// and because the AnimatedList's internal item count is never decremented its
// indices drift out of sync with the data (RangeError / wrong row on the next op).
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  final List<String> _items = ['Apple', 'Banana', 'Cherry'];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  void _remove(int index) {
    // ❌ Mutates the data and rebuilds, but never tells the AnimatedList.
    // No SizeTransition/FadeTransition runs and the item count desyncs.
    setState(() => _items.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) =>
            ListTile(title: Text(_items[index]), onTap: () => _remove(index)),
      ),
    );
  }
}
