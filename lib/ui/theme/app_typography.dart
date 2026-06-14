import 'package:flutter/material.dart';

/// The app type scale, crafted on the platform font (offline, no font assets) —
/// stronger hierarchy via tuned weight / letter-spacing / line-height — plus a
/// monospace style for redaction output and surrogates.
class AppTypography {
  const AppTypography._();

  /// Platform monospace family for redacted text / token surrogates.
  static const String monoFamily = 'monospace';

  static TextTheme textTheme(TextTheme base) => base.copyWith(
    displaySmall: base.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: base.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
  );

  /// A monospace style derived from the current body style — for redaction
  /// previews and token surrogates.
  static TextStyle mono(BuildContext context) =>
      (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontFamily: monoFamily,
        height: 1.5,
      );
}
