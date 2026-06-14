import 'package:documink/ui/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('maps known statuses to a friendly label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusBadge('redacted'))),
    );
    expect(find.text('Redacted'), findsOneWidget);
  });

  testWidgets('falls back to the raw status for unknown values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: StatusBadge('weird'))),
    );
    expect(find.text('weird'), findsOneWidget);
  });
}
