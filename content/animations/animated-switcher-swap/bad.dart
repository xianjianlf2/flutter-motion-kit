// ❌ 反面教材：child 不带 Key。
// AnimatedSwitcher 认为前后是同一个 Text widget，只是参数变了 ->
// 数字会瞬间跳变，完全没有过渡动画。
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

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
          child: Text(
            '$_count', // ❌ 没有 key -> 不触发切换动画
            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
