import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  static final ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF2D3748), // Grigio scuro elegante invece di nero
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF4A5568), // Grigio medio per accenti
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFE53E3E), // Rosso più soft
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA), // Off-white molto soft
    onSurface: Color(0xFF2D3748),
    surfaceContainerHighest:
        Color(0xFFF7FAFC), // Grigio chiarissimo per background
  );

  static final ColorScheme darkScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE2E8F0), // Grigio chiaro invece di bianco puro
    onPrimary: Color(0xFF1A202C),
    secondary: Color(0xFFA0AEC0), // Grigio medio-chiaro
    onSecondary: Color(0xFF1A202C),
    error: Color(0xFFFC8181), // Rosso più soft per dark mode
    onError: Color(0xFF1A202C),
    surface: Color(0xFF1A202C), // Grigio scuro invece di nero
    onSurface: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFF2D3748), // Grigio medio per background
  );

  static final ThemeData light = ThemeData(
    colorScheme: lightScheme,
    fontFamily: 'Montserrat',
    textTheme: ThemeData.light()
        .textTheme
        .apply(
          fontFamily: 'Montserrat',
          bodyColor: const Color(0xFF2D3748), // Grigio scuro invece di nero
          displayColor: const Color(0xFF2D3748),
        )
        .copyWith(
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
    scaffoldBackgroundColor: const Color(0xFF65CCED), // Background azzurro
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF65CCED), // AppBar azzurro
      foregroundColor: Color(0xFF2D3748), // Testo grigio scuro
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF65CCED), // Status bar azzurra
        statusBarIconBrightness: Brightness.dark, // Icone scure per contrasto
        statusBarBrightness: Brightness.light, // Per iOS
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFF2D3748), // FAB grigio scuro
      foregroundColor: const Color(0xFFFFFFFF),
    ),
    dividerColor: const Color(0xFFE2E8F0), // Divider soft
    cardColor: const Color(0xFFFAFAFA), // Card soft
    iconTheme:
        const IconThemeData(color: Color(0xFF4A5568)), // Icone grigio medio
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: ThemeData.dark()
        .textTheme
        .apply(
          fontFamily: 'Montserrat',
          bodyColor: const Color(0xFFE2E8F0), // Grigio chiaro invece di bianco
          displayColor: const Color(0xFFE2E8F0),
        )
        .copyWith(
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
    scaffoldBackgroundColor: const Color(0xFF65CCED), // Background azzurro anche per dark mode
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF65CCED), // AppBar azzurro anche per dark mode
      foregroundColor: Color(0xFF2D3748), // Testo grigio scuro per contrasto
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF65CCED), // Status bar azzurra
        statusBarIconBrightness: Brightness.dark, // Icone scure per contrasto
        statusBarBrightness: Brightness.light, // Per iOS
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE2E8F0), // FAB grigio chiaro
      foregroundColor: Color(0xFF1A202C), // Testo scuro
    ),
    dividerColor: const Color(0xFF4A5568), // Divider grigio medio
    cardColor: const Color(0xFF2D3748), // Card grigio medio
    iconTheme:
        const IconThemeData(color: Color(0xFFA0AEC0)), // Icone grigio chiaro
  );
}
