import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/widgets/expense_amount_card.dart';
import '../../../manager/details/pages/expense_group_detail_page.dart';

class GroupCardRecents extends StatefulWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const GroupCardRecents({
    super.key,
    required this.group,
    required this.localizations,
    required this.theme,
  });

  @override
  State<GroupCardRecents> createState() => _GroupCardRecentsState();
}

class _GroupCardRecentsState extends State<GroupCardRecents> {
  List<ExpenseDetails>? _cachedRecentExpenses;
  String? _cachedGroupId;

  @override
  void didUpdateWidget(GroupCardRecents oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache if group changed or expenses changed
    if (oldWidget.group.id != widget.group.id ||
        oldWidget.group.expenses.length != widget.group.expenses.length) {
      _cachedRecentExpenses = null;
      _cachedGroupId = null;
    }
  }

  Future<List<ExpenseDetails>> _getRecentExpenses() async {
    // Use cached result if available and group hasn't changed
    if (_cachedRecentExpenses != null && _cachedGroupId == widget.group.id) {
      return _cachedRecentExpenses!;
    }

    // Fetch from storage API
    final recentExpenses = await ExpenseGroupStorageV2.getRecentExpenses(
      widget.group.id,
      limit: 2,
    );

    // Cache the result
    _cachedRecentExpenses = recentExpenses;
    _cachedGroupId = widget.group.id;

    return recentExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseDetails>>(
      future: _getRecentExpenses(),
      builder: (ctx, snapshot) {
        // Handle loading state - keep showing cached data if available
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show cached data if available, otherwise hide
          if (_cachedRecentExpenses != null &&
              _cachedRecentExpenses!.isNotEmpty) {
            final lastTwo = _cachedRecentExpenses!;
            return _buildRecentsColumn(ctx, lastTwo);
          }
          return const SizedBox.shrink();
        }

        // Handle error state silently (fail gracefully) - keep showing cached data if available
        if (snapshot.hasError || !snapshot.hasData) {
          if (_cachedRecentExpenses != null &&
              _cachedRecentExpenses!.isNotEmpty) {
            final lastTwo = _cachedRecentExpenses!;
            return _buildRecentsColumn(ctx, lastTwo);
          }
          return const SizedBox.shrink();
        }

        final lastTwo = snapshot.data!;
        if (lastTwo.isEmpty) return const SizedBox.shrink();

        return _buildRecentsColumn(ctx, lastTwo);
      },
    );
  }

  Widget _buildRecentsColumn(BuildContext ctx, List<ExpenseDetails> lastTwo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.localizations.recent_expenses.toUpperCase(),
          style: widget.theme.textTheme.labelSmall?.copyWith(
            color: widget.theme.colorScheme.onSurfaceVariant.withValues(
              alpha: 0.5,
            ),
            fontWeight: FontWeight.w400,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<String>(lastTwo.map((e) => e.id).join('-')),
            children: lastTwo.asMap().entries.map((entry) {
              final index = entry.key;
              final e = entry.value;
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6.0),
                  child: ExpenseAmountCard(
                    title: e.name ?? '',
                    amount: e.amount ?? 0,
                    checked: true,
                    paidBy: e.paidBy,
                    category: e.category.name,
                    date: e.date,
                    showDate: false,
                    compact: true,
                    fullWidth: true,
                    currency: widget.group.currency,
                    onTap: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ExpenseGroupDetailPage(trip: widget.group),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
