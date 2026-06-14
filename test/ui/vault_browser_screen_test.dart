import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/ui/screens/document_detail_screen.dart';
import 'package:documink/ui/screens/vault_browser_screen.dart';
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

  Future<String> saveDoc(String name, String text) async {
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
    return container
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: name,
          originalText: text,
          detection: detection,
          operators: const {},
          outcome: outcome,
        );
  }

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state when there are no documents', (tester) async {
    await pump(tester, const VaultBrowserScreen());
    expect(find.textContaining('No documents yet'), findsOneWidget);
  });

  testWidgets('lists a saved document', (tester) async {
    await saveDoc('Doc One', 'Email alice@example.com today.');
    await pump(tester, const VaultBrowserScreen());
    expect(find.text('Doc One'), findsOneWidget);
  });

  testWidgets('detail shows the redacted content', (tester) async {
    final id = await saveDoc('Doc One', 'Email alice@example.com today.');
    await pump(tester, DocumentDetailScreen(documentId: id));

    expect(find.text('Doc One'), findsOneWidget);
    final text = tester
        .widget<SelectableText>(find.byKey(const Key('document-redacted-text')))
        .data!;
    expect(text, contains('[REDACTED]'));
    expect(text, isNot(contains('alice@example.com')));
  });

  testWidgets('delete confirm removes the document', (tester) async {
    final id = await saveDoc('Doc One', 'Email alice@example.com today.');
    await pump(tester, DocumentDetailScreen(documentId: id));

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      await container.read(documentRepositoryProvider).documentById(id),
      isNull,
    );
  });
}
