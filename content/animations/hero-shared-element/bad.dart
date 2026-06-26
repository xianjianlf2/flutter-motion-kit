// ❌ Anti-pattern: every item uses the same constant tag.
// Multiple Heroes with the same tag on screen at once — at runtime this throws "There are multiple heroes
// that share the same tag within a subtree."
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _GridPage()));

const _colors = [Colors.red, Colors.green, Colors.blue, Colors.orange];

class _GridPage extends StatelessWidget {
  const _GridPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          for (final c in _colors)
            const Hero(
              tag:
                  'box', // ❌ every item shares one tag -> on-screen conflict crashes
              child: Placeholder(),
            ),
        ],
      ),
    );
  }
}
