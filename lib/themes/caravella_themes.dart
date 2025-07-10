import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CaravellaThemes {
  // Light ColorScheme made with FlexColorScheme v8.2.0
  static const ColorScheme lightScheme = ColorScheme(
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
    surface: Color(0xFFFCFCFC),
    onSurface: Color(0xFF111111),
    surfaceDim: Color(0xFFE0E0E0),
    surfaceBright: Color(0xFFFDFDFD),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8F8F8),
    surfaceContainer: Color(0xFFF3F3F3),
    surfaceContainerHigh: Color(0xFFEDEDED),
    surfaceContainerHighest: Color(0xFFE7E7E7),
    onSurfaceVariant: Color(0xFF393939),
    outline: Color(0xFF919191),
    outlineVariant: Color(0xFFD1D1D1),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2A2A2A),
    onInverseSurface: Color(0xFFF1F1F1),
    inversePrimary: Color(0xFFE5FFFF),
    surfaceTint: Color(0xFF4C9BBA),
  );

  // Dark ColorScheme made with FlexColorScheme v8.2.0
  static const ColorScheme darkScheme = ColorScheme(
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
    surface: Color(0xFF080808),
    onSurface: Color(0xFFF1F1F1),
    surfaceDim: Color(0xFF060606),
    surfaceBright: Color(0xFF2C2C2C),
    surfaceContainerLowest: Color(0xFF010101),
    surfaceContainerLow: Color(0xFF0E0E0E),
    surfaceContainer: Color(0xFF151515),
    surfaceContainerHigh: Color(0xFF1D1D1D),
    surfaceContainerHighest: Color(0xFF282828),
    onSurfaceVariant: Color(0xFFCACACA),
    outline: Color(0xFF777777),
    outlineVariant: Color(0xFF414141),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE8E8E8),
    onInverseSurface: Color(0xFF2A2A2A),
    inversePrimary: Color(0xFF334952),
    surfaceTint: Color(0xFF669DB3),
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
    scaffoldBackgroundColor: lightScheme.surface,
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
          color: lightScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightScheme.primary,
        foregroundColor: lightScheme.onPrimary,
        elevation: 2,
        shadowColor: lightScheme.shadow.withValues(alpha: 0.1),
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
    dividerColor: lightScheme.outline.withValues(alpha: 0.3),
    iconTheme: IconThemeData(color: lightScheme.onSurfaceVariant),
  );

  static final ThemeData dark = ThemeData(
    colorScheme: darkScheme,
    fontFamily: 'Montserrat',
    textTheme: _createTextTheme(darkScheme),
    scaffoldBackgroundColor: darkScheme.surface,
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
          color: darkScheme.outline.withValues(alpha: 0.3),
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
    dividerColor: darkScheme.outline.withValues(alpha: 0.3),
    iconTheme: IconThemeData(color: darkScheme.onSurfaceVariant),
  );
}
