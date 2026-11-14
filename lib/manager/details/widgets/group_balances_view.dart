import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

/// Balances of a group: for each participant what they get back (bar to the
/// right, primary) or owe (bar to the left, lighter primary — no alarming
/// red), then Settle up: the payments still to make ([computeSettlements]),
/// each with a reminder to share, followed by the ones already ticked as
/// paid ([ExpenseGroup.payments]), and a button sharing the whole summary.
///
/// The control at the right of each payment ticks it as paid, in full
/// ([markSettlementPaid]), or back to not paid ([unmarkPayment]); the new
/// payments go to [onPaymentsChanged]. Without it the rows are read-only.
///
/// [share] defaults to the system share sheet (overridable in tests).
class GroupBalancesView extends StatelessWidget {
  final ExpenseGroup group;
  final Future<void> Function(String text) share;
  final Future<void> Function(List<SettlePayment> payments)? onPaymentsChanged;

  const GroupBalancesView({
    super.key,
    required this.group,
    this.share = _systemShare,
    this.onPaymentsChanged,
  });

  static Future<void> _systemShare(String text) =>
      SharePlus.instance.share(ShareParams(text: text));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    // Whole cents, the same as Settle up: no 0.01 left once all is paid.
    final balances = outstandingBalances(group);
    final paidTotals = group.getParticipantTotals();
    final settlements = computeSettlements(group);
    final byId = {for (final p in group.participants) p.id: p};
    final rows = group.participants.toList()
      ..sort((a, b) => (balances[b.id] ?? 0).compareTo(balances[a.id] ?? 0));
    final maxAbs = balances.values.fold<double>(
      0,
      (m, v) => v.abs() > m ? v.abs() : m,
    );
    final number = NumberFormat(
      '#,##0.00',
      Localizations.localeOf(context).toString(),
    );
    String money(double v) => '${number.format(v.abs())} ${group.currency}';
    final day = DateFormat.MMMd(Localizations.localeOf(context).toString());
    final paid = [...group.payments]..sort((a, b) => b.date.compareTo(a.date));
    // Payments ticked in Settle up move money too: say so next to what
    // each person paid in expenses, or "Paid 0.00 € in all" looks wrong for
    // someone who just paid back.
    final sent = <String, double>{};
    final received = <String, double>{};
    for (final pay in group.payments) {
      sent[pay.fromId] = (sent[pay.fromId] ?? 0) + pay.amount;
      received[pay.toId] = (received[pay.toId] ?? 0) + pay.amount;
    }
    String paidLabel(String id) {
      final total = money(paidTotals[id] ?? 0);
      final out = sent[id] ?? 0;
      final back = received[id] ?? 0;
      if (out > 0) return gloc.balance_paid_and_settled(total, money(out));
      if (back > 0) return gloc.balance_paid_and_received(total, money(back));
      return gloc.balance_paid_total(total);
    }

    final onChanged = onPaymentsChanged;

    String summary() => [
      gloc.balances_share_title(group.title),
      for (final st in settlements)
        if ((byId[st.fromId], byId[st.toId]) case (final f?, final t?))
          '${f.name} → ${t.name}: ${money(st.amount)}',
      gloc.balances_share_footer(
        money(group.getTotalExpenses()),
        money(
          group.participants.isEmpty
              ? 0
              : group.getTotalExpenses() / group.participants.length,
        ),
      ),
    ].join('\n');

