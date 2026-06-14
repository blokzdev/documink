import 'dart:async';

import 'package:documink/features/input/image_input_source.dart';
import 'package:documink/features/input/input_ingestion_service.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/pdf_page_rasterizer.dart';
import 'package:documink/features/input/pdf_source.dart';
import 'package:documink/features/input/pdf_text_extractor.dart';
import 'package:documink/features/input/share_intent_coordinator.dart';
import 'package:documink/features/input/share_intent_receiver.dart';
import 'package:documink/features/input/temp_file_disposer.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeOcr implements OcrRecognizer {
  _FakeOcr(this._text);
  final String _text;
  @override
  Future<String> recognizeImage(String imagePath) async => _text;
}

// Unused seams for the ingestion service in these tests.
class _NoImageSource implements ImageInputSource {
  @override
  Future<PickedImage?> capturePhoto() async => null;
  @override
  Future<PickedImage?> pickImage() async => null;
}

class _NoPdfSource implements PdfSource {
  @override
  Future<String?> pickPdf() async => null;
}

class _NoPdfText implements PdfTextExtractor {
  @override
  Future<List<String>> extractPages(String path) async => const [];
}

class _NoRaster implements PdfPageRasterizer {
  @override
  Future<String> renderPageToImage(String path, int pageIndex) async => '';
}

class _NoDisposer implements TempFileDisposer {
  @override
  Future<void> dispose(String path) async {}
}

InputIngestionService _ingestion({OcrRecognizer? ocr}) => InputIngestionService(
  ocr: ocr ?? _FakeOcr(''),
  imageSource: _NoImageSource(),
  pdfSource: _NoPdfSource(),
  pdfTextExtractor: _NoPdfText(),
  pdfPageRasterizer: _NoRaster(),
  tempFileDisposer: _NoDisposer(),
);

class _FakeReceiver implements ShareIntentReceiver {
  _FakeReceiver({this.initial, Stream<SharedInput>? stream})
    : _stream = stream ?? const Stream.empty();
  final SharedInput? initial;
  final Stream<SharedInput> _stream;
  @override
  Future<SharedInput?> initialShare() async => initial;
  @override
  Stream<SharedInput> shareStream() => _stream;
}

void main() {
  test('routes shared text to the editor when unlocked', () async {
    final navigated = <String>[];
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(
        initial: const SharedInput(kind: SharedInputKind.text, value: 'hi PII'),
      ),
      ingestion: _ingestion(),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    await c.start();

    expect(navigated, ['hi PII']);
    await c.dispose();
  });

  test('holds a share received while locked, flushes on unlock', () async {
    final navigated = <String>[];
    var unlocked = false;
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(
        initial: const SharedInput(kind: SharedInputKind.text, value: 'secret'),
      ),
      ingestion: _ingestion(),
      isUnlocked: () => unlocked,
      navigateToEditor: navigated.add,
    );

    await c.start();
    expect(navigated, isEmpty); // held while locked

    unlocked = true;
    c.onUnlocked();
    expect(navigated, ['secret']);
    await c.dispose();
  });

  test('OCRs a shared image before routing', () async {
    final navigated = <String>[];
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(
        initial: const SharedInput(
          kind: SharedInputKind.image,
          value: '/tmp/x.jpg',
        ),
      ),
      ingestion: _ingestion(ocr: _FakeOcr('text from image')),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    await c.start();

    expect(navigated, ['text from image']);
    await c.dispose();
  });

  test('routes shares delivered on the runtime stream', () async {
    final navigated = <String>[];
    final controller = StreamController<SharedInput>();
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(stream: controller.stream),
      ingestion: _ingestion(),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    await c.start();
    controller.add(
      const SharedInput(kind: SharedInputKind.text, value: 'streamed'),
    );
    await Future<void>.delayed(Duration.zero); // let the stream event process

    expect(navigated, ['streamed']);
    await controller.close();
    await c.dispose();
  });

  test('onUnlocked with no pending share is a no-op', () async {
    final navigated = <String>[];
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(),
      ingestion: _ingestion(),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    await c.start();
    c.onUnlocked();

    expect(navigated, isEmpty);
    await c.dispose();
  });
}
