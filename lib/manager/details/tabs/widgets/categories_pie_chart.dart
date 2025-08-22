import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/model/expense_group.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../../widgets/currency_display.dart';
import '../../../../data/model/expense_category.dart';

class CategoriesPieChart extends StatelessWidget {
  final ExpenseGroup trip;

  const CategoriesPieChart({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    // Calcola i totali per categoria (ExpenseCategory come chiave)
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final category in trip.categories) {
      final total = trip.expenses
          .where((e) => e.category.id == category.id)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      if (total > 0) {
        categoryTotals[category] = total;
      }
    }

    // Aggiungi le spese non categorizzate (categoria non presente tra quelle note)
    final uncategorizedTotal = trip.expenses
        .where((e) => !trip.categories.any((c) => c.id == e.category.id))
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

    if (uncategorizedTotal > 0) {
      // Crea una categoria fittizia per "Senza categoria"
      final uncategorized = ExpenseCategory(
        name: gloc.uncategorized,
        id: 'uncategorized',
        createdAt: DateTime(2000),
      );
      categoryTotals[uncategorized] = uncategorizedTotal;
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordina per valore decrescente
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Colori per le fette - solo colori del tema
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.error,
      Theme.of(context).colorScheme.outline,
      Theme.of(context).colorScheme.inversePrimary,
      Theme.of(context).colorScheme.surface,
      Theme.of(context).colorScheme.surfaceContainerHighest,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gloc.expenses_by_category,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        // Pie chart centrato
        Center(
          child: SizedBox(
            height: 180,
            width: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: -90,
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final categoryEntry = entry.value;
                  final percentage =
                      (categoryEntry.value /
                          categoryTotals.values.reduce((a, b) => a + b)) *
                      100;

                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: categoryEntry.value,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    badgeWidget: null,
                  );
                }).toList(),
                pieTouchData: PieTouchData(enabled: false),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Legenda sotto il grafico (wrap responsivo)
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryEntry = entry.value;
            return ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 140),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      categoryEntry.key.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CurrencyDisplay(
                    value: categoryEntry.value,
                    currency: trip.currency,
                    valueFontSize: 12,
                    currencyFontSize: 10,
                    showDecimals: false,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
