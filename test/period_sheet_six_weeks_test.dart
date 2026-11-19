import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/group/widgets/period_selection_bottom_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// November 2026 starts on a Sunday, so its 30th falls in a sixth week.
/// The calendar was 240 dp tall, room for about five rows of day cells:
/// the last week was cut off.
void main() {
  testWidgets('a month spanning six weeks shows its last day in full', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: CaravellaThemes.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showPeriodSelectionBottomSheet(
                  context: context,
                  initialStartDate: DateTime(2026, 11, 3),
                  initialEndDate: DateTime(2026, 11, 7),
                  onSelectionChanged: (_, _) {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final grid = tester.getRect(find.byType(GridView));
    final day30 = find.descendant(
      of: find.byType(GridView),
      matching: find.text('30'),
    );
    expect(day30, findsOneWidget);
    final cell = tester.getRect(day30);
    expect(cell.bottom, lessThanOrEqualTo(grid.bottom));
    // The 30th answers a tap: it isn't clipped away.
    await tester.tap(day30);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
