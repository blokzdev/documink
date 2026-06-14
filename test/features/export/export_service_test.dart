import 'dart:convert';

import 'package:documink/features/export/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = ExportService();

  test('text export is the redacted text', () {
    final out = service.build(
      name: 'Doc',
      type: 'text',
      status: 'redacted',
      createdAtEpochMs: 0,
      redactedText: 'Email [REDACTED] today.',
      entities: const [
        ExportEntity(label: 'EMAIL', operator: 'redact', start: 6, end: 16),
      ],
    );
    expect(out.text, 'Email [REDACTED] today.');
  });

  test('json metadata is valid, structured, and carries no plaintext', () {
    final out = service.build(
      name: 'Doc',
      type: 'text',
      status: 'redacted',
      createdAtEpochMs: 123,
      redactedText: 'Email [REDACTED] today.',
      entities: const [
        ExportEntity(label: 'EMAIL', operator: 'redact', start: 6, end: 16),
      ],
    );

    final decoded = jsonDecode(out.jsonMetadata) as Map<String, dynamic>;
    expect(decoded['documink_export_version'], ExportService.schemaVersion);
    expect(decoded['name'], 'Doc');
    expect(decoded['entityCount'], 1);
    expect(decoded['redactedText'], 'Email [REDACTED] today.');
    final entity = (decoded['entities'] as List).single as Map<String, dynamic>;
    expect(entity['type'], 'EMAIL');
    expect(entity['operator'], 'redact');
    expect(entity, isNot(contains('text'))); // never the matched plaintext
    expect(out.jsonMetadata, isNot(contains('alice@example.com')));
  });
}
