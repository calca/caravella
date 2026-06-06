import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'group_total.dart';

class ParticipantAvatar extends StatelessWidget {
  final ExpenseParticipant participant;
  final double size;
  const ParticipantAvatar({
    super.key,
    required this.participant,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Build initials from first and last word when possible (e.g., "John Doe" -> "JD").
    // Fallback to first two characters for single-word names.
    final parts = participant.name
        .trim()
        .split(RegExp(r"\s+"))
        .where((p) => p.isNotEmpty)
        .toList();
    String initials;
    if (parts.length >= 2) {
      final first = parts.first;
      final last = parts.last;
      initials =
          (first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '');
    } else if (participant.name.length >= 2) {
      initials = participant.name.substring(0, 2);
    } else {
      initials = participant.name;
    }
    initials = initials.toUpperCase();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.surfaceContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class ExpenseGroupAvatar extends StatelessWidget {
  final ExpenseGroup trip;
  final double size;
  final Color? backgroundColor;
  const ExpenseGroupAvatar({
    super.key,
    required this.trip,
    required this.size,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Resolve color from palette index or use legacy color value
    Color bgColor;
    if (trip.color != null) {
      if (ExpenseGroupColorPalette.isLegacyColorValue(trip.color)) {
        // Legacy ARGB value - use as-is
        bgColor = Color(trip.color!);
      } else {
        // New palette index - resolve to theme-aware color
        bgColor =
            ExpenseGroupColorPalette.resolveColor(trip.color, colorScheme) ??
            (backgroundColor ?? colorScheme.surfaceContainerLowest);
      }
    } else {
      bgColor = backgroundColor ?? colorScheme.surfaceContainerLowest;
    }
    final initials = trip.title.length >= 2
        ? trip.title.substring(0, 2).toUpperCase()
        : trip.title.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

class GroupHeader extends StatelessWidget {
  final ExpenseGroup trip;
  final double totalExpenses;
  final double todaySpending;

  const GroupHeader({
    super.key,
    required this.trip,
    required this.totalExpenses,
    required this.todaySpending,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          trip.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GroupTotal(
              total: totalExpenses,
              currency: trip.currency,
              alignment: CrossAxisAlignment.center,
              valueFontSize: 34,
              currencyFontSize: 22,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CurrencyDisplay(
                value: todaySpending.abs(),
                currency: trip.currency,
                valueFontSize: 16,
                currencyFontSize: 12,
                alignment: MainAxisAlignment.start,
                showDecimals: true,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(width: 8),
              Text(
                gloc.spent_today.toLowerCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
