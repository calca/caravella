import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/expense_group.dart';
import '../data/expense_group_storage.dart';
import '../state/expense_group_notifier.dart';
import '../../main.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'welcome/home_welcome_section.dart';
import 'cards/home_cards_section.dart';
import '../widgets/app_toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ExpenseGroup? _pinnedTrip;
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;
  bool _refreshing = false;

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
      final event = _groupNotifier?.consumeLastEvent();
      if (event == 'expense_added') {
        final gloc = gen.AppLocalizations.of(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.show(
            context,
            gloc.expense_added_success,
            type: ToastType.success,
          );
        });
      }
    }
  }

  Future<void> _loadLocaleAndTrip() async {
    if (!_refreshing) {
      setState(() {
        _loading = true;
      });
    }
    final pinnedTrip = await ExpenseGroupStorage.getPinnedTrip();
    if (!mounted) return;
    setState(() {
      _pinnedTrip = pinnedTrip;
      _loading = false;
      _refreshing = false;
    });
  }

  void _refresh() => _loadLocaleAndTrip();

  Future<void> _handleUserRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    await _loadLocaleAndTrip();
    if (mounted) {
      AppToast.show(
        context,
        gen.AppLocalizations.of(context).data_refreshed,
        type: ToastType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? Semantics(
              liveRegion: true,
              label: 'Loading groups',
              child: const Center(
                child: CircularProgressIndicator(
                  semanticsLabel: 'Loading your groups',
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _handleUserRefresh,
              child: FutureBuilder<List<ExpenseGroup>>(
                future: ExpenseGroupStorage.getActiveGroups(),
                builder: (context, snapshot) {
                  final hasGroups = snapshot.data?.isNotEmpty == true;
                  if (hasGroups) {
                    return SafeArea(
                      child: Semantics(
                        label: 'Groups list',
                        child: HomeCardsSection(
                          onTripAdded: () {
                            _refresh();
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              AppToast.show(
                                context,
                                gloc.group_added_success,
                                type: ToastType.success,
                              );
                            });
                          },
                          pinnedTrip: _pinnedTrip,
                        ),
                      ),
                    );
                  } else {
                    return Semantics(
                      label: 'Welcome screen',
                      child: HomeWelcomeSection(
                        onTripAdded: () {
                          _refresh();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            AppToast.show(
                              context,
                              gloc.group_added_success,
                              type: ToastType.success,
                            );
                          });
                        },
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
