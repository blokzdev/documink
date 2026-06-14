import 'package:flutter_pdf_text/flutter_pdf_text.dart';

import 'pdf_text_extractor.dart';

/// Production [PdfTextExtractor] backed by `flutter_pdf_text` (MIT; Apache
/// PDFBox on Android).
///
/// **Device-only:** PDFBox runs via platform channels, so this adapter is not
/// exercised by headless tests — the orchestration it feeds is tested with a
/// fake. Wired at bootstrap; extraction accuracy is device-verified
/// (VERIFICATION.md). Pages with no embedded text layer return an empty string
/// (the orchestrator's signal to OCR that page).
class FlutterPdfTextExtractor implements PdfTextExtractor {
  const FlutterPdfTextExtractor();

  @override
  Future<List<String>> extractPages(String path) async {
    final doc = await PDFDoc.fromPath(path);
    return [for (final page in doc.pages) await page.text];
  }
}
