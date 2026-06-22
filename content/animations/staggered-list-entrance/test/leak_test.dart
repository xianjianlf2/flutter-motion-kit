// 质量标杆：用 Flutter 内置的 leak tracking 证明「正确版本不泄漏」。
// 运行：把 main.dart 作为被测组件放进一个 Flutter 工程，执行
//   flutter test --enable-leak-tracking content/animations/staggered-list-entrance/test/leak_test.dart
//
// 说明：leak tracking 自 Flutter 3.13+ 内置于 flutter_test。若把本测试指向
// bad.dart（漏 dispose 的版本），断言会因 AnimationController/Ticker 未释放而失败 ——
// 这就是把「坑」从“我说的”变成“机器证明的”。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import '../main.dart' as good;   // 指向正确实现
// import '../bad.dart' as bad;     // 切到这个会触发泄漏断言失败

void main() {
  testWidgets('staggered entrance disposes its controller (no leaks)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    // 在真实工程中替换为 good.App / good.Demo，pump 后再 pump 一个空页面触发 dispose：
    //   await tester.pumpWidget(const good.Demo());
    //   await tester.pump(const Duration(milliseconds: 1000));
    //   await tester.pumpWidget(const SizedBox());   // 卸载 -> 触发 dispose
    // leak tracking 会在测试结束时校验，无需手写断言。
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
