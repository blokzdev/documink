import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detection_pipeline.dart';
import 'pii_recognizer.dart';
import 'recognizers/credit_card_recognizer.dart';
import 'recognizers/email_recognizer.dart';
import 'recognizers/iban_recognizer.dart';
import 'recognizers/ip_address_recognizer.dart';
import 'recognizers/ssn_recognizer.dart';
import 'recognizers/url_recognizer.dart';

/// The registered detectors. Tier 1 structured/checksum recognizers land in 2b;
/// Tier 1 heuristic/locale (phone, date, MRN, passport) in 2c; Tier 2 ML Kit in
/// 2d; Tier 3 GLiNER ONNX in 2e.
final piiRecognizersProvider = Provider<List<PiiRecognizer>>((ref) {
  return [
    EmailRecognizer(),
    UrlRecognizer(),
    IpAddressRecognizer(),
    SsnRecognizer(),
    CreditCardRecognizer(),
    IbanRecognizer(),
  ];
});

/// The assembled detection pipeline (normalize → recognize → resolve).
final detectionPipelineProvider = Provider<DetectionPipeline>((ref) {
  return DetectionPipeline(ref.watch(piiRecognizersProvider));
});
