import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invesly/common/presentations/widgets/calculator.dart';

void main() {
  testWidgets('calculator widget becomes visible when enabled', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InveslyCalculatorWidget())));

    expect(find.byType(Divider), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: InveslyCalculatorWidget())));

    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsOneWidget);
  });
}
