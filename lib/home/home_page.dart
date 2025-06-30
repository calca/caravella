import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/expense_group.dart';
import '../data/expense_group_storage.dart';
import '../state/locale_notifier.dart';
import '../../main.dart';
import 'welcome/welcome_section.dart';
import 'trip/home_trip_section.dart';
import 'pinned/pinned_trip_section.dart';
import 'widgets/home_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ExpenseGroup? _currentTrip;
  ExpenseGroup? _pinnedTrip;
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
    final trips = await ExpenseGroupStorage.currentTrips(DateTime.now());
    final pinnedTrip = await ExpenseGroupStorage.getPinnedTrip();
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background che occupa tutta la pagina - solo se ci sono viaggi
          if (_pinnedTrip != null ||
              (_currentTrip != null && _pinnedTrip == null))
            const HomeBackground(),

          SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Logica per mostrare le sezioni:
                        // 1. Se non ci sono viaggi: Welcome
                        // 2. Se ci sono viaggi e c'è un pinnato: solo sezione pinnata
                        // 3. Se ci sono viaggi ma nessun pinnato: trip section normale
                        if (_currentTrip == null)
                          // Nessun viaggio corrente: mostra Welcome
                          WelcomeSection(onTripAdded: _refresh)
                        else if (_pinnedTrip != null)
                          // C'è un viaggio pinnato: mostra solo la sezione pinnata
                          PinnedTripSection(
                            pinnedTrip: _pinnedTrip!,
                            loc: loc,
                            onTripAdded: _refresh,
                          )
                        else
                          // Ci sono viaggi ma nessun pinnato: mostra trip section
                          HomeTripSection(
                            trip: _currentTrip!,
                            loc: loc,
                            onTripAdded: _refresh,
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
