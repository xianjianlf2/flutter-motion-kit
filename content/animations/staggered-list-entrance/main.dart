// ✅ Recommended: a single controller + Interval staggering, AnimatedBuilder with a child, and proper dispose.
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

// Single controller → SingleTickerProviderStateMixin
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
  )..forward();

  @override
  void dispose() {
    _controller.dispose(); // ✅ release the Ticker to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered entrance')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          // Each item gets a staggered interval; begin/end always stay within [0,1]
          final start = (i / _items.length) * 0.6;
          final anim = CurvedAnimation(
            parent: _controller,
            curve: Interval(start, start + 0.4, curve: Curves.easeOut),
          );
          return _Entrance(
            animation: anim,
            // the child doesn't change with the animation → pass it as the child to avoid rebuilding it every frame
            child: ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(_items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      // ✅ Key idea: reuse the passed-in child; the builder only does lightweight Transform/Opacity
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}
