import 'package:flutter/material.dart';

import '../../features/detection/pii_span.dart';

/// DocuMink's brand colours and the per-entity-type colour system.
///
/// Direction: **Ink Indigo** — a deep indigo primary with a teal accent and
/// slate neutrals; trustworthy, calm, privacy-first; dark mode first-class.
class AppColors {
  const AppColors._();

  /// Brand primary (indigo) — the seed for both light and dark schemes.
  static const Color brand = Color(0xFF4F46E5);

  /// Brand accent (teal) — secondary actions / highlights.
  static const Color accent = Color(0xFF0D9488);

  static ColorScheme light() => ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.light,
  ).copyWith(secondary: accent);

  static ColorScheme dark() => ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.dark,
  ).copyWith(secondary: accent);

  // --- Entity-type colour system ----------------------------------------
  // The 13 built-in PII labels grouped into semantic hues, used for the
  // colour-coded entity chips. Contrast is handled by the chip (tonal bg +
  // tone-mapped foreground), so these are mid-tone hues that read in both modes.
  static const Color _indigo = Color(0xFF4F46E5); // identity
  static const Color _teal = Color(0xFF0D9488); // contact
  static const Color _amber = Color(0xFFD97706); // financial
  static const Color _red = Color(0xFFDC2626); // government id
  static const Color _rose = Color(0xFFE11D48); // health
  static const Color _green = Color(0xFF16A34A); // location
  static const Color _violet = Color(0xFF7C3AED); // temporal
  static const Color _cyan = Color(0xFF0891B2); // network
  static const Color _slate = Color(0xFF64748B); // unknown / custom

  static const Map<String, Color> _entity = {
    PiiLabels.person: _indigo,
    PiiLabels.email: _teal,
    PiiLabels.phone: _teal,
    PiiLabels.creditCard: _amber,
    PiiLabels.iban: _amber,
    PiiLabels.ssn: _red,
    PiiLabels.passport: _red,
    PiiLabels.mrn: _rose,
    PiiLabels.url: _cyan,
    PiiLabels.ipAddress: _cyan,
    PiiLabels.date: _violet,
    PiiLabels.dateOfBirth: _violet,
    PiiLabels.location: _green,
  };

  /// The hue for an entity [label] (custom/unknown types fall back to slate).
  static Color entityColor(String label) => _entity[label] ?? _slate;
}
