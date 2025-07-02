import 'package:flutter/material.dart';

class NoExpense extends StatelessWidget {
  final String semanticLabel;
  const NoExpense({super.key, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        width: 180,
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long,
                size: 100,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                semanticLabel: semanticLabel,
              ),
              const SizedBox(height: 16),
              Text(
                semanticLabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
