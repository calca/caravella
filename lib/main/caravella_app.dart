import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../config/app_config.dart';
import '../themes/caravella_themes.dart';
import '../services/shortcuts_initialization.dart';
import 'route_observer.dart';
import 'provider_setup.dart';
import 'caravella_home_page.dart';

/// The root widget of the Caravella app, managing locale and theme state.
class CaravellaApp extends StatefulWidget {
  const CaravellaApp({super.key});

  @override
  State<CaravellaApp> createState() => _CaravellaAppState();
}

class _CaravellaAppState extends State<CaravellaApp> {
  String _locale = 'it';
  ThemeMode _themeMode = ThemeMode.system;

  // Global scaffold messenger key to allow showing SnackBars/toasts safely
  // even when the local BuildContext that requested it is already disposed.
  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadThemeMode();
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

  @override
  Widget build(BuildContext context) {
    return ProviderSetup.createProviders(
      child: ProviderSetup.wrapWithNotifiers(
        locale: _locale,
        onLocaleChange: _changeLocale,
        themeMode: _themeMode,
        onThemeChange: _changeTheme,
        child: MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: AppConfig.showDebugBanner,
          theme: CaravellaThemes.light,
          darkTheme: CaravellaThemes.dark,
          themeMode: _themeMode,
          scaffoldMessengerKey: _scaffoldMessengerKey,
          navigatorKey: navigatorKey,
          locale: Locale(_locale),
          // Use generated locales & delegates to avoid divergence and ensure pt is enabled
          supportedLocales: gen.AppLocalizations.supportedLocales,
          localizationsDelegates: gen.AppLocalizations.localizationsDelegates,
          home: const CaravellaHomePage(title: 'Caravella'),
          navigatorObservers: [routeObserver],
        ),
      ),
    );
  }

  /// Expose a top-level getter for the scaffold messenger state so utility
  /// classes (e.g. AppToast) can fallback to it when the original context
  /// becomes unmounted between an async operation and UI feedback.
  static ScaffoldMessengerState? get rootScaffoldMessenger =>
      _scaffoldMessengerKey.currentState;
}

/// Expose the root scaffold messenger for global access.
ScaffoldMessengerState? get rootScaffoldMessenger =>
    _CaravellaAppState.rootScaffoldMessenger;
