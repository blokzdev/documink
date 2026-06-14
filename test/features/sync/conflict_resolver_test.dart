import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/custom_entities/custom_entity_definition.dart';
import 'package:documink/features/sync/conflict_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

CustomEntityDefinition def({
  required String id,
  String label = 'NPI',
  String? projectId,
  String pattern = r'\d{10}',
  CustomValidator validator = CustomValidator.none,
  Operator op = Operator.redact,
}) => CustomEntityDefinition(
  id: id,
  workspaceId: 'ws',
  projectId: projectId,
  label: label,
  regexPattern: pattern,
  validator: validator,
  defaultOperator: op,
  createdAtEpochMs: 0,
);

void main() {
  group('LWW', () {
    Versioned<String> v(String value, int at, String dev) =>
        Versioned(value, updatedAtEpochMs: at, deviceId: dev);

    test('newer timestamp wins', () {
      expect(lwwWinner(v('a', 1, 'x'), v('b', 2, 'y')).value, 'b');
      expect(lwwWinner(v('a', 3, 'x'), v('b', 2, 'y')).value, 'a');
    });

    test('ties break deterministically by device id', () {
      final r1 = lwwWinner(v('a', 5, 'devA'), v('b', 5, 'devB'));
      final r2 = lwwWinner(v('b', 5, 'devB'), v('a', 5, 'devA'));
      expect(r1.value, 'b'); // devB > devA
      expect(r2.value, r1.value); // order-independent
    });
  });

  test('setUnion merges and dedups', () {
    expect(setUnion([1, 2], [2, 3]), {1, 2, 3});
  });

  group('hard conflict detection', () {
    const detector = SyncConflictDetector();

    test('same identity, different id + pattern is a hard conflict', () {
      final conflicts = detector.detectCustomEntityConflicts(
        [def(id: 'l', pattern: r'\d{10}')],
        [def(id: 'r', pattern: r'\d{9}')],
      );
      expect(conflicts, hasLength(1));
      expect(conflicts.single.label, 'NPI');
      expect(conflicts.single.local.id, 'l');
      expect(conflicts.single.remote.id, 'r');
    });

    test('same record id is not a conflict (CRDT handles)', () {
      final conflicts = detector.detectCustomEntityConflicts(
        [def(id: 'same', pattern: r'\d{10}')],
        [def(id: 'same', pattern: r'\d{9}')],
      );
      expect(conflicts, isEmpty);
    });

    test('same identity + identical definition is a benign duplicate', () {
      final conflicts = detector.detectCustomEntityConflicts(
        [def(id: 'l')],
        [def(id: 'r')],
      );
      expect(conflicts, isEmpty);
    });

    test('different identity is not a conflict', () {
      final conflicts = detector.detectCustomEntityConflicts(
        [def(id: 'l', label: 'NPI')],
        [def(id: 'r', label: 'MRN')],
      );
      expect(conflicts, isEmpty);
    });

    test('diverging validator or operator also conflicts', () {
      expect(
        detector.detectCustomEntityConflicts(
          [def(id: 'l', validator: CustomValidator.none)],
          [def(id: 'r', validator: CustomValidator.luhn)],
        ),
        hasLength(1),
      );
      expect(
        detector.detectCustomEntityConflicts(
          [def(id: 'l', op: Operator.redact)],
          [def(id: 'r', op: Operator.fpe)],
        ),
        hasLength(1),
      );
    });
  });
}
