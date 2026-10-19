import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../../manager/details/pages/expense_group_detail_page.dart';
import '../../../manager/details/pages/expense_locations_map_page.dart';
import '../../../manager/details/pages/expense_search_page.dart';
import '../../../services/receipt_scanner_service.dart';
import 'add_expense_controller.dart';
import 'group_card_voice_button.dart';

/// Row of shortcuts under the featured group card on Home: new expense from
/// a receipt scan, new expense by voice, the group's map and search. They
/// sit below the floating navigation and are reached by scrolling (#529).
/// Scan and voice only appear where the device supports them; map and search
/// are disabled until the group has places / expenses.
class GroupQuickActions extends StatelessWidget {
  final ExpenseGroup group;

  /// Called after an expense is added by scan or voice.
  final VoidCallback onExpenseAdded;

  const GroupQuickActions({
    super.key,
    required this.group,
    required this.onExpenseAdded,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final hasExpenses = group.expenses.isNotEmpty;
    final hasPlaces = group.expenses.any((e) => e.location != null);
    final canScan = ReceiptScannerService().isAvailable;

    void push(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (canScan)
          _QuickAction(
            icon: Icons.document_scanner_outlined,
            label: gloc.quick_action_scan,
            semanticLabel: gloc.scan_receipt,
            onTap: () => AddExpenseController(
              group: group,
              onExpenseAdded: onExpenseAdded,
            ).scanReceiptAndAdd(context),
          ),
        // Hidden on devices without speech recognition.
        GroupCardVoiceButton(
          group: group,
          onExpenseAdded: onExpenseAdded,
          builder: (context, onPressed, listening) => _QuickAction(
            icon: listening ? Icons.mic_rounded : Icons.mic_none_rounded,
            label: gloc.quick_action_voice,
            semanticLabel: gloc.voice_add_expense,
            active: listening,
            onTap: onPressed,
          ),
        ),
        _QuickAction(
          icon: Icons.map_outlined,
          label: gloc.quick_action_map,
          onTap: hasPlaces
              ? () => push(ExpenseLocationsMapPage(group: group))
              : null,
        ),
        _QuickAction(
          icon: Icons.search_rounded,
          label: gloc.quick_action_search,
          onTap: hasExpenses
              ? () => ExpenseSearchPage.show(
                  context,
                  expenses: group.expenses,
                  categories: group.categories,
                  participants: group.participants,
                  currency: group.currency,
                  groupName: group.title,
                  // Expenses are edited from the group page.
                  onExpenseTap: (_) =>
                      push(ExpenseGroupDetailPage(trip: group)),
                )
              : null,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Spoken instead of [label] when the short label needs context.
  final String? semanticLabel;

  /// Highlighted (e.g. while listening).
  final bool active;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.semanticLabel,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final enabled = onTap != null;
    final fg = enabled ? s.onSurface : s.onSurface.withValues(alpha: 0.38);
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          width: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? s.primaryContainer : s.raisedSurface,
                ),
                child: Icon(icon, color: active ? s.onPrimaryContainer : fg),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
