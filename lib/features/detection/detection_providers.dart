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

/// The registered detectors. Tier 1 structured/checksum recognizers landed in
/// 2b; Tier 1 heuristic/locale (date, MRN, passport) in 2c; phone in 2d. Tier 2
/// ML Kit and Tier 3 GLiNER ONNX register next.
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
