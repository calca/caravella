import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/widgets/background_color_sheet.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, GroupFormState state) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ColorSheet(state: state),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the random color row picks another color and closes', (
    tester,
  ) async {
    for (
      var current = 0;
      current < ExpenseGroupColorPalette.paletteSize;
      current++
    ) {
      final state = GroupFormState()..setColor(current);
      await openSheet(tester, state);

      // The whole row reacts, not only a small button at its end.
      await tester.tap(find.text('Let the app pick a color for you'));
      await tester.pumpAndSettle();

      expect(state.color, isNotNull);
      expect(state.color, isNot(current));
      expect(find.byType(ColorSheet), findsNothing);
    }
  });
}
