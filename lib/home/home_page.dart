import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../trip/add_trip_page.dart';
import '../data/trips_storage.dart';
import '../home/trip_section.dart';
import '../home/top_card/no_trip_card.dart';
import '../home/top_card/current_trip_card.dart';
import '../state/locale_notifier.dart';
import 'home_background.dart';
import '../../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  Trip? _currentTrip;
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
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HomeBackground(),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16), // Maggiore spazio verticale
                        child: IntrinsicHeight(
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
                              : CurrentTripCard(trip: _currentTrip!),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TripSection(
                            currentTrip: _currentTrip,
                            loc: loc,
                            onTripAdded: _refresh,
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
