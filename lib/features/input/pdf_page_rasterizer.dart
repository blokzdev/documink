import 'input_exceptions.dart';

/// Renders a single PDF page to a temporary image file for OCR.
///
/// The returned path feeds the **existing** `OcrRecognizer.recognizeImage`
/// unchanged — that's why the seam yields a file path rather than bytes, so a
/// scanned PDF page reuses the same OCR pipeline as a captured photo.
/// Device-only in production (`pdfx` native rendering); faked in tests.
abstract interface class PdfPageRasterizer {
  /// Renders the page at zero-based [pageIndex] of the PDF at [path] to a temp
  /// image file and returns its path.
  Future<String> renderPageToImage(String path, int pageIndex);
}

/// Thrown when rasterization is requested but no platform rasterizer was wired
/// (the safe default).
class PdfPageRasterizerUnavailableException
    implements InputUnavailableException {
  const PdfPageRasterizerUnavailableException();

  @override
  String toString() => 'PDF page rendering is not available on this device.';
}

/// Safe default [PdfPageRasterizer] — fails loudly until the real rasterizer is
/// composed at bootstrap.
class UnavailablePdfPageRasterizer implements PdfPageRasterizer {
  const UnavailablePdfPageRasterizer();

  @override
  Future<String> renderPageToImage(String path, int pageIndex) async =>
      throw const PdfPageRasterizerUnavailableException();
}
