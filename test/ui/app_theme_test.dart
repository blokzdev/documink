import 'package:documink/ui/theme/app_colors.dart';
import 'package:documink/ui/theme/app_theme.dart';
import 'package:documink/features/detection/pii_span.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    for (final entry in {
      'light': AppTheme.lightTheme,
      'dark': AppTheme.darkTheme,
    }.entries) {
      test('${entry.key} theme has the centralized component themes', () {
        final t = entry.value;
        expect(t.useMaterial3, isTrue);
        expect(t.cardTheme, isA<CardThemeData>());
        expect(t.cardTheme.margin, EdgeInsets.zero);
        expect(t.inputDecorationTheme.filled, isTrue);
        expect(t.appBarTheme.centerTitle, isFalse);
        expect(t.dialogTheme, isA<DialogThemeData>());
        expect(t.snackBarTheme.behavior, SnackBarBehavior.floating);
      });
    }

    test('light and dark derive from the indigo brand seed', () {
      expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
      expect(AppTheme.lightTheme.colorScheme.secondary, AppColors.accent);
    });
  });

  group('entity colours', () {
    test('same semantic group shares a colour; groups differ', () {
      expect(
        AppColors.entityColor(PiiLabels.email),
        AppColors.entityColor(PiiLabels.phone),
      );
      expect(
        AppColors.entityColor(PiiLabels.person),
        isNot(AppColors.entityColor(PiiLabels.email)),
      );
    });

    test('known labels are mapped; unknown falls back to slate', () {
      const slate = Color(0xFF64748B);
      expect(AppColors.entityColor(PiiLabels.person), isNot(slate));
      expect(AppColors.entityColor('CUSTOM_THING'), slate);
    });
  });
}
