import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'themes/caravella_themes.dart';
import 'app_localizations.dart';
import 'add_trip_page.dart';
import 'trips_storage.dart';
import 'home/caravella_bottom_bar.dart';
import 'home/no_trip_card.dart';
import 'home/current_trip_card.dart';
import 'home/trip_expenses_list.dart';

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
    setState(() { _loading = true; }); // Mostra loader subito
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selected_locale');
    final trips = await TripsStorage.readTrips();
    if (!mounted) return;
    setState(() {
      _locale = savedLocale ?? 'it';
      _currentTrip = trips.isNotEmpty ? (trips..sort((a, b) => b.startDate.compareTo(a.startDate))).first : null;
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
    final loc = AppLocalizations(_locale);
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _currentTrip == null
                            ? NoTripCard(
                                loc: loc,
                                onAddTrip: () async {
                                  final result = await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AddTripPage(localizations: loc),
                                    ),
                                  );
                                  if (result == true) _refresh();
                                },
                                opacity: 0.5,
                              )
                            : CurrentTripCard(trip: _currentTrip!, loc: loc, opacity: 0.5),
                      ),
                      // Lista task/viaggi
                      Expanded(
                        child: _currentTrip == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/home/no_travels.png',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.only(top: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(loc.get('latest_expenses'), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Lista task/viaggi/spese/partecipanti
                                    TripExpensesList(currentTrip: _currentTrip, loc: loc),
                                    // Bottom bar stile floating
                                    CaravellaBottomBar(loc: loc, onTripAdded: _refresh, currentTrip: _currentTrip),
                                  ],
                                ),
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
