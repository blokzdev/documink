import 'package:flutter/widgets.dart';

/// Design tokens — the spacing/radius/motion scale the whole app draws from.
/// Keep raw magic numbers out of widgets; reach for these instead.
class AppTokens {
  const AppTokens._();

  // Spacing scale (4-pt base).
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // Corner radii.
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 28;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius fieldRadius = BorderRadius.all(
    Radius.circular(radiusMd),
  );

  // Motion.
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 250);

  // Layout.
  static const double maxContentWidth = 560;
  static const double minTouchTarget = 48;
}
