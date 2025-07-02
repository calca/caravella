import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/expense_group.dart';
import '../../data/expense_group_storage.dart';
import '../../manager/add_new_expenses_group.dart';
import '../../manager/detail_page/trip_detail_page.dart';
import '../../manager/trips_history_page.dart';
import '../../settings/settings_page.dart';
import '../../state/locale_notifier.dart';

class HomeCardsSection extends StatefulWidget {
  final VoidCallback onTripAdded;

  const HomeCardsSection({
    super.key,
    required this.onTripAdded,
  });

  @override
  State<HomeCardsSection> createState() => _HomeCardsSectionState();
}

class _HomeCardsSectionState extends State<HomeCardsSection> {
  List<ExpenseGroup> _activeGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveGroups();
  }

  Future<void> _loadActiveGroups() async {
    try {
      final groups = await ExpenseGroupStorage.getActiveGroups();
      if (mounted) {
        setState(() {
          _activeGroups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 18) return 'good_afternoon';
    return 'good_evening';
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con saluto dinamico
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.get(_getGreeting()),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.get('your_groups'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Content area - occupa 2/3 della pagina
          SizedBox(
            height: screenHeight * 0.67, // 2/3 della pagina
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _activeGroups.isEmpty
                    ? _buildEmptyState(context, loc, theme)
                    : _buildHorizontalGroupsList(context, loc, theme, screenWidth),
          ),

          // Bottom bar semplificata
          _buildSimpleBottomBar(context, loc, theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations loc, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            loc.get('no_active_groups'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            loc.get('no_active_groups_subtitle'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddNewExpensesGroupPage(),
                ),
              );
              if (result == true) {
                widget.onTripAdded();
                _loadActiveGroups();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(loc.get('create_first_group')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalGroupsList(BuildContext context, AppLocalizations loc, ThemeData theme, double screenWidth) {
    return PageView.builder(
      itemCount: _activeGroups.length,
      padEnds: false,
      controller: PageController(
        viewportFraction: 0.85, // Mostra parte della card successiva
      ),
      itemBuilder: (context, index) {
        final group = _activeGroups[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildGroupCard(context, group, loc, theme),
        );
      },
    );
  }

  Widget _buildGroupCard(BuildContext context, ExpenseGroup group, AppLocalizations loc, ThemeData theme) {
    final totalExpenses = group.expenses.fold<double>(0, (sum, expense) => sum + (expense.amount ?? 0));
    final participantCount = group.participants.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripDetailPage(trip: group),
            ),
          );
          if (result == true) {
            widget.onTripAdded();
            _loadActiveGroups();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header della card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (group.pinned)
                    Icon(
                      Icons.push_pin,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Info del gruppo
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$participantCount ${loc.get('participants').toLowerCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${group.expenses.length} ${loc.get('expenses').toLowerCase()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              
              if (group.startDate != null || group.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateRange(group, loc),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Totale spese
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.euro,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '€${totalExpenses.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
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
    );
  }

  String _formatDateRange(ExpenseGroup group, AppLocalizations loc) {
    final start = group.startDate;
    final end = group.endDate;
    
    if (start != null && end != null) {
      return '${_formatDate(start)} - ${_formatDate(end)}';
    } else if (start != null) {
      return 'Dal ${_formatDate(start)}';
    } else if (end != null) {
      return 'Fino al ${_formatDate(end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSimpleBottomBar(BuildContext context, AppLocalizations loc, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          // Bottone Cronologia
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TripsHistoryPage()),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Text(
                loc.get('history').toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          const SizedBox(width: 16), // Spazio tra i bottoni
          
          // Bottone Impostazioni
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              child: Text(
                loc.get('settings').toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
