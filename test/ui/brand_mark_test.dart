import 'package:documink/ui/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrandMark renders a CustomPaint', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandMark())),
      ),
    );
    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('BrandLockup exposes the DocuMink wordmark', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandLockup())),
      ),
    );
    expect(find.bySemanticsLabel('DocuMink'), findsOneWidget);
  });
}
