import 'package:flutter/material.dart';
import 'caravella_fab.dart';
import 'current_trip_tile.dart';
import 'app_localizations.dart';

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
          // Language selector in top-right corner with semi-transparent background
          Positioned(
            top: 32,
            right: 24,
            child: DropdownButton<String>(
              value: _locale,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.black))),
                DropdownMenuItem(value: 'it', child: Text('ITA', style: TextStyle(color: Colors.black))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _locale = value;
                  });
                }
              },
            ),
          ),
          Center(
            child: CurrentTripTile(localizations: loc),
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
