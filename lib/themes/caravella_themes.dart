import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  // Palette colori migliorata
  static const Color _primaryDark = Color(0xFF2D3748);
  static const Color _primaryLight = Color(0xFF4A90E2);
  static const Color _accent = Color(0xFF68D391);

  // Colori di superficie ottimizzati
  static const Color _surfaceLight = Color(0xFFFAFAFA);
  static const Color _surfaceDark = Color(0xFF1E2328);
  static const Color _surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color _surfaceContainerDark = Color(0xFF2A3038);

  // Background migliorati
  static const Color _backgroundLight = Color(0xFFF5F5F5);
  static const Color _backgroundDark = Color(0xFF161A1E);

  // Errore
  static const Color _errorLight = Color(0xFFE53E3E);
  static const Color _errorDark = Color(0xFFFF6B6B);

  static final ColorScheme lightScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: _primaryDark,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE3F2FD),
    onPrimaryContainer: _primaryDark,
    secondary: Color(0xFF4A5568),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE2E8F0),
    onSecondaryContainer: Color(0xFF2D3748),
    tertiary: _accent,
    onTertiary: Colors.white,
    error: _errorLight,
    onError: Colors.white,
    surface: _surfaceLight,
    onSurface: _primaryDark,
    surfaceContainer: _surfaceContainerLight,
    onSurfaceVariant: Color(0xFF6B7280),
    outline: Color(0xFFD1D5DB),
    shadow: Color(0xFF000000),
  );

  static final ColorScheme darkScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryLight,
    onPrimary: Color(0xFF1A1D23),
    primaryContainer: Color(0xFF2A5A8A),
    onPrimaryContainer: Color(0xFFB3D4FC),
    secondary: Color(0xFF8B9DC3),
    onSecondary: Color(0xFF1A1D23),
    secondaryContainer: Color(0xFF3A4A5C),
    onSecondaryContainer: Color(0xFFB8C5D1),
    tertiary: _accent,
    onTertiary: Color(0xFF1A1D23),
    error: _errorDark,
    onError: Color(0xFF1A1D23),
    surface: _surfaceDark,
    onSurface: Color(0xFFE8EAED),
    surfaceContainer: _surfaceContainerDark,
    onSurfaceVariant: Color(0xFFBDC1C6),
    outline: Color(0xFF5F6368),
    shadow: Color(0xFF000000),
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
    scaffoldBackgroundColor: _backgroundLight,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceLight,
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
      color: _surfaceContainerLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: lightScheme.outline.withValues(alpha: 0.12),
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
          borderRadius: BorderRadius.circular(12),
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
    scaffoldBackgroundColor: _backgroundDark,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceDark,
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
      color: _surfaceContainerDark,
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
          borderRadius: BorderRadius.circular(12),
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
