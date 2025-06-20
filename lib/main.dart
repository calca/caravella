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

class _CaravellaHomePageState extends State<CaravellaHomePage> {
  String _locale = 'en';

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
