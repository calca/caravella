import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../data/trips_storage.dart';
import '../state/locale_notifier.dart';
import '../../main.dart';
import 'welcome/welcome_section.dart';
import 'trip/home_trip_section.dart';
import 'pinned/pinned_trip_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Trip? _currentTrip;
  Trip? _pinnedTrip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadLocaleAndTrip() async {
    setState(() {
      _loading = true;
    });
    final trips = await TripsStorage.currentTrips(DateTime.now());
    final pinnedTrip = await TripsStorage.getPinnedTrip();
    if (!mounted) return;
    setState(() {
      _currentTrip = trips.isNotEmpty ? trips.first : null;
      _pinnedTrip = pinnedTrip;
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
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Sezione viaggio pinnato (se presente)
                    if (_pinnedTrip != null)
                      PinnedTripSection(
                        pinnedTrip: _pinnedTrip!,
                        loc: loc,
                        onTripAdded: _refresh,
                      ),

                    // Sezione principale
                    if (_currentTrip == null)
                      WelcomeSection(onTripAdded: _refresh)
                    else
                      HomeTripSection(
                        trip: _currentTrip!,
                        loc: loc,
                        onTripAdded: _refresh,
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
