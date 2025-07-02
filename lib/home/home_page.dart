import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../data/expense_group.dart';
import '../data/expense_group_storage.dart';
import '../state/locale_notifier.dart';
import '../../main.dart';
import 'welcome/home_welcome_section.dart';
import 'cards/home_cards_section.dart';
import 'pinned/home_pinned_section.dart';

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
    final trips = await ExpenseGroupStorage.getActiveGroups();
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _currentTrip == null
                  // Per WelcomeSection: NO SafeArea per edge-to-edge completo
                  ? HomeWelcomeSection(onTripAdded: _refresh)
                  // Per altre sezioni: USA SafeArea
                  : SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (_pinnedTrip != null)
                              // C'è un viaggio pinnato: mostra solo la sezione pinnata
                              HomePinnedSection(
                                pinnedTrip: _pinnedTrip!,
                                loc: loc,
                                onTripAdded: _refresh,
                              )
                            else
                              // Ci sono viaggi ma nessun pinnato: mostra trip section
                              HomeCardsSection(
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
