import 'package:documink/features/mink/mink_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseToolInvocation', () {
    test('parses a bare tool-call JSON object', () {
      final inv = parseToolInvocation('{"tool":"search_documents","args":{}}');
      expect(inv, isNotNull);
      expect(inv!.name, 'search_documents');
      expect(inv.args, isEmpty);
    });

    test('extracts JSON embedded in surrounding prose', () {
      final inv = parseToolInvocation(
        'Sure, let me look: {"tool":"list_entities","args":{"document_id":"d1"}} ok',
      );
      expect(inv!.name, 'list_entities');
      expect(inv.args['document_id'], 'd1');
    });

    test('returns null for a plain text reply', () {
      expect(parseToolInvocation('You have three documents.'), isNull);
    });

    test('returns null for malformed JSON', () {
      expect(parseToolInvocation('{"tool": '), isNull);
    });

    test('returns null when "tool" is missing or empty', () {
      expect(parseToolInvocation('{"args":{}}'), isNull);
      expect(parseToolInvocation('{"tool":"","args":{}}'), isNull);
    });

    test('tolerates a missing args object', () {
      final inv = parseToolInvocation('{"tool":"recall_core"}');
      expect(inv!.name, 'recall_core');
      expect(inv.args, isEmpty);
    });
  });
}
