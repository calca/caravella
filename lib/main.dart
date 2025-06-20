import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'caravella_fab.dart';
import 'current_trip_tile.dart';
import 'app_localizations.dart';
import 'language_selector.dart';
import 'themes/caravella_themes.dart';

void main() {
  runApp(const CaravellaApp());
}

class CaravellaApp extends StatelessWidget {
  const CaravellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caravella',
      theme: CaravellaThemes.light,
      darkTheme: CaravellaThemes.dark,
      themeMode: ThemeMode.system,
      home: const CaravellaHomePage(title: 'Caravella'),
    );
  }
}

class CaravellaHomePage extends StatefulWidget {
  const CaravellaHomePage({super.key, required this.title});
  final String title;
  @override
  State<CaravellaHomePage> createState() => _CaravellaHomePageState();
}

class _CaravellaHomePageState extends State<CaravellaHomePage> with WidgetsBindingObserver {
  String _locale = 'it';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');
    setState(() {
      _locale = savedLocale ?? 'it';
    });
  }

  Future<void> _saveLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', locale);
  }

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
    final loc = AppLocalizations(_locale);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/viaggio_bg.jpg',
            fit: BoxFit.cover,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.1),
            colorBlendMode: BlendMode.darken,
          ),
          LanguageSelector(
            locale: _locale,
            onChanged: (value) async {
              await _saveLocale(value);
              setState(() {
                _locale = value;
              });
            },
          ),
          Center(
            child: CurrentTripTile(
              localizations: loc,
              onTripAdded: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CaravellaFab(
        localizations: loc,
        onRefresh: () {
          setState(() {});
        },
      ),
    );
  }
}
