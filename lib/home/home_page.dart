import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/expense_group.dart';
import '../data/expense_group_storage.dart';
import '../state/expense_group_notifier.dart';
import '../../main.dart';
import 'welcome/home_welcome_section.dart';
import 'cards/home_cards_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ExpenseGroup? _pinnedTrip;
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLocaleAndTrip());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    // Rimuovi il listener precedente se esiste
    _groupNotifier?.removeListener(_onGroupUpdated);

    // Ottieni il nuovo notifier e aggiungi il listener
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupUpdated);
  }

  @override
  void dispose() {
    // Rimuovi il listener in modo sicuro
    _groupNotifier?.removeListener(_onGroupUpdated);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refresh();
  }

  void _onGroupUpdated() {
    final updatedGroupIds = _groupNotifier?.updatedGroupIds ?? [];

    if (updatedGroupIds.isNotEmpty && mounted) {
      // Ricarica i dati se ci sono gruppi aggiornati
      _loadLocaleAndTrip();
      // Pulisci la lista degli aggiornamenti
      _groupNotifier?.clearUpdatedGroups();
    }
  }

  Future<void> _loadLocaleAndTrip() async {
    setState(() {
      _loading = true;
    });
    final pinnedTrip = await ExpenseGroupStorage.getPinnedTrip();
    if (!mounted) return;
    setState(() {
      _pinnedTrip = pinnedTrip;
      _loading = false;
    });
  }

  void _refresh() => _loadLocaleAndTrip();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<ExpenseGroup>>(
                  future: ExpenseGroupStorage.getActiveGroups(),
                  builder: (context, snapshot) {
                    final hasGroups = snapshot.data?.isNotEmpty == true;

                    return hasGroups
                        // Ci sono gruppi: mostra HomeCardsSection con SafeArea
                        ? SafeArea(
                            child: HomeCardsSection(
                              onTripAdded: _refresh,
                              pinnedTrip: _pinnedTrip,
                            ),
                          )
                        // Nessun gruppo: mostra WelcomeSection senza SafeArea
                        : HomeWelcomeSection(onTripAdded: _refresh);
                  },
                ),
        ],
      ),
    );
  }
}
