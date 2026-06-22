// ❌ 反面教材：所有项用同一个常量 tag。
// 同屏出现多个相同 tag 的 Hero —— 运行时直接抛 "There are multiple heroes
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
              tag: 'box', // ❌ 所有项共用同一个 tag -> 同屏冲突崩溃
              child: Placeholder(),
            ),
        ],
      ),
    );
  }
}
