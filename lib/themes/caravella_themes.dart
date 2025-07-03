import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  // === COLORI NORD UFFICIALI ===
  // Polar Night (Palette scura) - per dark theme
  static const Color nord0 = Color(0xFF2E3440); // Base background scuro
  static const Color nord1 = Color(0xFF3B4252); // Elevated surfaces scure
  static const Color nord2 = Color(0xFF434C5E); // Selection background
  static const Color nord3 = Color(0xFF4C566A); // Comments, disabled elements

  // Snow Storm (Palette chiara) - per light theme
  static const Color nord4 = Color(0xFFD8DEE9); // Subtle text, borders
  static const Color nord5 = Color(0xFFE5E9F0); // Base text, primary elements
  static const Color nord6 = Color(0xFFECEFF4); // Pure text, backgrounds

  // Frost (Palette blu) - accenti principali
  static const Color nord7 = Color(0xFF8FBCBB); // Teal calm
  static const Color nord8 = Color(0xFF88C0D0); // Blue bright - PRIMARY
  static const Color nord9 = Color(0xFF81A1C1); // Blue muted
  static const Color nord10 = Color(0xFF5E81AC); // Blue deep

  // Aurora (Palette colorata) - accenti secondari
  static const Color nord11 = Color(0xFFBF616A); // Red - errori
  static const Color nord12 = Color(0xFFD08770); // Orange - warning
  static const Color nord13 = Color(0xFFEBCB8B); // Yellow - warning soft
  static const Color nord14 = Color(0xFFA3BE8C); // Green - success
  static const Color nord15 = Color(0xFFB48EAD); // Purple - special

  // Light Theme - Snow Storm + Frost + Aurora
  static final ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary usando Nord Frost Blue
    primary: nord8, // Bright blue per azioni principali
    onPrimary: nord0, // Testo scuro su primary
    primaryContainer: nord6, // Container chiaro
    onPrimaryContainer: nord1,

    // Secondary usando Nord Frost Teal
    secondary: nord7, // Teal per elementi secondari
    onSecondary: nord0,
    secondaryContainer: nord6,
    onSecondaryContainer: nord1,

    // Tertiary usando Nord Aurora Green
    tertiary: nord14, // Verde per successo/elementi speciali
    onTertiary: nord0,
    tertiaryContainer: nord6,
    onTertiaryContainer: nord1,

    // Error usando Nord Aurora Red
    error: nord11,
    onError: nord6,
    errorContainer: nord6,
    onErrorContainer: nord11,

    // Surfaces usando Snow Storm
    surface: nord6, // Background principale
    onSurface: nord0, // Testo principale
    surfaceContainerLowest: nord6,
    surfaceContainerLow: nord5,
    surfaceContainer: nord5, // Card e container
    surfaceContainerHigh: nord4,
    surfaceContainerHighest: nord4,
    onSurfaceVariant: nord3, // Testo secondario

    // Outline e utilità
    outline: nord3,
    outlineVariant: nord4,
    shadow: nord0,
    scrim: nord0,
    inverseSurface: nord0,
    onInverseSurface: nord6,
    inversePrimary: nord8,
  );

  // Dark Theme - Polar Night + Frost + Aurora
  static final ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary usando Nord Frost Blue
    primary: nord8, // Stesso blue, ma su sfondo scuro
    onPrimary: nord0,
    primaryContainer: nord1, // Container scuri
    onPrimaryContainer: nord6,

    // Secondary usando Nord Frost Teal
    secondary: nord7,
    onSecondary: nord0,
    secondaryContainer: nord1,
    onSecondaryContainer: nord6,

    // Tertiary usando Nord Aurora Green
    tertiary: nord14,
    onTertiary: nord0,
    tertiaryContainer: nord1,
    onTertiaryContainer: nord6,

    // Error usando Nord Aurora Red
    error: nord11,
    onError: nord0,
    errorContainer: nord1,
    onErrorContainer: nord11,

    // Surfaces usando Polar Night
    surface: nord0, // Background principale scuro
    onSurface: nord6, // Testo chiaro
    surfaceContainerLowest: nord0,
    surfaceContainerLow: nord1,
    surfaceContainer: nord1, // Card e container
    surfaceContainerHigh: nord2,
    surfaceContainerHighest: nord3,
    onSurfaceVariant: nord4, // Testo secondario

    // Outline e utilità
    outline: nord3,
    outlineVariant: nord2,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: nord6,
    onInverseSurface: nord0,
    inversePrimary: nord8,
  );

  // Overlay styles ottimizzati
  static const SystemUiOverlayStyle lightOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // TextTheme ottimizzato
  static TextTheme _createTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      // Headlines
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontSize: 24,
      ),

      // Titles
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        fontSize: 14,
      ),

      // Body
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),

      // Labels
      labelLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
        fontSize: 11,
      ),
    ).apply(fontFamily: 'Montserrat');
  }

  static final ThemeData light = ThemeData(
    colorScheme: lightScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(lightScheme),
    scaffoldBackgroundColor: nord4, // Background morbido
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: nord6, // AppBar pulita
      foregroundColor: lightScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: lightScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      systemOverlayStyle: lightOverlayStyle,
    ),
    cardTheme: CardThemeData(
      color: nord6, // Card bianche pulite
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: nord4.withValues(alpha: 0.5), // Bordo sottile nord
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        elevation: 2,
        shadowColor: nord0.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightScheme.primary,
      foregroundColor: lightScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerColor: nord4, // Divisori sottili
    iconTheme: IconThemeData(color: lightScheme.onSurfaceVariant),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(darkScheme),
    scaffoldBackgroundColor: nord0, // Background scuro base
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: nord1, // AppBar scura elevated
      foregroundColor: darkScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: darkScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      systemOverlayStyle: darkOverlayStyle,
    ),
    cardTheme: CardThemeData(
      color: nord1, // Card leggermente più chiare del background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: nord2.withValues(alpha: 0.5), // Bordo sottile
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkScheme.primary,
      foregroundColor: darkScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerColor: nord2, // Divisori scuri
    iconTheme: IconThemeData(color: darkScheme.onSurfaceVariant),
  );
}
