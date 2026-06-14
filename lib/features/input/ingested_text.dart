/// Where a block of ingested text originated. The redaction flow downstream is
/// identical regardless of source; the kind is retained for audit/labeling.
enum InputSourceKind { cameraScan, imageImport, pdfImport, sharedText }

/// Text extracted from an input source (camera capture, imported image, …),
/// ready to flow into the detection + redaction pipeline.
///
/// The text is the *raw* recognized string — normalization (NFC, zero-width
/// strip, hyphen line-join) is the detection pipeline's job, so it is not
/// applied here to avoid double-normalization / offset confusion.
class IngestedText {
  const IngestedText({
    required this.text,
    required this.source,
    this.pageCount = 1,
    this.warnings = const [],
    this.originalPath,
    this.mime,
  });

  /// The recognized/extracted text.
  final String text;

  /// How the text was obtained.
  final InputSourceKind source;

  /// Number of source pages (1 for a single image; >1 for multi-page PDFs).
  final int pageCount;

  /// Non-fatal notes for the user (e.g. "No text was recognized in the image").
  final List<String> warnings;

  /// Path to the **original source file** (image/PDF) this text came from, when
  /// one exists — so it can be optionally retained encrypted (Phase 4c). Null
  /// for pasted/shared text (no file). Not the throwaway OCR scaffold.
  final String? originalPath;

  /// MIME type of [originalPath] (e.g. `image/jpeg`, `application/pdf`).
  final String? mime;

  /// True when there is no usable text to redact.
  bool get isEmpty => text.trim().isEmpty;
}
