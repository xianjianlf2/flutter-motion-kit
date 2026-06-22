// ✅ 推荐：单个 controller + Interval 错峰，AnimatedBuilder 传 child，正确 dispose。
// 可直接粘进 DartPad (https://dartpad.dev) 运行。
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

// 单个控制器 → SingleTickerProviderStateMixin
class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  static const _items = ['Inbox', 'Drafts', 'Sent', 'Starred', 'Archive', 'Trash'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose(); // ✅ 释放 Ticker，杜绝泄漏
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staggered entrance')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          // 每个 item 一段错峰区间，begin/end 都保证落在 [0,1]
          final start = (i / _items.length) * 0.6;
          final anim = CurvedAnimation(
            parent: _controller,
            curve: Interval(start, start + 0.4, curve: Curves.easeOut),
          );
          return _Entrance(
            animation: anim,
            // child 不随动画变化 → 作为 child 传入，避免每帧重建
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
      // ✅ 关键：复用传入的 child，builder 只做轻量的 Transform/Opacity
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
