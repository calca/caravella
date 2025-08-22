import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../tabs/unified_overview_tab.dart';
import '../../../../widgets/bottom_sheet_scaffold.dart';

class UnifiedOverviewSheet extends StatelessWidget {
  final ExpenseGroup trip;
  final ScrollController? scrollController;
  const UnifiedOverviewSheet({
    super.key,
    required this.trip,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GroupBottomSheetScaffold(
      title: gloc.overview,
      scrollable: true,
      scrollController: scrollController,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        child: UnifiedOverviewTab(trip: trip),
      ),
    );
  }
}
