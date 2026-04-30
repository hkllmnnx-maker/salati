import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salati/main.dart';

void main() {
  testWidgets('Salati app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const SalatiApp());
    await tester.pump(const Duration(milliseconds: 200));
    // التطبيق ينبغي أن يبدأ دون رمي استثناء
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
