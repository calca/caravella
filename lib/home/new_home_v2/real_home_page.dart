import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../main/route_observer.dart';
import 'widgets/real_home_header.dart';
import 'widgets/featured_group_card.dart';
import 'widgets/other_groups_section.dart';
import 'widgets/recent_activity_section.dart';

/// Real functional home page based on the new design mockup.
/// Features: balance summary, featured group card, other groups, recent activity.
class RealHomePage extends StatefulWidget {
  const RealHomePage({super.key});

  @override
  State<RealHomePage> createState() => _RealHomePageState();
}

class _RealHomePageState extends State<RealHomePage> with RouteAware {
  ExpenseGroup? _pinnedGroup;
  List<ExpenseGroup> _otherGroups = [];
  List<ExpenseDetails> _recentExpenses = [];
  bool _loading = true;
  ExpenseGroupNotifier? _groupNotifier;
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);

    _groupNotifier?.removeListener(_onGroupUpdated);
    _groupNotifier = context.read<ExpenseGroupNotifier>();
    _groupNotifier?.addListener(_onGroupUpdated);
  }

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onGroupUpdated);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadData();
  }

  void _onGroupUpdated() {
    final updatedGroupIds = _groupNotifier?.updatedGroupIds ?? [];
    if (updatedGroupIds.isNotEmpty && mounted) {
      _loadData();
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

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final allGroups = await ExpenseGroupStorageV2.getActiveGroups();
      final pinnedGroup = await ExpenseGroupStorageV2.getPinnedTrip();
      
      // Calculate total balance across all groups
      double totalBalance = 0.0;
      for (final group in allGroups) {
        totalBalance += _calculateGroupBalance(group);
      }

      // Get other groups (non-pinned)
      final otherGroups = allGroups.where((g) => g.id != pinnedGroup?.id).toList();

      // Get recent expenses from all groups
      final recentExpenses = <ExpenseDetails>[];
      for (final group in allGroups) {
        recentExpenses.addAll(group.expenses);
      }
      recentExpenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      if (mounted) {
        setState(() {
          _pinnedGroup = pinnedGroup;
          _otherGroups = otherGroups;
          _recentExpenses = recentExpenses.take(10).toList();
          _totalBalance = totalBalance;
          _loading = false;
        });
      }
    } catch (e) {
      LoggerService.warning('Error loading home data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  double _calculateGroupBalance(ExpenseGroup group) {
    // Calculate user's balance in this group
    // This is a simplified calculation - adjust based on your actual balance logic
    double balance = 0.0;
    
    // Get current user (simplified - you may need to get this from a user service)
    final userName = 'Tu'; // Replace with actual current user
    
    for (final expense in group.expenses) {
      if (expense.paidBy.name == userName) {
        // User paid, so they are owed
        balance += expense.amount;
      }
      // Subtract proportional share
      final participantCount = expense.participants.length;
      if (participantCount > 0) {
        balance -= expense.amount / participantCount;
      }
    }
    
    return balance;
  }

  void _onSearchTap() {
    // TODO: Implement search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ricerca')),
    );
  }

  void _onSettingsTap() {
    // TODO: Navigate to settings
    Navigator.pushNamed(context, '/settings');
  }

  void _onGroupTap(ExpenseGroup group) {
    // TODO: Navigate to group details
    Navigator.pushNamed(
      context,
      '/group-detail',
      arguments: group.id,
    );
  }

  void _onSettlePayment() {
    // TODO: Implement settle payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salda pagamento')),
    );
  }

  void _onAddNew() {
    // TODO: Show add new dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aggiungi nuovo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(
            semanticsLabel: gloc.accessibility_loading_your_groups,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                RealHomeHeader(
                  onSearchTap: _onSearchTap,
                  onSettingsTap: _onSettingsTap,
                ),
                const SizedBox(height: 8),

                // Balance summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'In totale ti spettano: ',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _totalBalance >= 0
                              ? '+${_totalBalance.toStringAsFixed(2)}€'
                              : '${_totalBalance.toStringAsFixed(2)}€',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _totalBalance >= 0
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Featured/Pinned group card
                if (_pinnedGroup != null) ...[
                  const SizedBox(height: 8),
                  FeaturedGroupCard(
                    group: _pinnedGroup!,
                    balance: _calculateGroupBalance(_pinnedGroup!),
                    onTap: () => _onGroupTap(_pinnedGroup!),
                    onSettlePayment: _onSettlePayment,
                  ),
                ],

                // Other active groups
                if (_otherGroups.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  OtherGroupsSection(
                    groups: _otherGroups,
                    onGroupTap: _onGroupTap,
                  ),
                ],

                // Recent activity
                if (_recentExpenses.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  RecentActivitySection(
                    expenses: _recentExpenses,
                  ),
                ],

                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddNew,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
