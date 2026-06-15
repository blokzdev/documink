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
    // Read each page independently so a single page PDFBox can't extract (e.g.
    // a page whose only content is a JPEG2000 image — the JP2 decoder is
    // intentionally excluded from the build) degrades to an empty string rather
    // than failing the whole document. An empty page is the orchestrator's
    // signal to OCR it via the rasterize + ML Kit fallback (InputIngestionService).
    final pages = <String>[];
    for (final page in doc.pages) {
      try {
        pages.add(await page.text);
      } on Object {
        pages.add('');
      }
    }
    return pages;
  }
}
