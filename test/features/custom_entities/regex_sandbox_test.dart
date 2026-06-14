import 'package:documink/features/custom_entities/regex_sandbox.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sandbox = RegexSandbox();

  test('returns matches for a normal pattern', () async {
    final result = await sandbox.preview(r'\d{3}', 'a 123 b 456 c');
    expect(result.status, RegexPreviewStatus.ok);
    expect(result.matches.map((m) => m.text).toList(), ['123', '456']);
    expect(result.matches.first.start, 2);
  });

  test('reports a compile error instead of throwing', () async {
    final result = await sandbox.preview('(unclosed', 'whatever');
    expect(result.status, RegexPreviewStatus.error);
    expect(result.errorMessage, isNotNull);
  });

  test(
    'aborts a catastrophic-backtracking pattern (ReDoS) via timeout',
    () async {
      const fast = RegexSandbox(timeout: Duration(milliseconds: 200));
      // (a+)+$ against many 'a's followed by a non-match is exponential.
      final evilInput = '${'a' * 32}!';
      final result = await fast.preview(r'(a+)+$', evilInput);
      expect(result.status, RegexPreviewStatus.timedOut);
    },
  );

  test('truncates the sample to maxSampleLength', () async {
    const tiny = RegexSandbox(maxSampleLength: 5);
    // Only the first 5 chars ('12345') are searched.
    final result = await tiny.preview(r'\d', '123456789');
    expect(result.status, RegexPreviewStatus.ok);
    expect(result.matches, hasLength(5));
  });
}
