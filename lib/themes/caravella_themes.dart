import 'package:flutter/material.dart';

class CaravellaThemes {
  static final Color seed = const Color(0xFF4FC3F7);

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: seed,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: seed,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    appBarTheme: AppBarTheme(
      backgroundColor: seed.withValues(alpha: 0.9),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: seed,
      foregroundColor: Colors.white,
    ),
  );
}
