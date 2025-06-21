import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/caravella_themes.dart';
import 'app_localizations.dart';
import 'add_trip_page.dart';
import 'trips_storage.dart';
import 'home/trip_section.dart';
import 'home/top_card/no_trip_card.dart';
import 'home/top_card/current_trip_card.dart';
import 'state/locale_notifier.dart';
import 'state/theme_mode_notifier.dart';

void main() {
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
          home: CaravellaHomePage(title: 'Caravella'),
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
    with WidgetsBindingObserver {
  Trip? _currentTrip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Avvia caricamento dati dopo il primo frame per evitare blocchi UI
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocaleAndTrip());
  }

  Future<void> _loadLocaleAndTrip() async {
    setState(() {
      _loading = true;
    }); // Mostra loader subito
    final trips = await TripsStorage.readTrips();
    if (!mounted) return;
    setState(() {
      _currentTrip = trips.isNotEmpty
          ? (trips..sort((a, b) => b.startDate.compareTo(a.startDate))).first
          : null;
      _loading = false;
    });
  }

  void _refresh() => _loadLocaleAndTrip();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Rimosso l'aggiornamento automatico su resume
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home/backgrounds/mountains.jpg',
            fit: BoxFit.cover,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
            colorBlendMode: BlendMode.darken,
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Card utente/viaggio in alto
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: _currentTrip == null
                            ? NoTripCard(
                                loc: loc,
                                onAddTrip: () async {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddTripPage(),
                                    ),
                                  );
                                  if (result == true) _refresh();
                                },
                                opacity: 0.5,
                              )
                            : CurrentTripCard(
                                trip: _currentTrip!, opacity: 0.5),
                      ),
                      // Lista task/viaggi
                      Expanded(
                        child: TripSection(
                          currentTrip: _currentTrip,
                          loc: loc,
                          onTripAdded: _refresh,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
