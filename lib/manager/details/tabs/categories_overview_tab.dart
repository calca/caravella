import 'package:flutter/material.dart';
import '../../../data/model/expense_group.dart';
import 'widgets/daily_average_by_category.dart';
import 'widgets/categories_pie_chart.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Categories analysis tab: daily average by category + distribution pie chart.
class CategoriesOverviewTab extends StatelessWidget {
  final ExpenseGroup trip;
  const CategoriesOverviewTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (trip.expenses.isEmpty) {
      return Center(
        child: Text(
          gloc.no_expenses_for_statistics,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          DailyAverageByCategoryWidget(trip: trip),
          const SizedBox(height: 32),
          CategoriesPieChart(trip: trip),
        ],
      ),
    );
  }
}
