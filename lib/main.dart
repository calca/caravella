import 'package:flutter/material.dart';
import 'caravella_fab.dart';
import 'current_trip_tile.dart';
import 'app_localizations.dart';
import 'language_selector.dart';

void main() {
  runApp(const CaravellaApp());
}

class CaravellaApp extends StatelessWidget {
  const CaravellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caravella',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
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
  String _locale = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {}); // Ricarica i dati dallo storage quando si torna in foreground
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ricarica i dati ogni volta che la pagina torna visibile
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
          ),
          LanguageSelector(
            locale: _locale,
            onChanged: (value) {
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
