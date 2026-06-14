import 'package:documink/features/detection/detection_pipeline.dart';
import 'package:documink/features/detection/pii_recognizer.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:documink/features/detection/recognizers/email_recognizer.dart';
import 'package:documink/features/detection/recognizers/ssn_recognizer.dart';
import 'package:documink/features/memory/memory_guard.dart';
import 'package:documink/features/memory/memory_pii_scanner.dart';
import 'package:documink/features/memory/token_reference.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stub PERSON recognizer (real name detection is Tier 2/3, gated headless).
class _PersonStub implements PiiRecognizer {
  @override
  String get name => 'stub_person';
  @override
  int get priority => 2;
  @override
  List<DetectedSpan> recognize(String text) => [
    for (final m in RegExp(r'Dr\. Chen').allMatches(text))
      DetectedSpan(
        start: m.start,
        end: m.end,
        label: PiiLabels.person,
        text: m.group(0)!,
        detector: name,
        priority: priority,
      ),
  ];
}

void main() {
  final pipeline = DetectionPipeline([
    EmailRecognizer(),
    SsnRecognizer(),
    _PersonStub(),
  ]);
  final scanner = MemoryPiiScanner(pipeline);
  final guard = MemoryWriteGuard(scanner);

  group('scanner flags unreferenced PII', () {
    test('plaintext SSN is a violation', () async {
      final v = await scanner.scan('patient SSN 123-45-6789 on file');
      expect(v.map((e) => e.label), contains(PiiLabels.ssn));
    });

    test('plaintext email is a violation', () async {
      final v = await scanner.scan('mail her at a@b.com please');
      expect(v.map((e) => e.label), contains(PiiLabels.email));
    });

    test('plaintext person name is a violation', () async {
      final v = await scanner.scan('met Dr. Chen today');
      expect(v.map((e) => e.label), contains(PiiLabels.person));
    });
  });

  group('token references are not violations', () {
    test('Form B inline <<tok_…>> marker is safe', () async {
      final v = await scanner.scan(
        'I found 14 mentions of <<tok_01HXJ4K2Z6F3X9M2N5Q7V8W1E3>>.',
      );
      expect(v, isEmpty);
    });

    test('Form A token_ref map is skipped wholesale', () async {
      final content = {
        'type': 'token_ref',
        'token_id': 'tok_01HXJ4K2Z6F3X9M2N5Q7V8W1E3',
        'display_fallback_type': 'PERSON',
      };
      expect(await scanner.scan(content), isEmpty);
    });

    test('clean prose passes', () async {
      expect(await scanner.scan('the report was filed on time'), isEmpty);
    });
  });

  group('nested content', () {
    test('finds a leak beside a safe token_ref, with a path', () async {
      final content = {
        'summary': 'see <<tok_01HXJ4K2Z6F3X9M2N5Q7V8W1E3>>',
        'details_json': {
          'ref': const TokenRef(
            tokenId: 'tok_abc',
            displayFallbackType: 'SSN',
          ).toJson(),
          'leaked': 'SSN 123-45-6789',
        },
      };
      final v = await scanner.scan(content);
      expect(v, hasLength(1));
      expect(v.single.label, PiiLabels.ssn);
      expect(v.single.location, contains('details_json.leaked'));
    });
  });

  group('MemoryWriteGuard', () {
    test('throws MemoryPiiLeakError on unreferenced PII', () async {
      expect(
        () => guard.assertNoPlaintext('SSN 123-45-6789'),
        throwsA(isA<MemoryPiiLeakError>()),
      );
    });

    test('passes clean / fully-referenced content', () async {
      await guard.assertNoPlaintext({
        'note': 'spoke with <<tok_01HXJ4K2Z6F3X9M2N5Q7V8W1E3>>',
        'entity': const TokenRef(tokenId: 'tok_xyz').toJson(),
      });
    });

    test('error carries the structured violations', () async {
      try {
        await guard.assertNoPlaintext('mail a@b.com');
        fail('expected MemoryPiiLeakError');
      } on MemoryPiiLeakError catch (e) {
        expect(e.violations, isNotEmpty);
        expect(e.message, contains('token references'));
      }
    });
  });
}
