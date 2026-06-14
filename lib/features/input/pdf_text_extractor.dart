import 'input_exceptions.dart';

/// Extracts the embedded text layer of a PDF, one entry per page.
///
/// A page with no text layer (a scanned/image-only page) yields an empty
/// string for that index — the orchestrator's signal to fall back to OCR via
/// [PdfPageRasterizer] + the existing `OcrRecognizer`. Device-only in
/// production (`flutter_pdf_text` → Apache PDFBox on Android); faked in tests.
abstract interface class PdfTextExtractor {
  /// Returns the text layer per page. List length == page count.
  Future<List<String>> extractPages(String path);
}

/// Thrown when text extraction is requested but no platform extractor was
/// wired (the safe default).
class PdfTextExtractorUnavailableException
    implements InputUnavailableException {
  const PdfTextExtractorUnavailableException();

  @override
  String toString() => 'PDF text extraction is not available on this device.';
}

/// Safe default [PdfTextExtractor] — fails loudly until the real extractor is
/// composed at bootstrap.
class UnavailablePdfTextExtractor implements PdfTextExtractor {
  const UnavailablePdfTextExtractor();

  @override
  Future<List<String>> extractPages(String path) async =>
      throw const PdfTextExtractorUnavailableException();
}
