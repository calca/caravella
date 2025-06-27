import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../widgets/caravella_bottom_bar.dart';

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
                      if (_currentTrip == null)
                        const Expanded(
                          child: NoTripSection(),
                        )
                      else
                        Expanded(
                          child: CurrentTripSection(
                            trip: _currentTrip!,
                            loc: loc,
                            onTripAdded: _refresh,
                            zenMode: _zenMode,
                            onZenModeChanged: _toggleZenMode,
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

class CurrentTripSection extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;
  final VoidCallback onTripAdded;
  final bool zenMode;
  final ValueChanged<bool> onZenModeChanged;
  const CurrentTripSection({
    super.key,
    required this.trip,
    required this.loc,
    required this.onTripAdded,
    required this.zenMode,
    required this.onZenModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Switch(
                value: zenMode,
                onChanged: onZenModeChanged,
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: Padding(
            key: ValueKey(zenMode),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: IntrinsicHeight(
              child: CurrentTripCard(trip: trip),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: zenMode
                ? const SizedBox.shrink(key: ValueKey('zen'))
                : Padding(
                    key: const ValueKey('normal'),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TripSection(
                      currentTrip: trip,
                      loc: loc,
                      onTripAdded: onTripAdded,
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: CaravellaBottomBar(
            loc: loc,
            onTripAdded: onTripAdded,
            currentTrip: trip,
            showLeftButtons: !zenMode,
          ),
        ),
      ],
    );
  }
}

class NoTripSection extends StatelessWidget {
  const NoTripSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = LocaleNotifier.of(context);
    final loc = AppLocalizations(localeNotifier?.locale ?? 'it');
    final state = context.findAncestorStateOfType<_HomePageState>();
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: NoTripCard(
                loc: loc,
                onAddTrip: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTripPage(),
                    ),
                  );
                  if (result == true) state?._refresh();
                },
                opacity: 0.5,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: CaravellaBottomBar(
            loc: loc,
            onTripAdded: state?._refresh ?? () {},
            currentTrip: Trip.empty(),
            showAddButton: false,
          ),
        ),
      ],
    );
  }
}
