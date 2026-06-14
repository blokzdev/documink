import 'image_input_source.dart';
import 'ingested_text.dart';
import 'ocr_recognizer.dart';
import 'pdf_page_rasterizer.dart';
import 'pdf_source.dart';
import 'pdf_text_extractor.dart';
import 'temp_file_disposer.dart';

/// Orchestrates turning a raw input source into [IngestedText] for the redaction
/// pipeline (roadmap Phase 4 — input handlers).
///
/// Pure-Dart and fully unit-testable: the device-only bits (camera/picker, OCR)
/// are injected as seams ([ImageInputSource], [OcrRecognizer]). This is the
/// headless-verifiable orchestration; the native adapters are device-verified
/// (see VERIFICATION.md).
class InputIngestionService {
  InputIngestionService({
    required OcrRecognizer ocr,
    required ImageInputSource imageSource,
    required PdfSource pdfSource,
    required PdfTextExtractor pdfTextExtractor,
    required PdfPageRasterizer pdfPageRasterizer,
    required TempFileDisposer tempFileDisposer,
  }) : _ocr = ocr,
       _imageSource = imageSource,
       _pdfSource = pdfSource,
       _pdfTextExtractor = pdfTextExtractor,
       _pdfPageRasterizer = pdfPageRasterizer,
       _tempFileDisposer = tempFileDisposer;

  final OcrRecognizer _ocr;
  final ImageInputSource _imageSource;
  final PdfSource _pdfSource;
  final PdfTextExtractor _pdfTextExtractor;
  final PdfPageRasterizer _pdfPageRasterizer;
  final TempFileDisposer _tempFileDisposer;

  /// Capture a page with the camera and OCR it. Returns null if the user
  /// cancels the capture; throws [OcrUnavailableException] /
  /// [ImageSourceUnavailableException] when a seam is unwired.
  Future<IngestedText?> captureFromCamera() async {
    final picked = await _imageSource.capturePhoto();
    if (picked == null) return null;
    return _ingestImage(picked, InputSourceKind.cameraScan);
  }

  /// Pick an image from the system photo picker and OCR it. Returns null if the
  /// user cancels.
  Future<IngestedText?> importImage() async {
    final picked = await _imageSource.pickImage();
    if (picked == null) return null;
    return _ingestImage(picked, InputSourceKind.imageImport);
  }

  Future<IngestedText> _ingestImage(
    PickedImage picked,
    InputSourceKind kind,
  ) async {
    final recognized = await _ocr.recognizeImage(picked.path);
    return IngestedText(
      text: recognized,
      source: kind,
      warnings: recognized.trim().isEmpty
          ? const ['No text was recognized in the image.']
          : const [],
    );
  }

  /// Pick a PDF, extract its text layer page-by-page, and OCR any scanned
  /// (text-less) pages by rasterizing them through the existing
  /// [OcrRecognizer]. Returns null if the user cancels.
  ///
  /// Multi-page output is joined with `--- Page N ---` markers; warnings note
  /// which pages were OCR'd and flag a fully-empty extraction.
  Future<IngestedText?> importPdf() async {
    final path = await _pdfSource.pickPdf();
    if (path == null) return null;

    final pages = await _pdfTextExtractor.extractPages(path);
    final multiPage = pages.length > 1;
    final buffer = StringBuffer();
    final ocrPages = <int>[];

    for (var i = 0; i < pages.length; i++) {
      var pageText = pages[i];
      if (pageText.trim().isEmpty) {
        // Scanned / image-only page — rasterize and OCR it. The rendered PNG
        // holds PII, so delete it as soon as OCR is done (even on failure):
        // it's throwaway scaffolding and must not linger in the cache.
        final imagePath = await _pdfPageRasterizer.renderPageToImage(path, i);
        try {
          pageText = await _ocr.recognizeImage(imagePath);
        } finally {
          await _tempFileDisposer.dispose(imagePath);
        }
        if (pageText.trim().isNotEmpty) ocrPages.add(i + 1);
      }
      if (multiPage) buffer.writeln('--- Page ${i + 1} ---');
      buffer.writeln(pageText.trim());
    }

    final text = buffer.toString().trim();
    final warnings = <String>[
      if (ocrPages.isNotEmpty)
        'Page${ocrPages.length == 1 ? '' : 's'} ${ocrPages.join(', ')} '
            '${ocrPages.length == 1 ? 'was' : 'were'} scanned — used OCR.',
      if (text.isEmpty) 'No text could be extracted from the PDF.',
    ];

    return IngestedText(
      text: text,
      source: InputSourceKind.pdfImport,
      pageCount: pages.length,
      warnings: warnings,
    );
  }
}
