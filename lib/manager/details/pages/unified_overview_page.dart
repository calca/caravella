import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../tabs/unified_overview_tab.dart';

/// Full screen page replacement for the previous bottom sheet overview/statistics.
class UnifiedOverviewPage extends StatelessWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.overview),
      ),
      body: UnifiedOverviewTab(trip: trip),
    );
  }
}
