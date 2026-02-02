import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_total.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'group_card_today_spending.dart';

/// Small widget extracted from GroupCardContent showing
/// total and today's spending side-by-side with animations.
class GroupCardAmounts extends StatefulWidget {
  final ExpenseGroup group;
  final ThemeData theme;
  final gen.AppLocalizations localizations;

  const GroupCardAmounts({
    super.key,
    required this.group,
    required this.theme,
    required this.localizations,
  });

  @override
  State<GroupCardAmounts> createState() => _GroupCardAmountsState();
}

class _GroupCardAmountsState extends State<GroupCardAmounts> {
  double? _todaySpending;
  bool _isInitialLoad = true;

  // Cache previous values to avoid unnecessary animations
  double? _previousTotal;
  double? _previousTodaySpending;

  @override
  void initState() {
    super.initState();
    _loadTodaySpending();
  }

  @override
  void didUpdateWidget(GroupCardAmounts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id ||
        oldWidget.group.expenses.length != widget.group.expenses.length) {
      _loadTodaySpending();
    }
  }

  Future<void> _loadTodaySpending() async {
    final spending = await ExpenseGroupStorageV2.getTodaySpending(
      widget.group.id,
    );
    if (mounted) {
      setState(() {
        _todaySpending = spending;
        _isInitialLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = widget.group.getTotalExpenses();
    final todaySpending = _todaySpending ?? 0.0;

    // Track if values actually changed (not just initial load)
    final shouldAnimateTotal =
        !_isInitialLoad &&
        _previousTotal != null &&
        _previousTotal != totalExpenses;
    final shouldAnimateTodaySpending =
        !_isInitialLoad &&
        _previousTodaySpending != null &&
        _previousTodaySpending != todaySpending;

    // Update previous values for next comparison
    _previousTotal = totalExpenses;
    _previousTodaySpending = todaySpending;

    // Use stable keys during initial load to prevent unwanted animations
    // Once loaded, use value-based keys to animate on actual changes
    final totalKey = _isInitialLoad
        ? const ValueKey<String>('total_initial')
        : ValueKey<double>(totalExpenses);
    final todayKey = _isInitialLoad
        ? const ValueKey<String>('today_initial')
        : ValueKey<double>(todaySpending);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Animated total with scale and fade (only when value actually changes)
        AnimatedSwitcher(
          duration: shouldAnimateTotal
              ? const Duration(milliseconds: 600)
              : Duration.zero,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                ),
                child: child,
              ),
            );
          },
          child: Align(
            key: totalKey,
            alignment: Alignment.center,
            child: GroupTotal(
              total: totalExpenses,
              currency: widget.group.currency,
              alignment: CrossAxisAlignment.center,
              valueFontSize: 36.0,
              currencyFontSize: 24.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Animated daily spending badge (only when value actually changes)
        AnimatedSwitcher(
          duration: shouldAnimateTodaySpending
              ? const Duration(milliseconds: 500)
              : Duration.zero,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, -0.3),
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
          child: Align(
            key: todayKey,
            alignment: Alignment.center,
            child: GroupCardTodaySpending(
              todaySpending: todaySpending,
              currency: widget.group.currency,
              theme: widget.theme,
              localizations: widget.localizations,
            ),
          ),
        ),
      ],
    );
  }
}
