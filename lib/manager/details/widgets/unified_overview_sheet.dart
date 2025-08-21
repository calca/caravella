import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/expense_group.dart';
import '../tabs/unified_overview_tab.dart';
import '../../../../widgets/bottom_sheet_scaffold.dart';

class UnifiedOverviewSheet extends StatelessWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewSheet({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GroupBottomSheetScaffold(
      title: gloc.overview,
      scrollable: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        child: UnifiedOverviewTab(trip: trip),
      ),
    );
  }
}
