import 'package:documink/ui/widgets/primary_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester, {
  required bool enabled,
  required VoidCallback onTap,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: PrimaryActionCard(
        icon: Icons.chat_bubble_outline,
        label: 'Chat with Mink',
        description: 'Your on-device assistant',
        enabled: enabled,
        disabledTooltip: 'Needs a more capable device',
        onTap: onTap,
      ),
    ),
  ),
);

void main() {
  testWidgets('enabled card fires onTap', (tester) async {
    var taps = 0;
    await _pump(tester, enabled: true, onTap: () => taps++);
    await tester.tap(find.text('Chat with Mink'));
    expect(taps, 1);
  });

  testWidgets('disabled card does not fire onTap', (tester) async {
    var taps = 0;
    await _pump(tester, enabled: false, onTap: () => taps++);
    await tester.tap(find.text('Chat with Mink'), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('disabled card exposes disabled semantics + tooltip', (
    tester,
  ) async {
    await _pump(tester, enabled: false, onTap: () {});
    // The disabled reason is announced (Semantics) and available as a Tooltip
    // for sighted long-press.
    expect(find.byType(Tooltip), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(Tooltip)),
      containsSemantics(
        hasEnabledState: true,
        isEnabled: false,
        label: 'Chat with Mink. Needs a more capable device',
      ),
    );
  });
}
