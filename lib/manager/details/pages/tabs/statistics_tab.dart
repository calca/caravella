import 'package:flutter/material.dart';
import '../../../../data/model/expense_group.dart';

/// Minimal legacy placeholder: original StatisticsTab merged into UnifiedOverviewTab.
/// Kept only so existing duration tests compile. Remove after updating tests.
class StatisticsTab extends StatelessWidget {
  final ExpenseGroup trip;
  const StatisticsTab({super.key, required this.trip});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
