import 'package:documink/features/audit/audit_event_labels.dart';
import 'package:documink/features/audit/audit_event_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('prettifyAuditEvent', () {
    test('capitalizes and de-snakes the event type', () {
      expect(prettifyAuditEvent('document_saved'), 'Document saved');
      expect(prettifyAuditEvent('mink_tool_call'), 'Mink tool call');
      expect(
        prettifyAuditEvent('document_original_revealed'),
        'Document original revealed',
      );
    });

    test('handles a single word and empty input', () {
      expect(prettifyAuditEvent('export'), 'Export');
      expect(prettifyAuditEvent(''), '');
    });
  });

  group('auditFilterableEventTypes', () {
    test('covers every group, with no duplicates', () {
      final flat = auditFilterableEventTypes;
      expect(flat.toSet().length, flat.length);
      expect(flat, contains('document_saved'));
      expect(flat, contains(AuditEventType.personalTemplateSaved));
      expect(flat, contains(AuditEventType.syncPull));
    });
  });
}
