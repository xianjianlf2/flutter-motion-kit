// ✅ Recommended: a DraggableScrollableSheet whose inner ListView uses the builder's
// ScrollController, so dragging the sheet and scrolling its content compose cleanly.
// Snap points give it discrete resting heights. Scroll-driven — no AnimationController.
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

class _Demo extends StatelessWidget {
  const _Demo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable bottom sheet')),
      // A simple page behind the sheet.
      body: Stack(
        children: [
          const Center(child: Text('Drag the sheet up, then scroll it')),
          // ✅ expand:true makes the sheet fill the Stack and align to the bottom.
          DraggableScrollableSheet(
            // ✅ min <= initial <= max, otherwise it asserts.
            initialChildSize: 0.4,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            expand: true,
            // ✅ snap to discrete heights instead of resting wherever the finger lifts.
            snap: true,
            snapSizes: const [0.25, 0.4, 0.9],
            builder: (context, scrollController) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                // ✅ Hand the provided controller to the inner scrollable so the
                // drag-to-expand then scroll-content hand-off works seamlessly.
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: 31,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      // A drag handle at the top of the sheet.
                      return Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }
                    return ListTile(
                      leading: CircleAvatar(child: Text('$i')),
                      title: Text('Item $i'),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
