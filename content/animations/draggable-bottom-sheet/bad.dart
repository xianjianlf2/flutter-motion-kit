// ❌ Anti-pattern: the inner ListView uses its OWN ScrollController and ignores the
// one DraggableScrollableSheet hands to the builder. Now the drag gesture and the
// list scroll fight each other — you can't smoothly drag-to-expand then scroll.
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  // ❌ A controller of our own, used instead of the builder's.
  final ScrollController _ownController = ScrollController();

  @override
  void dispose() {
    _ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: Stack(
        children: [
          const Center(child: Text('Try dragging — it fights the scroll')),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            expand: true,
            builder: (context, scrollController) {
              // ❌ The provided scrollController is ignored on purpose.
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView.builder(
                  // ❌ Using _ownController breaks the drag-to-expand hand-off.
                  controller: _ownController,
                  itemCount: 30,
                  itemBuilder: (context, i) => ListTile(
                    leading: CircleAvatar(child: Text('$i')),
                    title: Text('Item $i'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
