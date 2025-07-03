import 'package:flutter/material.dart';
import '../data/expense_group.dart';
import '../data/expense_group_storage.dart';
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
