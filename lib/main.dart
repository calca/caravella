import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/caravella_themes.dart';
import 'state/locale_notifier.dart';
import 'state/theme_mode_notifier.dart';
import 'state/expense_group_notifier.dart';
import 'home/home_page.dart';
import 'config/app_config.dart';
import 'settings/flag_secure_android.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Legge il flavor dall'ambiente di compilazione
  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
  switch (flavorString) {
    case 'dev':
      AppConfig.setEnvironment(Environment.dev);
      break;
    case 'staging':
      AppConfig.setEnvironment(Environment.staging);
      break;
    default:
      AppConfig.setEnvironment(Environment.prod);
  }

  // Ottimizzazioni performance
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Abilita l'edge-to-edge su Android
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Ottimizza la gestione memoria per immagini
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB

  _initFlagSecure().then((_) {
    runApp(const CaravellaApp());
  });
}

// Test entrypoint (avoids async flag secure wait & system chrome constraints in tests)
@visibleForTesting
Widget createAppForTest() {
  // Initialize environment (prod) for tests
  AppConfig.setEnvironment(Environment.prod);
  return const CaravellaApp();
}

Future<void> _initFlagSecure() async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool('flag_secure_enabled') ?? true;
  await FlagSecureAndroid.setFlagSecure(enabled);
}

class CaravellaApp extends StatefulWidget {
  const CaravellaApp({super.key});

  @override
  State<CaravellaApp> createState() => _CaravellaAppState();
}

class _CaravellaAppState extends State<CaravellaApp> {
  String _locale = 'it';
  ThemeMode _themeMode = ThemeMode.system;

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
      ],
      child: LocaleNotifier(
        locale: _locale,
        changeLocale: _changeLocale,
        child: ThemeModeNotifier(
          themeMode: _themeMode,
          changeTheme: _changeTheme,
          child: MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: AppConfig.showDebugBanner,
            theme: CaravellaThemes.light,
            darkTheme: CaravellaThemes.dark,
            themeMode: _themeMode,
            locale: Locale(_locale),
            supportedLocales: const [Locale('it'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const CaravellaHomePage(title: 'Caravella'),
            navigatorObservers: [routeObserver],
          ),
        ),
      ),
    );
  }
}

class CaravellaHomePage extends StatefulWidget {
  const CaravellaHomePage({super.key, required this.title});
  final String title;
  @override
  State<CaravellaHomePage> createState() => _CaravellaHomePageState();
}

class _CaravellaHomePageState extends State<CaravellaHomePage>
    with WidgetsBindingObserver, RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {}); // trigger HomePage refresh if needed
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
