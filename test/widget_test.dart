import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palmcare/main.dart'; // تأكد أن اسم مشروعك هو palmcare، أو غيّره حسب اسم مشروعك

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // بناء التطبيق
    await tester.pumpWidget(const PalmCareApp());

    // التأكد أن العداد يبدأ من 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // الضغط على زر "+"
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // التأكد أن العداد أصبح 1
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
