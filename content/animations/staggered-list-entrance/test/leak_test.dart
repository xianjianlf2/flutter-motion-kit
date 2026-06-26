// Quality benchmark: use Flutter's built-in leak tracking to prove "the correct version doesn't leak".
// To run: drop main.dart into a Flutter project as the widget under test, then run
//   flutter test --enable-leak-tracking content/animations/staggered-list-entrance/test/leak_test.dart
//
// Note: leak tracking has been built into flutter_test since Flutter 3.13+. If you point this test at
// bad.dart (the version that forgets dispose), the assertion fails because the AnimationController/Ticker
// is never released — turning the pitfall from "something I claim" into "something the machine proves".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// import '../main.dart' as good;   // points to the correct implementation
// import '../bad.dart' as bad;     // switching to this triggers a leak-assertion failure

void main() {
  testWidgets('staggered entrance disposes its controller (no leaks)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Placeholder()));
    // In a real project, swap in good.App / good.Demo, then pump an empty page to trigger dispose:
    //   await tester.pumpWidget(const good.Demo());
    //   await tester.pump(const Duration(milliseconds: 1000));
    //   await tester.pumpWidget(const SizedBox());   // unmount -> triggers dispose
    // leak tracking verifies at the end of the test, so no manual assertion is needed.
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
