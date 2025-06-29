import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../data/trips_storage.dart';
import '../state/locale_notifier.dart';
import '../../main.dart';
import 'welcome/welcome_section.dart';
import 'trip/home_trip_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Trip? _currentTrip;
  bool _loading = true;
  bool _zenMode = false;

  @override
  void initState() {
    super.initState();
    _loadZenMode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocaleAndTrip());
  }

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
    _refresh();
  }

  Future<void> _loadZenMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _zenMode = prefs.getBool('zenMode') ?? false;
    });
  }

  Future<void> _toggleZenMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _zenMode = value;
    });
    await prefs.setBool('zenMode', value);
  }

  Future<void> _loadLocaleAndTrip() async {
    setState(() {
      _loading = true;
    });
    final trips = await TripsStorage.currentTrips(DateTime.now());
    if (!mounted) return;
    setState(() {
      _currentTrip = trips.isNotEmpty ? trips.first : null;
      _loading = false;
    });
  }

  void _refresh() => _loadLocaleAndTrip();

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_currentTrip == null)
                    WelcomeSection(onTripAdded: _refresh)
                  else
                    HomeTripSection(
                      trip: _currentTrip!,
                      loc: loc,
                      onTripAdded: _refresh,
                      zenMode: _zenMode,
                      onZenModeChanged: _toggleZenMode,
                    ),
                ],
              ),
      ),
    );
  }
}
