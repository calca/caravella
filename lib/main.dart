import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/caravella_themes.dart';
import 'state/locale_notifier.dart';
import 'state/theme_mode_notifier.dart';
import 'home/home_page.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Abilita l'edge-to-edge su Android
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  runApp(const CaravellaApp());
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
    return LocaleNotifier(
      locale: _locale,
      changeLocale: _changeLocale,
      child: ThemeModeNotifier(
        themeMode: _themeMode,
        changeTheme: _changeTheme,
        child: MaterialApp(
          title: 'Caravella',
          theme: CaravellaThemes.light,
          darkTheme: CaravellaThemes.dark,
          themeMode: _themeMode,
          locale: Locale(_locale),
          supportedLocales: const [Locale('it'), Locale('en')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: CaravellaHomePage(title: 'Caravella'),
          navigatorObservers: [routeObserver],
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
