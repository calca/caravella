import 'package:material_ui/material_ui.dart';
// dynamic_color hasn't migrated to material_ui yet, so its ColorScheme is
// still the legacy flutter/material one; see _toModernColorScheme below.
import 'package:flutter/material.dart' as legacy show ColorScheme;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:zentoast/zentoast.dart';

import 'route_observer.dart';
import 'provider_setup.dart';
import 'caravella_home_page.dart';

/// Converts the legacy [legacy.ColorScheme] that `dynamic_color` still
/// produces into the material_ui [ColorScheme] our own theming expects.
/// Both classes carry the same Material 3 color roles, so every getter
/// (including its already-resolved fallbacks) copies over directly.
ColorScheme _toModernColorScheme(legacy.ColorScheme s) {
  return ColorScheme(
    brightness: s.brightness,
    primary: s.primary,
    onPrimary: s.onPrimary,
    secondary: s.secondary,
    onSecondary: s.onSecondary,
    error: s.error,
    onError: s.onError,
    surface: s.surface,
    onSurface: s.onSurface,
  ).copyWith(
    primaryContainer: s.primaryContainer,
    onPrimaryContainer: s.onPrimaryContainer,
    primaryFixed: s.primaryFixed,
    primaryFixedDim: s.primaryFixedDim,
    onPrimaryFixed: s.onPrimaryFixed,
    onPrimaryFixedVariant: s.onPrimaryFixedVariant,
    secondaryContainer: s.secondaryContainer,
    onSecondaryContainer: s.onSecondaryContainer,
    secondaryFixed: s.secondaryFixed,
    secondaryFixedDim: s.secondaryFixedDim,
    onSecondaryFixed: s.onSecondaryFixed,
    onSecondaryFixedVariant: s.onSecondaryFixedVariant,
    tertiary: s.tertiary,
    onTertiary: s.onTertiary,
    tertiaryContainer: s.tertiaryContainer,
    onTertiaryContainer: s.onTertiaryContainer,
    tertiaryFixed: s.tertiaryFixed,
    tertiaryFixedDim: s.tertiaryFixedDim,
    onTertiaryFixed: s.onTertiaryFixed,
    onTertiaryFixedVariant: s.onTertiaryFixedVariant,
    errorContainer: s.errorContainer,
    onErrorContainer: s.onErrorContainer,
    surfaceDim: s.surfaceDim,
    surfaceBright: s.surfaceBright,
    surfaceContainerLowest: s.surfaceContainerLowest,
    surfaceContainerLow: s.surfaceContainerLow,
    surfaceContainer: s.surfaceContainer,
    surfaceContainerHigh: s.surfaceContainerHigh,
    surfaceContainerHighest: s.surfaceContainerHighest,
    onSurfaceVariant: s.onSurfaceVariant,
    outline: s.outline,
    outlineVariant: s.outlineVariant,
    shadow: s.shadow,
    scrim: s.scrim,
    inverseSurface: s.inverseSurface,
    onInverseSurface: s.onInverseSurface,
    inversePrimary: s.inversePrimary,
    surfaceTint: s.surfaceTint,
  );
}

/// The root widget of the Caravella app, managing locale and theme state.
class CaravellaApp extends StatefulWidget {
  const CaravellaApp({super.key});

  @override
  State<CaravellaApp> createState() => _CaravellaAppState();
}

class _CaravellaAppState extends State<CaravellaApp> {
  String _locale = 'it';
  ThemeMode _themeMode = ThemeMode.system;
  bool _dynamicColorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadThemeMode();
    _loadDynamicColorPreference();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');
    setState(() {
      _locale = savedLocale ?? 'it';
    });
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  void _changeLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale);
    setState(() {
      _locale = locale;
    });
  }

  void _changeTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString('theme_mode', value);
    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> _loadDynamicColorPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dynamicColorEnabled = prefs.getBool('dynamic_color_enabled') ?? false;
    });
  }

  void _changeDynamicColor(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamic_color_enabled', enabled);
    setState(() {
      _dynamicColorEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderSetup.createProviders(
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return ProviderSetup.wrapWithNotifiers(
            locale: _locale,
            onLocaleChange: _changeLocale,
            themeMode: _themeMode,
            onThemeChange: _changeTheme,
            dynamicColorEnabled: _dynamicColorEnabled,
            onDynamicColorChange: _changeDynamicColor,
            child: ToastProvider.create(
              child: MaterialApp(
                title: AppConfig.appName,
                debugShowCheckedModeBanner: AppConfig.showDebugBanner,
                theme: _dynamicColorEnabled && lightDynamic != null
                    ? CaravellaThemes.createLightTheme(
                        dynamicColorScheme: _toModernColorScheme(
                          lightDynamic,
                        ),
                      )
                    : CaravellaThemes.light,
                darkTheme: _dynamicColorEnabled && darkDynamic != null
                    ? CaravellaThemes.createDarkTheme(
                        dynamicColorScheme: _toModernColorScheme(darkDynamic),
                      )
                    : CaravellaThemes.dark,
                themeMode: _themeMode,
                navigatorKey: navigatorKey,
                locale: Locale(_locale),
                // Use generated locales to avoid divergence and ensure pt is enabled
                supportedLocales: gen.AppLocalizations.supportedLocales,
                localizationsDelegates: appLocalizationsDelegates,
                builder: (context, child) {
                  return ToastThemeProvider(
                    data: const ToastTheme(
                      gap: 8,
                      viewerPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: child ?? const SizedBox()),
                        SafeArea(
                          child: ToastViewer(
                            alignment: Alignment.topCenter,
                            delay: const Duration(milliseconds: 2400),
                            visibleCount: 3,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                home: const CaravellaHomePage(title: 'Caravella'),
                navigatorObservers: [routeObserver],
              ),
            ),
          );
        },
      ),
    );
  }
}