    Widget card(List<Widget> children) => CardOutline(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: s.raisedSurface,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(children: children),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // What the balances are measured against: everyone owes the
          // same share of the total.
          if (group.participants.length > 1) ...[
            _FairShareCard(
              share: group.getTotalExpenses() / group.participants.length,
              currency: group.currency,
              // The total is already in the header above.
              basis: gloc.balances_share_basis(group.participants.length),
            ),
            const SizedBox(height: 12),
          ],
          card([
            for (final p in rows)
              _BalanceRow(
                participant: p,
                balance: balances[p.id] ?? 0,
                maxAbs: maxAbs,
                currency: group.currency,
                paidLabel: paidLabel(p.id),
                semanticLabel:
                    '${(balances[p.id] ?? 0) >= 0 ? gloc.balance_gets_back(p.name, money(balances[p.id] ?? 0)) : gloc.balance_owes(p.name, money(balances[p.id] ?? 0))}, '
                    '${paidLabel(p.id)}',
              ),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SettingsLabel(gloc.settle_up),
          ),
          card([
            if (settlements.isEmpty)
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
            for (var i = 0; i < settlements.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: s.outlineVariant.withValues(alpha: 0.5),
                ),
              if (byId[settlements[i].fromId] case final from?)
                if (byId[settlements[i].toId] case final to?)
                  _SettleRow(
                    from: from,
                    to: to,
                    amount: settlements[i].amount,
                    currency: group.currency,
                    semanticLabel: gloc.settlement_pays(
                      from.name,
                      to.name,
                      money(settlements[i].amount),
                    ),
                    shareTooltip: '${gloc.send_reminder}: ${from.name}',
                    onShare: () => share(
                      gloc.balance_reminder_message(
                        from.name,
                        group.title,
                        money(settlements[i].amount),
                        to.name,
                      ),
                    ),
                    toggleTooltip: gloc.settle_mark_paid,
                    onToggle: onChanged == null
                        ? null
                        : () => onChanged(
                            markSettlementPaid(group, settlements[i]).payments,
                          ),
                  ),
            ],
            for (var i = 0; i < paid.length; i++) ...[
              if (i > 0 || settlements.isNotEmpty)
                Divider(
                  height: 1,
                  color: s.outlineVariant.withValues(alpha: 0.5),
                ),
              if (byId[paid[i].fromId] case final from?)
                if (byId[paid[i].toId] case final to?)
                  _SettleRow(
                    from: from,
                    to: to,
                    amount: paid[i].amount,
                    currency: group.currency,
                    paidLabel: gloc.settle_paid_on(day.format(paid[i].date)),
                    semanticLabel: gloc.settlement_paid(
                      from.name,
                      to.name,
                      money(paid[i].amount),
                    ),
                    toggleTooltip: gloc.settle_mark_unpaid,
                    onToggle: onChanged == null
                        ? null
                        : () => onChanged(
                            unmarkPayment(group, paid[i].id).payments,
                          ),
                  ),
            ],
          ]),
          if (settlements.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: s.primaryContainer,
                foregroundColor: s.onPrimaryContainer,
              ),
              onPressed: () => share(summary()),
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(gloc.share_balances),
            ),
          ],
        ],
      ),
    );
  }
}

/// The share each participant owes (total ÷ people), the reference the
/// balances below are measured against.
class _FairShareCard extends StatelessWidget {
  final double share;
  final String currency;
  final String basis;

  const _FairShareCard({
    required this.share,
    required this.currency,
    required this.basis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final radius = BorderRadius.circular(20);
    final amount = CurrencyDisplay(
      value: share,
      currency: currency,
      valueFontSize: 22,
      currencyFontSize: 13,
      showDecimals: true,
    );
    // Large text: the amount under the title instead of beside it.
    final large = MediaQuery.textScalerOf(context).scale(14) / 14 >= 1.3;
    return Semantics(
      container: true,
      label:
          '${gloc.balances_share_per_person}: '
          '${CurrencyDisplay.formatLocalizedText(share, currency, Localizations.maybeLocaleOf(context))}, $basis',
      excludeSemantics: true,
      child: CardOutline(
        borderRadius: radius,
        child: Material(
          color: s.raisedSurface,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.surfaceContainerHighest,
                  ),
                  child: Icon(Icons.call_split_rounded, color: s.onSurface),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gloc.balances_share_per_person,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (large) ...[
                        const SizedBox(height: 4),
                        amount,
                        const SizedBox(height: 2),
                      ],
                      Text(
                        basis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!large) ...[const SizedBox(width: 8), amount],
              ],
            ),
          ),
        ),
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

  /// What they paid in all ("Paid 390.90 € in all"), under the row.
  final String paidLabel;

