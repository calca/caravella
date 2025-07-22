import 'package:flutter/material.dart';
import 'dart:io';
import '../../../data/expense_group.dart';

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
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surfaceContainer,
                ),
                child: trip.file != null && trip.file!.isNotEmpty
                    ? ClipOval(
                        child: Image.file(
                          File(trip.file!),
                          fit: BoxFit.cover,
                          width: circleSize,
                          height: circleSize,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              trip.title.length >= 2
                                  ? trip.title.substring(0, 2).toUpperCase()
                                  : trip.title.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: circleSize * 0.4,
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
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: circleSize * 0.4,
                              ),
                        ),
                      ),
              ),
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
