import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';

/// Circular avatar showing a participant's initials.
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

/// Circular avatar showing an expense group's initials, colored from its
/// palette index (or a legacy raw ARGB value).
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
