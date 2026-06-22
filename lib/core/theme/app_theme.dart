import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: Colors.indigo,
  );
}
