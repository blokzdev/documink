import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/ui/widgets/entity_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders label with optional count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: EntityChip(label: PiiLabels.email, count: 2)),
        ),
      ),
    );
    expect(find.text('EMAIL · 2'), findsOneWidget);
  });

  testWidgets('renders without a count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: EntityChip(label: PiiLabels.ssn)),
        ),
      ),
    );
    expect(find.text('SSN'), findsOneWidget);
  });
}
