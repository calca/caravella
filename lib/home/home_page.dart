import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/trip.dart';
import '../trip/add_trip_page.dart';
import '../data/trips_storage.dart';
import '../home/trip_section.dart';
import '../home/top_card/no_trip_card.dart';
import '../home/top_card/current_trip_card.dart';
import '../state/locale_notifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, RouteAware {
  Trip? _currentTrip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocaleAndTrip());
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // RouteObserver registration should be handled in main if needed
  }

  @override
  void didPopNext() {
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: child,
            ),
            child: Image.asset(
              'assets/images/home/backgrounds/mountains.jpg',
              fit: BoxFit.cover,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withAlpha(128)
                  : Colors.white.withAlpha(128),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
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
                              : CurrentTripCard(
                                  trip: _currentTrip!, opacity: 0.5),
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
