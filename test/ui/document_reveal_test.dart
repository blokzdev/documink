import 'package:documink/features/anonymization/anonymization_policy.dart';
import 'package:documink/features/anonymization/anonymization_providers.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/detection_providers.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/documents/document_repository.dart';
import 'package:documink/l10n/gen/app_localizations.dart';
import 'package:documink/services/authenticator.dart';
import 'package:documink/ui/screens/document_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_vault.dart';

class _FakeAuth implements Authenticator {
  _FakeAuth(this.approve);
  final bool approve;
  @override
  Future<bool> authenticate({required String reason}) async => approve;
}

void main() {
  late TestVault vault;

  setUp(() async => vault = await TestVault.unlocked());
  tearDown(() => vault.dispose());

  Future<({ProviderContainer container, String docId})> setup({
    required bool approve,
  }) async {
    final c = ProviderContainer(
      overrides: [
        vault.override,
        authenticatorProvider.overrideWithValue(_FakeAuth(approve)),
      ],
    );
    addTearDown(c.dispose);
    const text = 'Email alice@example.com now.';
    final detection = await c.read(detectionPipelineProvider).detect(text);
    const policy = AnonymizationPolicy({
      PiiLabels.email: Operator.tokenRandom,
    }, fallback: Operator.redact);
    final outcome = await c
        .read(anonymizationServiceProvider)
        .anonymize(detection.normalizedText, detection.spans, policy);
    final docId = await c
        .read(documentRepositoryProvider)
        .saveAnonymizedText(
          name: 'Doc',
          originalText: text,
          detection: detection,
          operators: const {PiiLabels.email: Operator.tokenRandom},
          outcome: outcome,
        );
    return (container: c, docId: docId);
  }

  Future<void> pump(WidgetTester tester, ProviderContainer c, String id) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DocumentDetailScreen(documentId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('reveal shows the original value after approval', (tester) async {
    final s = await setup(approve: true);
    await pump(tester, s.container, s.docId);

    await tester.tap(find.textContaining('original value'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('revealed-values')), findsOneWidget);
    expect(find.textContaining('alice@example.com'), findsOneWidget);
  });

  testWidgets('denied reveal shows an error and no plaintext', (tester) async {
    final s = await setup(approve: false);
    await pump(tester, s.container, s.docId);

    await tester.tap(find.textContaining('original value'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('revealed-values')), findsNothing);
    expect(find.text('Authentication failed'), findsOneWidget);
    expect(find.textContaining('alice@example.com'), findsNothing);
  });
}
