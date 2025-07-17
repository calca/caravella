import 'package:flutter/material.dart';
import '../../../data/expense_group.dart';
import '../tabs/overview_tab.dart';

class OverviewContent extends StatelessWidget {
  final ExpenseGroup trip;
  const OverviewContent({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return OverviewTab(trip: trip);
  }
}
