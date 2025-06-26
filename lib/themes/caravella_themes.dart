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

  static final ThemeData light = ThemeData(
    colorScheme: lightScheme,
    fontFamily: 'Montserrat',
    textTheme: ThemeData.light().textTheme.apply(
      fontFamily: 'Montserrat',
      bodyColor: Colors.black,
      displayColor: Colors.black,
    ).copyWith(
      bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
      bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
      bodySmall: const TextStyle(fontWeight: FontWeight.w300),
      titleLarge: const TextStyle(fontWeight: FontWeight.w300),
      titleMedium: const TextStyle(fontWeight: FontWeight.w300),
      titleSmall: const TextStyle(fontWeight: FontWeight.w300),
      labelLarge: const TextStyle(fontWeight: FontWeight.w300),
      labelMedium: const TextStyle(fontWeight: FontWeight.w300),
      labelSmall: const TextStyle(fontWeight: FontWeight.w300),
    ),
    useMaterial3: true,
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

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'Montserrat',
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ).copyWith(
      bodyLarge: const TextStyle(fontWeight: FontWeight.w300),
      bodyMedium: const TextStyle(fontWeight: FontWeight.w300),
      bodySmall: const TextStyle(fontWeight: FontWeight.w300),
      titleLarge: const TextStyle(fontWeight: FontWeight.w300),
      titleMedium: const TextStyle(fontWeight: FontWeight.w300),
      titleSmall: const TextStyle(fontWeight: FontWeight.w300),
      labelLarge: const TextStyle(fontWeight: FontWeight.w300),
      labelMedium: const TextStyle(fontWeight: FontWeight.w300),
      labelSmall: const TextStyle(fontWeight: FontWeight.w300),
    ),
    useMaterial3: true,
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
