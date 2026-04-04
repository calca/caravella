import 'package:flutter/material.dart';
import 'dart:io';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

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
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: trip.file != null && trip.file!.isNotEmpty
          ? ClipOval(
              child: Image.file(
                File(trip.file!),
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    trip.title.length >= 2
                        ? trip.title.substring(0, 2).toUpperCase()
                        : trip.title.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                trip.title.length >= 2
                    ? trip.title.substring(0, 2).toUpperCase()
                    : trip.title.toUpperCase(),
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
  final VoidCallback? onPinToggle;

  const GroupHeader({super.key, required this.trip, this.onPinToggle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double circleSize = MediaQuery.of(context).size.width * 0.3;
    final gloc = gen.AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: trip.archived ? null : onPinToggle,
                child: Semantics(
                  button: true,
                  enabled: !trip.archived,
                  label: trip.pinned ? gloc.unpin_group : gloc.pin_group,
                  child: ExpenseGroupAvatar(trip: trip, size: circleSize),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: trip.archived ? null : onPinToggle,
                  child: Semantics(
                    button: true,
                    enabled: !trip.archived,
                    label: trip.pinned ? gloc.unpin_group : gloc.pin_group,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceDim,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          trip.pinned
                              ? Icons.favorite
                              : (trip.archived
                                    ? Icons.archive_outlined
                                    : Icons.favorite_border),
                          key: ValueKey(trip.pinned ? 'pinned' : 'unpinned'),
                          size: circleSize * 0.15,
                          color: trip.pinned
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
}
