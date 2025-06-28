import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../data/trip.dart';
import '../../../../app_localizations.dart';
import '../../../../widgets/currency_display.dart';

class CategoriesPieChart extends StatelessWidget {
  final Trip trip;
  final AppLocalizations loc;

  const CategoriesPieChart({
    super.key,
    required this.trip,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    // Calcola i totali per categoria
    final Map<String, double> categoryTotals = {};
    
    // Aggiungi le categorie definite
    for (final category in trip.categories) {
      final total = trip.expenses
          .where((e) => e.category == category)
          .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
      if (total > 0) {
        categoryTotals[category] = total;
      }
    }

    // Aggiungi le spese non categorizzate
    final uncategorizedTotal = trip.expenses
        .where((e) => e.category.isEmpty || !trip.categories.contains(e.category))
        .fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
    
    if (uncategorizedTotal > 0) {
      categoryTotals[loc.get('uncategorized')] = uncategorizedTotal;
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
      Theme.of(context).colorScheme.surfaceVariant,
      Theme.of(context).colorScheme.primaryContainer,
      Theme.of(context).colorScheme.secondaryContainer,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('expenses_by_category'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        
        // Grafico a torta
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              sections: sortedEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryEntry = entry.value;
                final percentage = (categoryEntry.value / categoryTotals.values.reduce((a, b) => a + b)) * 100;
                
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: categoryEntry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: null,
                );
              }).toList(),
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Aggiungi interattività se necessario
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Leggenda sotto il grafico
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: sortedEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryEntry = entry.value;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  categoryEntry.key,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                CurrencyDisplay(
                  value: categoryEntry.value,
                  currency: trip.currency,
                  valueFontSize: 11,
                  currencyFontSize: 9,
                  showDecimals: false,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
