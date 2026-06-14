import 'package:documink/ui/widgets/app_error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the title and a working Retry', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            title: 'Could not load',
            onRetry: () => retried++,
          ),
        ),
      ),
    );

    expect(find.text('Could not load'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });

  testWidgets('omits Retry when no callback is given', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppErrorState())),
    );
    expect(find.text('Retry'), findsNothing);
  });
}
