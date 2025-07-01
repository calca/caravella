import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  // Colori principali dell'app
  static const Color _primaryDark = Color(0xFF2D3748);
  static const Color _primaryLight = Color(0xFFE2E8F0);
  static const Color _surfaceLight = Color(0xFFFAFAFA);
  static const Color _surfaceDark = Color(0xFF1A202C);
  static const Color _backgroundLight =
      Color(0xFFF5F5F5); // Nuovo background grigio chiaro
  static const Color _backgroundDark = Color(0xFF1A202C);
  static const Color _errorRed = Color(0xFFE53E3E);

  static final ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: _primaryDark,
    onPrimary: Colors.white,
    secondary: Color(0xFF4A5568),
    onSecondary: Colors.white,
    error: _errorRed,
    onError: Colors.white,
    surface: _surfaceLight,
    onSurface: _primaryDark,
    surfaceContainerHighest: _backgroundLight,
  );

  static final ColorScheme darkScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryLight,
    onPrimary: _surfaceDark,
    secondary: Color(0xFFA0AEC0),
    onSecondary: _surfaceDark,
    error: Color(0xFFFC8181),
    onError: _surfaceDark,
    surface: _surfaceDark,
    onSurface: _primaryLight,
    surfaceContainerHighest: Color(0xFF2D3748),
  );

  // Sistema UI overlay style condiviso
  static const SystemUiOverlayStyle _lightOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle _darkOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // TextTheme base condiviso
  static TextTheme _createTextTheme(Color textColor) {
    return TextTheme(
      headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: textColor), // Bold per titoli principali
      bodyLarge: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      bodyMedium: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      bodySmall: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor), // Semi-bold per pulsanti
      titleMedium: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      titleSmall: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      labelLarge: TextStyle(
          fontWeight: FontWeight.w600, color: textColor), // Semi-bold per label
      labelMedium: TextStyle(fontWeight: FontWeight.w300, color: textColor),
      labelSmall: TextStyle(fontWeight: FontWeight.w300, color: textColor),
    ).apply(fontFamily: 'Montserrat');
  }

  static final ThemeData light = ThemeData(
    colorScheme: lightScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(_primaryDark),
    scaffoldBackgroundColor: _backgroundLight,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceLight,
      foregroundColor: _primaryDark,
      elevation: 0,
      systemOverlayStyle: _lightOverlayStyle,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryDark,
      foregroundColor: Colors.white,
    ),
    dividerColor: const Color(0xFFE2E8F0),
    cardColor: _surfaceLight,
    iconTheme: const IconThemeData(color: Color(0xFF4A5568)),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(_primaryLight),
    scaffoldBackgroundColor: _backgroundDark,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceDark,
      foregroundColor: _primaryLight,
      elevation: 0,
      systemOverlayStyle: _darkOverlayStyle,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryLight,
      foregroundColor: _surfaceDark,
    ),
    dividerColor: const Color(0xFF4A5568),
    cardColor: const Color(0xFF2D3748),
    iconTheme: const IconThemeData(color: Color(0xFFA0AEC0)),
  );
}
