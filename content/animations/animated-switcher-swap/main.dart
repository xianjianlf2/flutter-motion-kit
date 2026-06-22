// ✅ 推荐：给 child 唯一 ValueKey，AnimatedSwitcher 才能识别「内容变了」并过渡。
// 可直接粘进 DartPad (https://dartpad.dev) 运行。
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _Demo(),
      );
}

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Text(
            '$_count',
            // 关键：用 ValueKey 标识不同内容，否则不会有过渡
            key: ValueKey<int>(_count),
            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
