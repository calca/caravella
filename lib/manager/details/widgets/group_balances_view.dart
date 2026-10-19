import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Balances of a group: for each participant what they get back (bar to the
/// right, primary) or owe (bar to the left, error), then the payments that
/// settle the group ([computeSettlements]).
class GroupBalancesView extends StatelessWidget {
  final ExpenseGroup group;

  const GroupBalancesView({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final balances = computeBalances(group);
    final settlements = computeSettlements(group);
    final byId = {for (final p in group.participants) p.id: p};
    final rows = group.participants.toList()
      ..sort((a, b) => (balances[b.id] ?? 0).compareTo(balances[a.id] ?? 0));
    final maxAbs = balances.values.fold<double>(
      0,
      (m, v) => v.abs() > m ? v.abs() : m,
    );
    String money(double v) => '${v.abs().toStringAsFixed(2)} ${group.currency}';

    Widget card(List<Widget> children) => CardOutline(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: s.raisedSurface,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: children),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card([
            for (final p in rows)
              _BalanceRow(
                participant: p,
                balance: balances[p.id] ?? 0,
                maxAbs: maxAbs,
                currency: group.currency,
                semanticLabel: (balances[p.id] ?? 0) >= 0
                    ? gloc.balance_gets_back(p.name, money(balances[p.id] ?? 0))
                    : gloc.balance_owes(p.name, money(balances[p.id] ?? 0)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 20, 6, 8),
            child: Semantics(
              header: true,
              child: Text(
                gloc.settle_up,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (settlements.isEmpty)
            card([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: s.primary),
                    const SizedBox(width: 12),
                    Text(gloc.all_settled_up, style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
            ])
          else
            card([
              for (var i = 0; i < settlements.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: s.outlineVariant.withValues(alpha: 0.5),
                  ),
                if (byId[settlements[i].fromId] case final from?)
                  if (byId[settlements[i].toId] case final to?)
                    Semantics(
                      label: gloc.settlement_pays(
                        from.name,
                        to.name,
                        money(settlements[i].amount),
                      ),
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            ParticipantAvatar(participant: from, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: from.name),
                                    const TextSpan(text: '  →  '),
                                    TextSpan(text: to.name),
                                  ],
                                ),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            CurrencyDisplay(
                              value: settlements[i].amount,
                              currency: group.currency,
                              valueFontSize: 20,
                              currencyFontSize: 13,
                              showDecimals: true,
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ]),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final ExpenseParticipant participant;
  final double balance;
  final double maxAbs;
  final String currency;
  final String semanticLabel;

  const _BalanceRow({
    required this.participant,
    required this.balance,
    required this.maxAbs,
    required this.currency,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final positive = balance >= 0;
    final settled = balance.abs() < 0.01;
    final color = settled
        ? s.onSurfaceVariant
        : positive
        ? s.primary
        : s.error;
    final fraction = maxAbs == 0 ? 0.0 : balance.abs() / maxAbs;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ParticipantAvatar(participant: participant, size: 32),
            const SizedBox(width: 10),
            SizedBox(
              width: 64,
              child: Text(
                participant.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Bar from the center: right = gets back, left = owes.
            Expanded(
              child: SizedBox(
                height: 12,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final half = c.maxWidth / 2;
                    final w = half * fraction;
                    return Stack(
                      children: [
                        Positioned(
                          left: half - 0.5,
                          top: -2,
                          bottom: -2,
                          child: Container(width: 1, color: s.outlineVariant),
                        ),
                        Positioned(
                          left: positive ? half : half - w,
                          width: w,
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 92,
              child: Text(
                '${settled ? '' : (positive ? '+' : '−')}'
                '${balance.abs().toStringAsFixed(2)} $currency',
                textAlign: TextAlign.end,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
