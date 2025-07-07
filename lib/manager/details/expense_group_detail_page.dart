import 'package:flutter/material.dart';
import '../../data/expense_details.dart';
import '../../data/expense_group.dart';
import '../../expense/expense_edit_page.dart';
import '../../data/expense_group_storage.dart';
import '../group/add_new_expenses_group.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'tabs/expenses_tab.dart';
import '../../widgets/currency_display.dart';
import '../../widgets/widgets.dart';
import '../../widgets/no_expense.dart';
import 'trip_amount_card.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  ExpenseGroup? _trip;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final trip = await ExpenseGroupStorage.getTripById(widget.trip.id);
    if (!mounted) return;
    setState(() {
      _trip = trip;
      _deleted = trip == null;
    });
    if (_deleted && mounted) {
      Navigator.of(context).pop(true); // Torna in home e aggiorna
    }
  }

  Future<void> _refreshTrip() async {
    final trip =
        await ExpenseGroupStorage.getTripById(_trip?.id ?? widget.trip.id);
    if (!mounted) return;
    if (trip != null) {
      setState(() {
        _trip = trip;
      });
    }
  }

  Future<void> _openEditExpense(ExpenseDetails expense) async {
    final result = await Navigator.of(context).push<ExpenseActionResult>(
      MaterialPageRoute(
        builder: (context) => ExpenseEditPage(
          expense: expense,
          participants: _trip!.participants.map((p) => p.name).toList(),
          categories: _trip!.categories.map((c) => c.name).toList(),
          loc: AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it'),
          tripStartDate: _trip!.startDate,
          tripEndDate: _trip!.endDate,
        ),
      ),
    );
    if (result != null) {
      if (result.deleted) {
        setState(() {
          _trip!.expenses.removeWhere((e) => e.id == expense.id);
        });
      } else if (result.updatedExpense != null) {
        setState(() {
          final idx = _trip!.expenses.indexWhere((e) => e.id == expense.id);
          if (idx != -1) _trip!.expenses[idx] = result.updatedExpense!;
        });
      }
      // Salva le modifiche
      final trips = await ExpenseGroupStorage.getAllGroups();
      final tripIdx = trips.indexWhere((t) => t.id == _trip!.id);
      if (tripIdx != -1) {
        trips[tripIdx] = _trip!;
        await ExpenseGroupStorage.writeTrips(trips);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    final trip = _trip;
    if (trip == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses = trip.expenses.fold<double>(0, (sum, s) => sum + (s.amount ?? 0));
    
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar con gradiente
          SliverAppBar(
            expandedHeight: 135.0,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Opzioni',
                onSelected: (value) async {
                  switch (value) {
                    case 'pin':
                      if (trip.pinned) {
                        await ExpenseGroupStorage.removePinnedTrip(trip.id);
                      } else {
                        await ExpenseGroupStorage.setPinnedTrip(trip.id);
                      }
                      await _refreshTrip();
                      break;
                    case 'archive':
                      final updatedTrip = trip.copyWith(archived: !trip.archived);
                      final trips = await ExpenseGroupStorage.getAllGroups();
                      final idx = trips.indexWhere((v) => v.id == trip.id);
                      if (idx != -1) {
                        trips[idx] = updatedTrip;
                        await ExpenseGroupStorage.writeTrips(trips);
                      }
                      await _refreshTrip();
                      break;
                    case 'edit':
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddNewExpensesGroupPage(
                              trip: trip,
                              onTripDeleted: () async {
                                await _loadTrip();
                              }),
                        ),
                      );
                      if (result == true && context.mounted) {
                        await _refreshTrip();
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(
                      children: [
                        Icon(
                          trip.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(trip.pinned ? 'Rimuovi pin' : 'Aggiungi pin'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          trip.archived ? Icons.unarchive_rounded : Icons.archive_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(trip.archived ? loc.get('unarchive') : loc.get('archive')),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(loc.get('edit')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colorScheme.surfaceContainerHighest,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titolo e totale
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                trip.title,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            CurrencyDisplay(
                              value: totalExpenses,
                              currency: trip.currency,
                              valueFontSize: 24.0,
                              currencyFontSize: 18.0,
                              alignment: MainAxisAlignment.end,
                              showDecimals: true,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Badge stato sotto il titolo
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: trip.archived 
                                ? colorScheme.outline.withValues(alpha: 0.15)
                                : colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: trip.archived 
                                  ? colorScheme.outline 
                                  : colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trip.archived ? Icons.archive_rounded : Icons.play_circle_fill_rounded,
                                size: 14,
                                color: trip.archived 
                                    ? colorScheme.outline 
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip.archived ? loc.get('archived') : loc.get('active'),
                                style: TextStyle(
                                  color: trip.archived 
                                      ? colorScheme.outline 
                                      : colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Expenses Content in BaseCard
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: BaseCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: colorScheme.surface,
                child: _trip!.expenses.isEmpty
                    ? NoExpense(
                        semanticLabel: loc.get('no_expense_label'),
                      )
                    : Column(
                        children: () {
                          final expenses = List.from(_trip!.expenses)
                            ..sort((a, b) => b.date.compareTo(a.date));
                          return expenses.map<Widget>((expense) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: GestureDetector(
                                onTap: () => _openEditExpense(expense),
                                child: TripAmountCard(
                                  title: expense.category,
                                  coins: (expense.amount ?? 0).toInt(),
                                  checked: true,
                                  paidBy: expense.paidBy,
                                  category: null,
                                  date: expense.date,
                                  currency: _trip!.currency,
                                ),
                              ),
                            );
                          }).toList();
                        }(),
                      ),
              ),
            ),
          ),
          
          // Spazio aggiuntivo per garantire lo scroll
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverToBoxAdapter(child: Container()),
          ),
        ],
      ),
      floatingActionButton: !trip.archived
          ? FloatingActionButton.extended(
              heroTag: 'add-expense-fab',
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExpenseEditPage(
                      expense: ExpenseDetails(
                        category: '',
                        amount: 0,
                        paidBy: '',
                        date: DateTime.now(),
                        note: null,
                      ),
                      participants: trip.participants.map((p) => p.name).toList(),
                      categories: trip.categories.map((c) => c.name).toList(),
                      loc: loc,
                      tripStartDate: trip.startDate,
                      tripEndDate: trip.endDate,
                    ),
                  ),
                );
                if (result is ExpenseActionResult && result.updatedExpense != null) {
                  final trips = await ExpenseGroupStorage.getAllGroups();
                  final idx = trips.indexWhere((v) => v.id == trip.id);
                  if (idx != -1) {
                    trips[idx].expenses.add(result.updatedExpense!);
                    await ExpenseGroupStorage.writeTrips(trips);
                  }
                }
                if (mounted) await _refreshTrip();
              },
              label: const Text('Aggiungi Spesa'),
              icon: const Icon(Icons.add_rounded),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }
}
