// ✅ 推荐：用隐式动画做简单属性过渡，零 controller、零 dispose 负担。
// 可直接粘进 DartPad (https://dartpad.dev) 运行。
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const _Demo(),
    );
  }
}

class _Demo extends StatefulWidget {
  const _Demo();

  @override
  State<_Demo> createState() => _DemoState();
}

class _DemoState extends State<_Demo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: AnimatedContainer(
            // 关键：只声明「目标状态」，框架负责补间过渡。
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            width: _expanded ? 240 : 120,
            height: _expanded ? 240 : 120,
            decoration: BoxDecoration(
              color: _expanded ? Colors.indigo : Colors.indigo.shade200,
              borderRadius: BorderRadius.circular(_expanded ? 32 : 12),
            ),
            alignment: Alignment.center,
            child: const Text('Tap me', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
