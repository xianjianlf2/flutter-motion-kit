// ✅ Recommended: each row has a unique Key, confirmDismiss guards the action,
// background + secondaryBackground match both swipe directions, and onDismissed
// removes the item from the data source.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const _Demo(),
  );
}

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

  Future<bool> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('This message will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    // ✅ Dialog can be dismissed by tapping outside → treat null as "cancel".
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe to dismiss')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Dismissible(
            // ✅ Unique, identity-based key — not the index.
            key: ValueKey<String>(item),
            // ✅ Ask before the destructive removal actually happens.
            confirmDismiss: (direction) => _confirm(context),
            // ✅ Remove from the data source so the widget leaves the tree.
            onDismissed: (direction) {
              setState(() => _items.removeAt(index));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Dismissed $item')));
            },
            background: const ColoredBox(
              color: Colors.green,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(Icons.archive, color: Colors.white),
                ),
              ),
            ),
            secondaryBackground: const ColoredBox(
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.message),
              title: Text(item),
            ),
          );
        },
      ),
    );
  }
}
