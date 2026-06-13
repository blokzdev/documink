import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'detection_pipeline.dart';
import 'pii_recognizer.dart';
import 'recognizers/credit_card_recognizer.dart';
import 'recognizers/date_recognizer.dart';
import 'recognizers/email_recognizer.dart';
import 'recognizers/iban_recognizer.dart';
import 'recognizers/ip_address_recognizer.dart';
import 'recognizers/mrn_recognizer.dart';
import 'recognizers/passport_recognizer.dart';
import 'recognizers/phone_recognizer.dart';
import 'recognizers/ssn_recognizer.dart';
import 'recognizers/url_recognizer.dart';

/// The registered detectors. Tier 1 (§4.2) is complete and pure-Dart, so it is
/// the default set here. Tier 2 (`MlKitEntityRecognizer`) and Tier 3 (GLiNER)
/// need native runtimes / a downloaded model, so they are **composed in at
/// bootstrap** (Phase 5) on capable devices rather than listed here — keeping
/// this provider usable in headless tests.
final piiRecognizersProvider = Provider<List<PiiRecognizer>>((ref) {
  return [
    // Tier 1 — structured / checksum (2b)
    EmailRecognizer(),
    UrlRecognizer(),
    IpAddressRecognizer(),
    SsnRecognizer(),
    CreditCardRecognizer(),
    IbanRecognizer(),
    // Tier 1 — heuristic / locale (2c)
    DateRecognizer(),
    MrnRecognizer(),
    PassportRecognizer(),
    // Tier 1 — phone (2d)
    PhoneRecognizer(),
  ];
});

/// The assembled detection pipeline (normalize → recognize → resolve).
final detectionPipelineProvider = Provider<DetectionPipeline>((ref) {
  return DetectionPipeline(ref.watch(piiRecognizersProvider));
});
