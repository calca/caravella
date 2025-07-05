import 'package:flutter/material.dart';

class HistoryFilterSection extends StatelessWidget {
  final List<Map<String, dynamic>> periodOptions;
  final String selectedPeriod;
  final Function(String) onFilterChanged;
  final Animation<double> filterAnimation;
  final VoidCallback onToggleFilters;

  const HistoryFilterSection({
    super.key,
    required this.periodOptions,
    required this.selectedPeriod,
    required this.onFilterChanged,
    required this.filterAnimation,
    required this.onToggleFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Toggle Button
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHigh
                .withValues(alpha: 0.8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggleFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtri',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: filterAnimation.value * 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Animated Filter Options
        AnimatedBuilder(
          animation: filterAnimation,
          builder: (context, child) {
            return Container(
              height: filterAnimation.value * 80,
              margin: const EdgeInsets.only(top: 8),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Opacity(
                  opacity: filterAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: periodOptions.map((option) {
                        final isSelected = selectedPeriod == option['key'];
                        return _buildFilterChip(
                          context,
                          option['label'],
                          option['icon'],
                          isSelected,
                          () => onFilterChanged(option['key']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: isSelected
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
