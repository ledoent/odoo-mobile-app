import 'package:flutter/material.dart';

/// Warehouse-floor theme: big touch targets, high contrast, no subtlety.
ThemeData buildScannerTheme() {
  final base = ThemeData(
    colorSchemeSeed: const Color(0xFF714B67), // Odoo plum
    brightness: Brightness.light,
    useMaterial3: true,
  );
  return base.copyWith(
    visualDensity: VisualDensity.comfortable,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 14),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
