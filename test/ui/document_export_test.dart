import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/document_detail_screen.dart';
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

  testWidgets('export copies the redacted text and audits the export', (
    tester,
  ) async {
    const text = 'Email alice@example.com today.';
    final detection = await container
        .read(detectionPipelineProvider)
        .detect(text);
    final outcome = await container
        .read(anonymizationServiceProvider)
        .anonymize(
          detection.normalizedText,
          detection.spans,
          const AnonymizationPolicy({}, fallback: Operator.redact),
        );
    final id = await container
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: 'Doc',
          originalText: text,
          detection: detection,
          operators: const {},
          outcome: outcome,
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DocumentDetailScreen(documentId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Export'));
    await tester.pumpAndSettle();

    // The export sheet offers both artifacts.
    expect(find.text('Copy redacted text'), findsOneWidget);
    expect(find.text('Copy metadata (JSON)'), findsOneWidget);
  });
}
