// ❌ 反面教材：listener 里 setState 全量重建 + AnimatedBuilder 不传 child + 漏 dispose。
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: _Demo()));

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  static const _items = ['Inbox', 'Drafts', 'Sent', 'Starred', 'Archive', 'Trash'];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )
    ..addListener(() => setState(() {})) // ❌ 每帧 setState，整页重建
    ..forward();

  // ❌ 没有 dispose() —— Ticker 泄漏

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BAD example')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final v = _controller.value;
          // ❌ 子树（ListTile）在每帧都被重新构建
          return Opacity(
            opacity: v,
            child: Transform.translate(
              offset: Offset(0, 24 * (1 - v)),
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_items[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}
