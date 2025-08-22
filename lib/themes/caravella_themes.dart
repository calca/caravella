import 'package:flutter/material.dart';

// https://rydmike.com/flexcolorscheme/themesplayground-latest/?config=H4sIAKZob2gA_3WRPWvDMBRF9_wKoTkY2cGk8VZKhw6BgEuHLkaNXlOBvpCe0piQ_15JtRNoqMZzLvcK3nlB0qNO8fHgbTRiEBw57Qh9_QINgeyuhmRD4OSsRxCkZhVbVw1rWsI2Xd12LaPLu7Yj-CCtyYUPVVNdI2Gf61-MgFNy65lKHRVH6x-dm1391z1Z7awBg-HfyJuE73drda5mbLKYF7dWQKLnggoW3OOAo8uYgol6KMFB5-TyljtyFUsmjAFB02Iuc7d1cl--82xEL8vG5s71mLYm20w2BthyBC-5WiX8yVWAm-rjx-8dZrW4_AALBabTsgEAAA==

/// Light [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF4C9BBA),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF9CEBEB),
  onPrimaryContainer: Color(0xFF000000),
  primaryFixed: Color(0xFFD8E9EF),
  primaryFixedDim: Color(0xFFB1D2DF),
  onPrimaryFixed: Color(0xFF204553),
  onPrimaryFixedVariant: Color(0xFF255061),
  secondary: Color(0xFFFF4F58),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDAD7),
  onSecondaryContainer: Color(0xFF000000),
  secondaryFixed: Color(0xFFF7DFE0),
  secondaryFixedDim: Color(0xFFEABCBF),
  onSecondaryFixed: Color(0xFFA60008),
  onSecondaryFixedVariant: Color(0xFFB3060E),
  tertiary: Color(0xFFBF4A50),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFCBDBD),
  onTertiaryContainer: Color(0xFF000000),
  tertiaryFixed: Color(0xFFF0D8DA),
  tertiaryFixedDim: Color(0xFFE0B0B3),
  onTertiaryFixed: Color(0xFF571F22),
  onTertiaryFixedVariant: Color(0xFF642427),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFCD9DF),
  onErrorContainer: Color(0xFF000000),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF000000),
  surfaceDim: Color(0xFFE0E0E0),
  surfaceBright: Color(0xFFFDFDFD),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF8F8F8),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEDEDED),
  surfaceContainerHighest: Color(0xFFE7E7E7),
  onSurfaceVariant: Color(0xFF000000),
  outline: Color(0xFF919191),
  outlineVariant: Color(0xFFD1D1D1),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF121212),
  onInverseSurface: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFFE5FFFF),
  surfaceTint: Color(0xFF4C9BBA),
);

/// Dark [ColorScheme] made with FlexColorScheme v8.2.0.
/// Requires Flutter 3.22.0 or later.
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF669DB3),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF078282),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFFD8E9EF),
  primaryFixedDim: Color(0xFFB1D2DF),
  onPrimaryFixed: Color(0xFF204553),
  onPrimaryFixedVariant: Color(0xFF255061),
  secondary: Color(0xFFFC6E75),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF92001A),
  onSecondaryContainer: Color(0xFFFFFFFF),
  secondaryFixed: Color(0xFFF7DFE0),
  secondaryFixedDim: Color(0xFFEABCBF),
  onSecondaryFixed: Color(0xFFA60008),
  onSecondaryFixedVariant: Color(0xFFB3060E),
  tertiary: Color(0xFFF75F67),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF580810),
  onTertiaryContainer: Color(0xFFFFFFFF),
  tertiaryFixed: Color(0xFFF0D8DA),
  tertiaryFixedDim: Color(0xFFE0B0B3),
  onTertiaryFixed: Color(0xFF571F22),
  onTertiaryFixedVariant: Color(0xFF642427),
  error: Color(0xFFCF6679),
  onError: Color(0xFF000000),
  errorContainer: Color(0xFFB1384E),
  onErrorContainer: Color(0xFFFFFFFF),
  surface: Color(0xFF121212),
  onSurface: Color(0xFFFFFFFF),
  surfaceDim: Color(0xFF060606),
  surfaceBright: Color(0xFF2C2C2C),
  surfaceContainerLowest: Color(0xFF010101),
  surfaceContainerLow: Color(0xFF0E0E0E),
  surfaceContainer: Color(0xFF151515),
  surfaceContainerHigh: Color(0xFF1D1D1D),
  surfaceContainerHighest: Color(0xFF282828),
  onSurfaceVariant: Color(0xFFFFFFFF),
  outline: Color(0xFF777777),
  outlineVariant: Color(0xFF414141),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFFFFFFF),
  onInverseSurface: Color(0xFF121212),
  inversePrimary: Color(0xFF394F58),
  surfaceTint: Color(0xFF669DB3),
);

class CaravellaThemes {
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
    colorScheme: lightColorScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(lightColorScheme),
    useMaterial3: true,
    scaffoldBackgroundColor: lightColorScheme.surface,
    dialogTheme: DialogThemeData(
      backgroundColor: lightColorScheme.surfaceContainerHigh,
      surfaceTintColor: lightColorScheme.surfaceTint,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: _createTextTheme(
        lightColorScheme,
      ).titleLarge?.copyWith(color: lightColorScheme.onSurface),
      contentTextStyle: _createTextTheme(
        lightColorScheme,
      ).bodyMedium?.copyWith(color: lightColorScheme.onSurfaceVariant),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: lightColorScheme.surfaceContainerHighest,
      // Material 3 outlined style
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: lightColorScheme.outline,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: lightColorScheme.outline,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: lightColorScheme.outline.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.error, width: 2.0),
      ),
      hintStyle: TextStyle(
        color: lightColorScheme.outline,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    ),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkColorScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(darkColorScheme),
    useMaterial3: true,
    scaffoldBackgroundColor: darkColorScheme.surface,
    dialogTheme: DialogThemeData(
      backgroundColor: darkColorScheme.surfaceContainerHigh,
      surfaceTintColor: darkColorScheme.surfaceTint,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: _createTextTheme(
        darkColorScheme,
      ).titleLarge?.copyWith(color: darkColorScheme.onSurface),
      contentTextStyle: _createTextTheme(
        darkColorScheme,
      ).bodyMedium?.copyWith(color: darkColorScheme.onSurfaceVariant),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: darkColorScheme.surfaceContainerHighest,
      // Material 3 outlined style
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: darkColorScheme.outline,
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: darkColorScheme.outline,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: darkColorScheme.outline.withValues(alpha: 0.12),
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.error, width: 2.0),
      ),
      hintStyle: TextStyle(
        color: darkColorScheme.outline,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    ),
  );
}
