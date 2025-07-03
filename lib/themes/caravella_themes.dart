import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  // Seed color per generare automaticamente la palette del tema
  static const Color _seedColor = Color(0xFFD8DEE9); // #d8dee9

  // ColorScheme generati automaticamente da Material 3
  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
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
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: lightScheme.surface,
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
      color: lightScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: lightScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: lightScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightScheme.primary,
      foregroundColor: lightScheme.onPrimary,
      elevation: 4,
    ),
    dividerColor: lightScheme.outline.withValues(alpha: 0.2),
    iconTheme: IconThemeData(color: lightScheme.onSurfaceVariant),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(darkScheme),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: darkScheme.surface,
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
      color: darkScheme.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: darkScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkScheme.primary,
        foregroundColor: darkScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkScheme.primary,
      foregroundColor: darkScheme.onPrimary,
      elevation: 4,
    ),
    dividerColor: darkScheme.outline.withValues(alpha: 0.3),
    iconTheme: IconThemeData(color: darkScheme.onSurfaceVariant),
  );
}
