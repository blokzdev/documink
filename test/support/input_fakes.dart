import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_page_rasterizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:documink/features/input/temp_file_disposer.dart';

/// Shared in-memory fakes for the input-ingestion seams, used across the
/// capture-controller, ingestion-service, and share-intent tests. Each fake is
/// deterministic and records what it was asked to do, so tests can assert on
/// side effects (which paths were OCR'd, which pages rasterized, which temp
/// files disposed) without touching the real platform plugins.

/// OCR that returns a fixed string (or throws [OcrUnavailableException]) and
/// records every path it was handed.
class FakeOcr implements OcrRecognizer {
  FakeOcr(this._text, {this.throwError = false});
  final String _text;
  final bool throwError;
  final List<String> calls = [];

  @override
  Future<String> recognizeImage(String imagePath) async {
    calls.add(imagePath);
    if (throwError) throw const OcrUnavailableException();
    return _text;
  }
}

/// Image source returning a fixed pick (or null = cancelled). [pick] is a
/// convenience that seeds both the camera and gallery results at once.
class FakeImageSource implements ImageInputSource {
  FakeImageSource({
    PickedImage? camera,
    PickedImage? gallery,
    PickedImage? pick,
  }) : camera = camera ?? pick,
       gallery = gallery ?? pick;
  final PickedImage? camera;
  final PickedImage? gallery;

  @override
  Future<PickedImage?> capturePhoto() async => camera;

  @override
  Future<PickedImage?> pickImage() async => gallery;
}

/// PDF source returning a fixed picked path (or null = cancelled).
class FakePdfSource implements PdfSource {
  FakePdfSource(this._path);
  final String? _path;
  @override
  Future<String?> pickPdf() async => _path;
}

/// PDF text-layer extractor returning a fixed list of per-page strings.
class FakePdfTextExtractor implements PdfTextExtractor {
  FakePdfTextExtractor(this._pages);
  final List<String> _pages;
  @override
  Future<List<String>> extractPages(String path) async => _pages;
}

/// Rasterizer that records which page indices were rendered and returns a
/// synthetic image path per page.
class FakeRasterizer implements PdfPageRasterizer {
  final List<int> rendered = [];
  @override
  Future<String> renderPageToImage(String path, int pageIndex) async {
    rendered.add(pageIndex);
    return '/tmp/page_$pageIndex.png';
  }
}

/// Disposer that records the temp files it was asked to delete (no real I/O).
class FakeDisposer implements TempFileDisposer {
  final List<String> disposed = [];
  @override
  Future<void> dispose(String path) async => disposed.add(path);
}
