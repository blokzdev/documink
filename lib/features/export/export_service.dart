import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A de-identified entity summary for export metadata — **type/operator/offsets
/// only, never plaintext** (privacy invariant).
class ExportEntity {
  const ExportEntity({
    required this.label,
    required this.operator,
    required this.start,
    required this.end,
  });

  final String label;
  final String operator;
  final int start;
  final int end;

  Map<String, dynamic> toJson() => {
    'type': label,
    'operator': operator,
    'start': start,
    'end': end,
  };
}

/// The two export artifacts for a redacted document.
class DocumentExport {
  const DocumentExport({required this.text, required this.jsonMetadata});

  /// The redacted text (`.txt`).
  final String text;

  /// Pretty-printed JSON sidecar (metadata + redacted text; no PII).
  final String jsonMetadata;
}

/// Builds export artifacts for a redacted document (blueprint §7). Pure: the
/// share-sheet / file-save is a native concern wired on-device. The output
/// contains only the **redacted** text and de-identified metadata — never the
/// original PII.
class ExportService {
  const ExportService();

  static const String schemaVersion = '1';

  DocumentExport build({
    required String name,
    required String type,
    required String status,
    required int createdAtEpochMs,
    required String redactedText,
    required List<ExportEntity> entities,
  }) {
    final meta = <String, dynamic>{
      'documink_export_version': schemaVersion,
      'name': name,
      'type': type,
      'status': status,
      'createdAt': createdAtEpochMs,
      'entityCount': entities.length,
      'entities': [for (final e in entities) e.toJson()],
      'redactedText': redactedText,
    };
    return DocumentExport(
      text: redactedText,
      jsonMetadata: const JsonEncoder.withIndent('  ').convert(meta),
    );
  }
}

final exportServiceProvider = Provider<ExportService>(
  (ref) => const ExportService(),
);
