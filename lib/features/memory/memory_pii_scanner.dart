import '../detection/detection_pipeline.dart';
import 'token_reference.dart';

/// A piece of unreferenced PII found in would-be memory content.
class MemoryPiiViolation {
  const MemoryPiiViolation({
    required this.label,
    required this.text,
    required this.location,
  });

  /// Entity type, e.g. `SSN`.
  final String label;

  /// The offending substring (kept only to surface the error to the developer;
  /// never written to a memory table).
  final String text;

  /// JSON-path-ish location within the scanned content (e.g. `$.details_json`).
  final String location;

  @override
  String toString() => '$label at $location';
}

/// Enforces the memory.md §3 invariant: scans would-be memory content for PII
/// that is **not** already a token reference. Form-A token-ref maps and Form-B
/// `<<tok_…>>` markers are recognized and excluded; everything else is run
/// through the detection pipeline, and any detected span is a violation.
class MemoryPiiScanner {
  const MemoryPiiScanner(this._pipeline);

  final DetectionPipeline _pipeline;

  /// Scans a single string after stripping inline token markers.
  Future<List<MemoryPiiViolation>> scanText(
    String text, {
    String location = r'$',
  }) async {
    final residual = stripInlineTokenMarkers(text);
    final result = await _pipeline.detect(residual);
    return [
      for (final span in result.spans)
        MemoryPiiViolation(
          label: span.label,
          text: span.text,
          location: location,
        ),
    ];
  }

  /// Recursively scans arbitrary JSON-like content (String/Map/List/scalar).
  /// Token-reference maps are skipped wholesale.
  Future<List<MemoryPiiViolation>> scan(
    Object? content, {
    String path = r'$',
  }) async {
    final violations = <MemoryPiiViolation>[];
    await _walk(content, path, violations);
    return violations;
  }

  Future<void> _walk(
    Object? content,
    String path,
    List<MemoryPiiViolation> out,
  ) async {
    if (content is String) {
      out.addAll(await scanText(content, location: path));
    } else if (content is Map) {
      if (isTokenRefMap(content)) return; // safe reference — no plaintext
      for (final entry in content.entries) {
        await _walk(entry.value, '$path.${entry.key}', out);
      }
    } else if (content is List) {
      for (var i = 0; i < content.length; i++) {
        await _walk(content[i], '$path[$i]', out);
      }
    }
    // Numbers/bools/null carry no PII.
  }
}
