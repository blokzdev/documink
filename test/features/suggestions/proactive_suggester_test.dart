import 'package:documink/data/app_database.dart';
import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:documink/features/audit/audit_log_repository.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/suggestions/deterministic_suggestion_rules.dart';
import 'package:documink/features/suggestions/proactive_suggester.dart';
import 'package:documink/features/suggestions/suggestion.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// A source returning a preset proposal, counting how often it's consulted.
class FixedSource implements SuggestionSource {
  FixedSource(this.proposal);
  final Suggestion? proposal;
  int calls = 0;

  @override
  Future<Suggestion?> propose(SuggestionSignal signal) async {
    calls++;
    return proposal;
  }
}

Suggestion suggestion({
  required String label,
  Operator operator = Operator.tokenRandom,
  SuggestionTrigger trigger = SuggestionTrigger.detectionCompleted,
}) => Suggestion(
  trigger: trigger,
  title: 't',
  body: 'b',
  action: SuggestionAction(
    kind: SuggestionActionKind.tokenizeLabelConsistently,
    label: label,
    operator: operator,
  ),
);

void main() {
  late AppDatabase db;
  late AuditLogRepository audit;
  var audN = 0;

  SuggestionSignal signal(
    Map<String, int> counts, {
    Map<String, Operator> operators = const {},
  }) => SuggestionSignal(
    trigger: SuggestionTrigger.detectionCompleted,
    labelCounts: counts,
    workspaceId: 'ws',
    tier: 'standard',
    currentOperators: operators,
  );

  ProactiveSuggester build(List<SuggestionSource> sources) =>
      ProactiveSuggester(
        sources: sources,
        audit: audit,
        idGenerator: () => 'a${audN++}',
        clock: () => DateTime.fromMillisecondsSinceEpoch(1000),
      );

  Future<List<AuditEntry>> offers() =>
      audit.query('ws', eventTypes: [AuditEventType.suggestionOffered]);

  setUp(() async {
    audN = 0;
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.workspaces)
        .insert(
          WorkspacesCompanion.insert(
            id: 'ws',
            name: 'W',
            createdAt: 0,
            kekVersion: 1,
          ),
        );
    audit = AuditLogRepository(db);
  });

  tearDown(() => db.close());

  test(
    'disabled toggle: no suggestion, source untouched, nothing audited',
    () async {
      final src = FixedSource(suggestion(label: PiiLabels.person));
      final out = await build([
        src,
      ]).suggest(signal({PiiLabels.person: 5}), enabled: false);

      expect(out, isNull);
      expect(src.calls, 0);
      expect(await offers(), isEmpty);
    },
  );

  test('no detected entities: short-circuits before any source', () async {
    final src = FixedSource(suggestion(label: PiiLabels.person));
    final out = await build([src]).suggest(signal(const {}), enabled: true);

    expect(out, isNull);
    expect(src.calls, 0);
    expect(await offers(), isEmpty);
  });

  test(
    'valid suggestion is returned and audited with PII-safe metadata',
    () async {
      final suggester = build([const DeterministicSuggestionSource()]);
      final out = await suggester.suggest(
        signal({PiiLabels.person: 47}),
        enabled: true,
      );

      expect(out, isNotNull);
      expect(out!.action.label, PiiLabels.person);

      final rows = await offers();
      expect(rows, hasLength(1));
      final meta = rows.single.metadata!;
      expect(meta['trigger'], 'detectionCompleted');
      expect(meta['action'], 'tokenizeLabelConsistently');
      expect(meta['label'], PiiLabels.person); // entity TYPE, not a value
      expect(meta['operator'], Operator.tokenRandom.policyName);
      expect(meta['count'], 47);
      // The metadata carries only type + count — no plaintext value field exists.
      expect(
        meta.keys,
        containsAll(['trigger', 'action', 'label', 'operator', 'count']),
      );
    },
  );

  test('rejects a label that was not detected (hallucination guard)', () async {
    final out = await build([
      FixedSource(suggestion(label: PiiLabels.mrn)),
    ]).suggest(signal({PiiLabels.person: 5}), enabled: true);

    expect(out, isNull);
    expect(await offers(), isEmpty);
  });

  test('rejects a no-op (label already on the proposed operator)', () async {
    final out = await build([FixedSource(suggestion(label: PiiLabels.person))])
        .suggest(
          signal(
            {PiiLabels.person: 5},
            operators: {PiiLabels.person: Operator.tokenRandom},
          ),
          enabled: true,
        );

    expect(out, isNull);
    expect(await offers(), isEmpty);
  });

  test('rejects an operator outside the whitelist (e.g. FPE)', () async {
    final out = await build([
      FixedSource(suggestion(label: PiiLabels.person, operator: Operator.fpe)),
    ]).suggest(signal({PiiLabels.person: 5}), enabled: true);

    expect(out, isNull);
    expect(await offers(), isEmpty);
  });

  test('recordActioned / recordDismissed write PII-safe audit rows', () async {
    final suggester = build(const []);
    final s = suggestion(label: PiiLabels.person);
    final sig = signal({PiiLabels.person: 5});

    await suggester.recordActioned(s, sig);
    await suggester.recordDismissed(s, sig);

    final actioned = await audit.query(
      'ws',
      eventTypes: [AuditEventType.suggestionActioned],
    );
    final dismissed = await audit.query(
      'ws',
      eventTypes: [AuditEventType.suggestionDismissed],
    );
    expect(actioned, hasLength(1));
    expect(dismissed, hasLength(1));
    expect(actioned.single.metadata!['label'], PiiLabels.person); // type only
    expect(actioned.single.metadata!['count'], 5);
  });

  test('consults sources in order and uses the first valid proposal', () async {
    final first = FixedSource(null);
    final second = FixedSource(suggestion(label: PiiLabels.email));
    final out = await build([
      first,
      second,
    ]).suggest(signal({PiiLabels.email: 4}), enabled: true);

    expect(out!.action.label, PiiLabels.email);
    expect(first.calls, 1);
    expect(second.calls, 1);
    expect(await offers(), hasLength(1));
  });
}