  const _BalanceRow({
    required this.participant,
    required this.balance,
    required this.maxAbs,
    required this.currency,
    required this.semanticLabel,
    required this.paidLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final positive = balance >= 0;
    final settled = balance.abs() < 0.01;
    // One hue: who gets money back in full primary, who owes in a lighter
    // primary (bar only — the amount stays onSurface, readable at AA).
    final barColor = settled
        ? s.onSurfaceVariant
        : positive
        ? s.primary
        : s.primary.withValues(alpha: 0.4);
    final textColor = settled || !positive ? s.onSurface : s.primary;
    final fraction = maxAbs == 0 ? 0.0 : balance.abs() / maxAbs;

    final name = Text(
      participant.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
    final amount = Text(
      '${settled ? '' : (positive ? '+' : '−')}'
      '${NumberFormat('#,##0.00', Localizations.localeOf(context).toString()).format(balance.abs())} $currency',
      textAlign: TextAlign.end,
      maxLines: 1,
      style: theme.textTheme.titleSmall?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    // Bar from the center: right = gets back, left = owes.
    final bar = SizedBox(
      height: 12,
      child: LayoutBuilder(
        builder: (context, c) {
          final half = c.maxWidth / 2;
          final w = half * fraction;
          return Stack(
            children: [
              Positioned(
                left: half - 0.75,
                top: -2,
                bottom: -2,
                // onSurfaceVariant: outlineVariant vanished on the dark card.
                child: Container(
                  width: 1.5,
                  color: s.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              Positioned(
                left: positive ? half : half - w,
                width: w,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
    final avatar = ParticipantAvatar(participant: participant, size: 32);
    // Under the name, past the avatar.
    final paid = Padding(
      padding: const EdgeInsets.only(left: 42, top: 2),
      child: Text(
        paidLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: s.onSurfaceVariant),
      ),
    );

    // Large text: name and amount on one line, the bar under them, so
    // neither is cut ("So…", "+217." / "30 €").
    final large = MediaQuery.textScalerOf(context).scale(14) / 14 >= 1.3;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: large
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 10),
                      Expanded(child: name),
                      const SizedBox(width: 8),
                      amount,
                    ],
                  ),
                  paid,
                  const SizedBox(height: 8),
                  bar,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 10),
                      SizedBox(width: 64, child: name),
                      Expanded(child: bar),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 92,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: amount,
                        ),
                      ),
                    ],
                  ),
                  paid,
                ],
              ),
      ),
    );
  }
}

/// One payment in Settle up: who pays whom and how much; for one still to
/// make ([paidLabel] null) a reminder to share; at the right, whether it is
/// paid — a filled check — or still to pay — a clock — tapping to switch.
class _SettleRow extends StatelessWidget {
  final ExpenseParticipant from;
  final ExpenseParticipant to;
  final double amount;
  final String currency;
  final String semanticLabel;
  final String? paidLabel;
  final String? shareTooltip;
  final VoidCallback? onShare;
  final String toggleTooltip;
  final VoidCallback? onToggle;

  const _SettleRow({
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.semanticLabel,
    required this.toggleTooltip,
    this.paidLabel,
    this.shareTooltip,
    this.onShare,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final isPaid = paidLabel != null;
    final done = isPaid
        ? TextStyle(
            color: s.onSurfaceVariant,
            decoration: TextDecoration.lineThrough,
            decorationColor: s.onSurfaceVariant,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: semanticLabel,
              excludeSemantics: true,
              child: Row(
                children: [
                  ParticipantAvatar(participant: from, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: from.name),
                              const TextSpan(text: '  →  '),
                              TextSpan(text: to.name),
                            ],
                          ),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)
                              .merge(done),
                        ),
                        if (paidLabel case final label?)
                          Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: s.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  CurrencyDisplay(
                    value: amount,
                    currency: currency,
                    valueFontSize: 20,
                    currencyFontSize: 13,
                    showDecimals: true,
                    color: isPaid ? s.onSurfaceVariant : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (onShare case final share?)
            IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              iconSize: 20,
              color: s.onSurfaceVariant,
              tooltip: shareTooltip,
              onPressed: share,
            )
          else
            const SizedBox(width: 48),
          if (onToggle != null)
            IconButton(
              tooltip: toggleTooltip,
              isSelected: isPaid,
              onPressed: onToggle,
              icon: Icon(Icons.schedule_rounded, color: s.onSurfaceVariant),
              selectedIcon: Icon(Icons.check_circle_rounded, color: s.primary),
              iconSize: 28,
            ),
        ],
      ),
    );
  }
}
