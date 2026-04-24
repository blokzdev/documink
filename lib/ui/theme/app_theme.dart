import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF1E3A8A); // ink-blue

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
      useMaterial3: true,
    );
  }
}