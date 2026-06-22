// ❌ 反面教材：为了一个简单过渡手写 AnimationController。
// 问题：① 代码量翻倍 ② 极易漏 dispose 造成 ticker 泄漏（此处故意漏）
//      ③ 用 setState 监听 = 每帧整体重建。隐式动画一行就能替代这一切。
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..addListener(() => setState(() {})); // ❌ 每帧 setState

  // ❌ 故意没有 dispose() —— 真实项目里这就是一处 ticker / 内存泄漏

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOutCubic.transform(_c.value);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _c.isCompleted ? _c.reverse() : _c.forward(),
          child: Container(
            width: 120 + 120 * t,
            height: 120 + 120 * t,
            decoration: BoxDecoration(
              color: Color.lerp(Colors.indigo.shade200, Colors.indigo, t),
              borderRadius: BorderRadius.circular(12 + 20 * t),
            ),
          ),
        ),
      ),
    );
  }
}
