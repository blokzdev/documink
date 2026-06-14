import 'input_exceptions.dart';

/// Picks a PDF document from the system file picker.
///
/// Device-only in production (`file_selector` opens native UI). Behind this
/// interface so [InputIngestionService] is unit-testable with a fake. Returns
/// the picked file's path, or null if the user cancels.
abstract interface class PdfSource {
  Future<String?> pickPdf();
}

/// Thrown when PDF picking is requested but no platform source was wired (the
/// safe default).
class PdfSourceUnavailableException implements InputUnavailableException {
  const PdfSourceUnavailableException();

  @override
  String toString() => 'PDF import is not available on this device.';
}

/// Safe default [PdfSource] — fails loudly until the real source is composed at
/// bootstrap.
class UnavailablePdfSource implements PdfSource {
  const UnavailablePdfSource();

  @override
  Future<String?> pickPdf() async =>
      throw const PdfSourceUnavailableException();
}
