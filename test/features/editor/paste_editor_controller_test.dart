import 'package:documink/features/anonymization/operator.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/editor/paste_editor_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  PasteEditorController controller() =>
      container.read(pasteEditorControllerProvider.notifier);
  PasteEditorState state() => container.read(pasteEditorControllerProvider);

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose);

  test('starts idle and empty', () {
    expect(state().status, EditorStatus.idle);
    expect(state().entityCount, 0);
    expect(state().previewText, '');
  });

  test('detect finds Tier-1 entities and redacts them by default', () async {
    controller().setInput('Email me at alice@example.com please.');
    await controller().detect();

    final s = state();
    expect(s.status, EditorStatus.ready);
    expect(s.labels, contains(PiiLabels.email));
    expect(s.operators[PiiLabels.email], Operator.redact);
    expect(s.previewText, contains('[REDACTED]'));
    expect(s.previewText, isNot(contains('alice@example.com')));
  });

  test('changing an operator recomputes the preview', () async {
    controller().setInput('Reach alice@example.com now.');
    await controller().detect();

    controller().setOperator(PiiLabels.email, Operator.replace);
    expect(state().previewText, contains('<${PiiLabels.email}>'));

    controller().setOperator(PiiLabels.email, Operator.mask);
    expect(state().previewText, contains('•'));
    expect(state().previewText, isNot(contains('alice@example.com')));
  });

  test('empty input detects nothing', () async {
    controller().setInput('   ');
    await controller().detect();
    expect(state().status, EditorStatus.idle);
    expect(state().entityCount, 0);
  });

  test('setInput clears prior detection', () async {
    controller().setInput('alice@example.com');
    await controller().detect();
    expect(state().entityCount, greaterThan(0));

    controller().setInput('nothing here');
    expect(state().detection, isNull);
    expect(state().status, EditorStatus.idle);
  });

  test('editor offers only irreversible operators', () {
    expect(editorOperators, [Operator.redact, Operator.mask, Operator.replace]);
    expect(editorOperators.every((o) => !o.isReversible), isTrue);
  });
}
