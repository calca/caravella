import 'package:flutter/material.dart';

class CaravellaThemes {
  static final ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.black,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  );

  static final ColorScheme darkScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.white,
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.black,
    surface: Colors.black,
    onSurface: Colors.white,
  );

  static final ThemeData light = ThemeData.from(
    colorScheme: lightScheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black54),
      titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    ),
  ).copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    dividerColor: Colors.black12,
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black),
  );

  static final ThemeData dark = ThemeData.from(
    colorScheme: darkScheme,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ).copyWith(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    dividerColor: Colors.white10,
    cardColor: Colors.grey,
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
