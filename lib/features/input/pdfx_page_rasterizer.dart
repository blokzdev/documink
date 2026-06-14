import 'dart:io';
import 'dart:math' as math;

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

import 'pdf_page_rasterizer.dart';

/// Production [PdfPageRasterizer] backed by `pdfx` (MIT) native rendering.
///
/// **Device-only:** renders via platform channels, so this adapter is not
/// exercised by headless tests — the orchestration it feeds is tested with a
/// fake. Wired at bootstrap; rendering is device-verified (VERIFICATION.md).
/// Renders on a white background and upscales so the page is legible to ML Kit
/// OCR.
class PdfxPageRasterizer implements PdfPageRasterizer {
  const PdfxPageRasterizer();

  /// Preferred upscale — higher resolution gives ML Kit OCR more to work with.
  static const double _scale = 2.0;

  /// Cap on the longest rendered edge (px). Bounds memory on very large pages
  /// while staying comfortably legible for OCR (ML Kit guidance ~≤1920–2048).
  static const double _maxEdgePx = 2400;

  @override
  Future<String> renderPageToImage(String path, int pageIndex) async {
    final document = await PdfDocument.openFile(path);
    try {
      // pdfx page numbers are 1-based; our seam is 0-based.
      final page = await document.getPage(pageIndex + 1);
      try {
        // Upscale 2x for OCR legibility, but cap the longest edge so a huge
        // page can't blow up memory.
        final longestEdge = math.max(page.width, page.height);
        final scale = math.min(_scale, _maxEdgePx / longestEdge);
        final image = await page.render(
          width: page.width * scale,
          height: page.height * scale,
          format: PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );
        if (image == null) {
          throw const PdfPageRasterizerUnavailableException();
        }
        final dir = await getTemporaryDirectory();
        final file = File(
          p.join(
            dir.path,
            'pdf_page_${pageIndex + 1}_'
            '${DateTime.now().microsecondsSinceEpoch}.png',
          ),
        );
        await file.writeAsBytes(image.bytes, flush: true);
        return file.path;
      } finally {
        await page.close();
      }
    } finally {
      await document.close();
    }
  }
}
