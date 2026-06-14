import 'dart:async';

import 'package:documink/features/input/input_ingestion_service.dart';
import 'package:documink/features/input/ocr_recognizer.dart';
import 'package:documink/features/input/share_intent_coordinator.dart';
import 'package:documink/features/input/share_intent_receiver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/input_fakes.dart';

/// A receiver whose initialShare() throws (a malformed cold-start intent).
class _ThrowingReceiver implements ShareIntentReceiver {
  @override
  Future<SharedInput?> initialShare() async => throw StateError('bad intent');
  @override
  Stream<SharedInput> shareStream() => const Stream.empty();
}

InputIngestionService _ingestion({OcrRecognizer? ocr}) => InputIngestionService(
  ocr: ocr ?? FakeOcr(''),
  imageSource: FakeImageSource(),
  pdfSource: FakePdfSource(null),
  pdfTextExtractor: FakePdfTextExtractor(const []),
  pdfPageRasterizer: FakeRasterizer(),
  tempFileDisposer: FakeDisposer(),
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
      ingestion: _ingestion(ocr: FakeOcr('text from image')),
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

  test('a shared-image OCR failure is dropped, never crashes', () async {
    final navigated = <String>[];
    final c = ShareIntentCoordinator(
      receiver: _FakeReceiver(
        initial: const SharedInput(
          kind: SharedInputKind.image,
          value: '/tmp/x.jpg',
        ),
      ),
      ingestion: _ingestion(ocr: FakeOcr('', throwError: true)),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    // Must complete without throwing; nothing routed.
    await c.start();
    expect(navigated, isEmpty);
    await c.dispose();
  });

  test('a throwing initialShare() is swallowed', () async {
    final navigated = <String>[];
    final c = ShareIntentCoordinator(
      receiver: _ThrowingReceiver(),
      ingestion: _ingestion(),
      isUnlocked: () => true,
      navigateToEditor: navigated.add,
    );

    await c.start(); // does not throw
    expect(navigated, isEmpty);
    await c.dispose();
  });
}
