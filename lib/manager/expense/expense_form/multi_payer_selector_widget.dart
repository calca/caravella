import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_participant.dart';

/// Allows selecting up to [maxPayers] participants that will split the payment equally.
class MultiPayerSelectorWidget extends StatelessWidget {
  final List<ExpenseParticipant> participants;
  final List<ExpenseParticipant> selected;
  final int maxPayers;
  final ValueChanged<ExpenseParticipant> onToggle;
  final TextStyle? textStyle;
  final double? totalAmount;
  final String? currency;

  const MultiPayerSelectorWidget({
    super.key,
    required this.participants,
    required this.selected,
    required this.maxPayers,
    required this.onToggle,
    required this.textStyle,
    this.totalAmount,
    this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSplit = selected.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in participants)
              FilterChip(
                label: Text(p.name, style: textStyle),
                selected: selected.any((s) => s.id == p.id),
                onSelected: (value) {
                  onToggle(p);
                },
                shape: StadiumBorder(
                  side: BorderSide(
                    color: selected.any((s) => s.id == p.id)
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
                selectedColor: colorScheme.primaryContainer,
                showCheckmark: selected.length > 1,
              ),
          ],
        ),
        if (isSplit) ...[
          const SizedBox(height: 6),
          _SplitHint(
            selected: selected,
            totalAmount: totalAmount,
            currency: currency,
          ),
        ],
      ],
    );
  }
}

class _SplitHint extends StatelessWidget {
  final List<ExpenseParticipant> selected;
  final double? totalAmount;
  final String? currency;

  const _SplitHint({
    required this.selected,
    required this.totalAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (selected.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final amount = totalAmount;
    String shareText;
    final loc = gen.AppLocalizations.of(context);
    if (amount == null || amount <= 0) {
      shareText = loc.multi_payer_split_equally;
    } else {
      final rawShare = amount / selected.length;
      final shareFloor = (rawShare * 100).floor() / 100.0; // first share
      final remainder = double.parse(
        (amount - shareFloor * (selected.length - 1)).toStringAsFixed(2),
      );
      if (selected.length == 2) {
        shareText = '${_fmt(shareFloor)} + ${_fmt(remainder)}';
      } else {
        shareText = '${_fmt(shareFloor)} ${loc.multi_payer_each}';
      }
      if (currency != null) shareText = '$shareText $currency';
    }
    final names = selected.map((e) => e.name).join(' & ');
    return Row(
      children: [
        Icon(Icons.call_split, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$names: $shareText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);
}
