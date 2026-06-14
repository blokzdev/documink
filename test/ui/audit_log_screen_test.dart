import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/ui/screens/audit_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

void main() {
  late TestVault vault;
  late ProviderContainer container;

  setUp(() async {
    vault = await TestVault.unlocked();
    container = ProviderContainer(overrides: [vault.override]);
    addTearDown(container.dispose);
    addTearDown(vault.dispose);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AuditLogScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state when no activity', (tester) async {
    await pump(tester);
    expect(find.textContaining('No activity yet'), findsOneWidget);
  });

  testWidgets('shows a logged event after a save', (tester) async {
    final detection = await container
        .read(detectionPipelineProvider)
        .detect('a@b.com');
    final outcome = await container
        .read(anonymizationServiceProvider)
        .anonymize(
          detection.normalizedText,
          detection.spans,
          const AnonymizationPolicy({}, fallback: Operator.redact),
        );
    await container
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: 'Doc',
          originalText: 'a@b.com',
          detection: detection,
          operators: const {},
          outcome: outcome,
        );

    await pump(tester);
    expect(find.text('document_saved'), findsOneWidget);
  });
}
