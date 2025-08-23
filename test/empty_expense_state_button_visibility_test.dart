import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/manager/details/widgets/empty_expense_state.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'Add First Expense button is always visible above navigation bar',
    (tester) async {
      // Simulate a device with a bottom navigation bar (e.g. Android)
      const fakeBottomInset = 48.0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 800),
              viewPadding: EdgeInsets.only(bottom: fakeBottomInset),
            ),
            child: Scaffold(body: EmptyExpenseState(onAddFirstExpense: () {})),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the button
      final buttonFinder = find.textContaining('Add First Expense');
      expect(buttonFinder, findsOneWidget);

      // Get the button's RenderBox and global position
      final buttonBox = tester.renderObject<RenderBox>(buttonFinder);
      final buttonBottom = buttonBox
          .localToGlobal(buttonBox.size.bottomRight(Offset.zero))
          .dy;

      // Get screen height and bottom inset
      final screenHeight =
          tester.binding.window.physicalSize.height /
          tester.binding.window.devicePixelRatio;
      // Use the simulated value for bottom inset
      final expectedBottom = screenHeight - fakeBottomInset;

      // The button's bottom should be above the navigation bar
      expect(buttonBottom <= expectedBottom, true);
    },
  );
}
