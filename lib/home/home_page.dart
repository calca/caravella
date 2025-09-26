import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/model/expense_group.dart';
import '../data/expense_group_storage_v2.dart';
import '../state/expense_group_notifier.dart';
import '../state/expense_groups_async_notifier.dart';
import '../../main.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'welcome/home_welcome_section.dart';
import 'cards/home_cards_section.dart';
import '../widgets/app_toast.dart';
import '../widgets/async_value_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  ExpenseGroup? _pinnedTrip;
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;
  late final ExpenseGroupsAsyncNotifier _groupsAsyncNotifier;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _groupsAsyncNotifier = ExpenseGroupsAsyncNotifier();
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
      // Usa state-based updates invece di ricaricare tutto
      setState(() {
        // Trigger rebuild of the UI with updated state
        // La UI si aggiornerà automaticamente grazie al Consumer pattern
      });

      // Aggiorna solo il pinned trip se necessario
      _updatePinnedTripIfNeeded(updatedGroupIds);

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

  Future<void> _updatePinnedTripIfNeeded(List<String> updatedGroupIds) async {
    if (_pinnedTrip != null && updatedGroupIds.contains(_pinnedTrip!.id)) {
      try {
        final updatedPinnedTrip = await ExpenseGroupStorageV2.getTripById(
          _pinnedTrip!.id,
        );
        if (mounted && updatedPinnedTrip != null) {
          setState(() {
            _pinnedTrip = updatedPinnedTrip;
          });
        }
      } catch (e) {
        // Fallback to full reload only if there's an error
        _loadLocaleAndTrip();
      }
    }
  }

  Future<void> _loadLocaleAndTrip() async {
    if (!_refreshing) {
      setState(() {
        _loading = true;
      });
    }
    
    // Load both pinned trip and groups data
    await Future.wait([
      _loadPinnedTrip(),
      _groupsAsyncNotifier.loadAllGroups(),
    ]);
    
    if (!mounted) return;
    setState(() {
      _loading = false;
      _refreshing = false;
    });
  }
  
  Future<void> _loadPinnedTrip() async {
    try {
      final pinnedTrip = await ExpenseGroupStorageV2.getPinnedTrip();
      if (mounted) {
        setState(() {
          _pinnedTrip = pinnedTrip;
        });
      }
    } catch (e) {
      // Handle error silently for pinned trip
      if (mounted) {
        setState(() {
          _pinnedTrip = null;
        });
      }
    }
  }

  void _refresh() => _loadLocaleAndTrip();

  Future<void> _handleUserRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    
    // Refresh both pinned trip and groups
    await Future.wait([
      _loadPinnedTrip(),
      _groupsAsyncNotifier.refreshGroupsInBackground(),
    ]);
    
    if (mounted) {
      setState(() => _refreshing = false);
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
    return ChangeNotifierProvider<ExpenseGroupsAsyncNotifier>.value(
      value: _groupsAsyncNotifier,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: _loading
            ? Semantics(
                liveRegion: true,
                label: gloc.accessibility_loading_groups,
                child: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: gloc.accessibility_loading_your_groups,
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _handleUserRefresh,
                child: SimpleAsyncConsumer<ExpenseGroupsAsyncNotifier, List<ExpenseGroup>>(
                  data: (context, allGroups, notifier) {
                    final active = notifier.activeGroups;
                    final archived = notifier.archivedGroups;

                    // Show HomeCardsSection when there are active groups.
                    // If active is empty but archived groups exist, still show HomeCardsSection
                    // with an empty list so the UI renders only the add-card.
                    if (active.isNotEmpty) {
                      return SafeArea(
                        child: Semantics(
                          label: gloc.accessibility_groups_list,
                          child: HomeCardsSection(
                            initialGroups: active,
                            pinnedTrip: _pinnedTrip,
                            onTripAdded: _refresh,
                            allArchived: false,
                          ),
                        ),
                      );
                    } else if (archived.isNotEmpty) {
                      return SafeArea(
                        child: Semantics(
                          label: gloc.accessibility_groups_list,
                          child: HomeCardsSection(
                            initialGroups: const [],
                            pinnedTrip: _pinnedTrip,
                            onTripAdded: _refresh,
                            allArchived: true,
                          ),
                        ),
                      );
                    } else {
                      return SafeArea(
                        child: HomeWelcomeSection(
                          onTripAdded: _refresh,
                        ),
                      );
                    }
                  },
                  loading: (context) => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: gloc.accessibility_loading_your_groups,
                    ),
                  ),
                  error: (context, error) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading groups',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _groupsAsyncNotifier.loadAllGroups(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
