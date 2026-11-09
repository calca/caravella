import 'package:material_ui/material_ui.dart';
import '../manager/history/expenses_history_page.dart';
import 'app_shell.dart';
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

/// The root widget of the Caravella app, managing locale and theme state.
class CaravellaApp extends StatefulWidget {
  const CaravellaApp({super.key});

  @override
  State<CaravellaApp> createState() => _CaravellaAppState();
}

class _CaravellaAppState extends State<CaravellaApp> {
  // The device language until the saved choice loads (or for good, when
  // the user never picked one), so the first frame isn't in Italian.
  String _locale = LocalePreferences.deviceDefault();
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
      _locale = savedLocale ?? LocalePreferences.deviceDefault();
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
                        dynamicColorScheme: lightDynamic,
                      )
                    : CaravellaThemes.light,
                darkTheme: _dynamicColorEnabled && darkDynamic != null
                    ? CaravellaThemes.createDarkTheme(
                        dynamicColorScheme: darkDynamic,
                      )
                    : CaravellaThemes.dark,
                themeMode: _themeMode,
                navigatorKey: navigatorKey,
                locale: Locale(_locale),
                // Use generated locales to avoid divergence and ensure pt is enabled
                supportedLocales: gen.AppLocalizations.supportedLocales,
                localizationsDelegates: appLocalizationsDelegates,
                builder: (context, child) => AppFrame(child: child),
                home: const AppShell(
                  home: CaravellaHomePage(title: 'Caravella'),
                  groups: ExpesensHistoryPage(),
                ),
                navigatorObservers: [routeObserver],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// What surrounds every page: the system bars' fallback and the toasts.
class AppFrame extends StatelessWidget {
  final Widget? child;

  const AppFrame({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Theme-aware fallback for the system bars: pages that
        // don't wrap themselves in AppSystemUI would otherwise
        // keep the previous screen's (or previous theme's)
        // navigation bar colors — e.g. a black nav bar right
        // after switching to light theme in Appearance. Pages
        // with their own AppSystemUI still take precedence.
        Positioned.fill(child: AppSystemUI(child: child ?? const SizedBox())),
        // Toasts at the bottom, above the floating navigation
        // (and the keyboard), so they never cover a page's
        // title.
        Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  FloatingNavBar.reservedHeight +
                  MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SafeArea(
              // Around the viewer only: zentoast is built on Flutter's own
              // Theme, which doesn't see the app's and sets the light
              // defaults, so around the pages it turned every icon without
              // a color of its own black in the dark theme.
              child: ToastThemeProvider(
                data: const ToastTheme(
                  gap: 8,
                  viewerPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                // No viewer delay: each AppToast hides itself
                // after its type's time.
                child: ToastViewer(
                  alignment: Alignment.bottomCenter,
                  delay: null,
                  visibleCount: 3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
