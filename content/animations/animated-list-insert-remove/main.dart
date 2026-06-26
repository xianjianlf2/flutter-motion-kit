// ✅ Recommended: AnimatedList + GlobalKey<AnimatedListState>, the backing list
// kept in lockstep, and a remove builder that animates the captured item out.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const _Demo(),
  );
}

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  // The single source of truth that must stay in lockstep with the AnimatedList.
  final List<String> _items = ['Apple', 'Banana', 'Cherry'];

  // ✅ The key is the only handle to insertItem / removeItem.
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  int _counter = 3;

  void _add() {
    final index = _items.length; // append at the end
    _items.insert(index, 'Item ${++_counter}'); // ✅ mutate data first
    _listKey.currentState!.insertItem(
      index,
      duration: const Duration(milliseconds: 350),
    ); // ✅ then animate the same index in
  }

  void _remove(int index) {
    // ✅ Capture the value BEFORE mutating, so the exit builder shows the
    // item that actually left — not the one that shifts into its place.
    final removed = _items.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => _tile(removed, animation, onTap: null),
      duration: const Duration(milliseconds: 300),
    );
  }

  // Shared row, reused for both the live list and the exit animation.
  Widget _tile(
    String label,
    Animation<double> animation, {
    required VoidCallback? onTap,
  }) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(label),
            trailing: onTap == null ? null : const Icon(Icons.close),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AnimatedList insert & remove')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.add),
      ),
      body: AnimatedList(
        key: _listKey,
        // ✅ Must equal the backing list length on first build.
        initialItemCount: _items.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index, animation) =>
            _tile(_items[index], animation, onTap: () => _remove(index)),
      ),
    );
  }
}
