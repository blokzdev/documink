import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ingested_text.dart';
import 'input_exceptions.dart';
import 'input_ingestion_service.dart';
import 'input_providers.dart';

enum CaptureStatus { idle, working, ready, error }

/// State of a single capture/import attempt on the capture screen.
class CaptureState {
  const CaptureState({
    this.status = CaptureStatus.idle,
    this.result,
    this.error,
  });

  final CaptureStatus status;

  /// The ingested text once [CaptureStatus.ready].
  final IngestedText? result;

  /// User-facing message once [CaptureStatus.error].
  final String? error;
}

final captureControllerProvider =
    NotifierProvider<CaptureController, CaptureState>(CaptureController.new);

/// Drives camera-scan / image-import through [InputIngestionService] and exposes
/// a small state machine (idle → working → ready/error) for the capture screen.
/// A cancelled pick returns to idle; an unwired/failed seam surfaces as error.
class CaptureController extends Notifier<CaptureState> {
  @override
  CaptureState build() => const CaptureState();

  /// Capture a page with the camera and OCR it.
  Future<void> scan() => _run((s) => s.captureFromCamera());

  /// Pick an image from the system picker and OCR it.
  Future<void> importImage() => _run((s) => s.importImage());

  /// Pick a PDF and extract its text (OCR'ing any scanned pages).
  Future<void> importPdf() => _run((s) => s.importPdf());

  void reset() => state = const CaptureState();

  Future<void> _run(
    Future<IngestedText?> Function(InputIngestionService service) op,
  ) async {
    state = const CaptureState(status: CaptureStatus.working);
    try {
      final result = await op(ref.read(inputIngestionServiceProvider));
      if (result == null) {
        // User cancelled the camera / picker.
        state = const CaptureState();
        return;
      }
      state = CaptureState(status: CaptureStatus.ready, result: result);
    } catch (e) {
      // Our seam exceptions carry safe, user-facing messages; anything else
      // (e.g. a raw native PlatformException) gets a generic fallback so we
      // never surface internals.
      final message = e is InputUnavailableException
          ? e.toString()
          : 'Something went wrong. Please try again.';
      state = CaptureState(status: CaptureStatus.error, error: message);
    }
  }
}
