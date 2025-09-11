import 'package:flutter/material.dart';
import 'dart:io';
import '../../../data/model/expense_group.dart';
import '../../../data/model/expense_participant.dart';

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
    final initials = participant.name.length >= 2
        ? participant.name.substring(0, 2).toUpperCase()
        : participant.name.toUpperCase();

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
    final Color bgColor = trip.color != null
        ? Color(trip.color!)
        : (backgroundColor ?? colorScheme.surfaceContainerLowest);
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
  const GroupHeader({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double circleSize = MediaQuery.of(context).size.width * 0.3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            children: [
              ExpenseGroupAvatar(trip: trip, size: circleSize),
              if (trip.pinned || trip.archived)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceDim,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      trip.pinned
                          ? Icons.push_pin_outlined
                          : Icons.archive_outlined,
                      size: circleSize * 0.15,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
