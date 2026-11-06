import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/widgets/stat_card.dart';
import 'package:io_caravella_egm/manager/expense/state/expense_form_controller.dart';
import 'package:io_caravella_egm/manager/expense/validation/expense_validation_service.dart';
import 'package:io_caravella_egm/manager/expense/widgets/amount_input_widget.dart';
import 'package:material_ui/material_ui.dart';

Widget _app(Locale locale, Widget child) => MaterialApp(
  locale: locale,
  supportedLocales: gen.AppLocalizations.supportedLocales,
  localizationsDelegates: appLocalizationsDelegates,
  home: Scaffold(body: child),
);

void main() {
  Widget amountField(Locale locale, TextEditingController controller) => _app(
    locale,
    AmountInputWidget(
      controller: controller,
      label: 'Importo',
      focusNode: FocusNode(),
    ),
  );

  testWidgets('the amount field follows the language', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(amountField(const Locale('it'), controller));
    await tester.pumpAndSettle();

    expect(find.text('0,00'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '12.34');
    expect(controller.text, '12,34');
    expect(ExpenseValidationService.parseAmount(controller.text), 12.34);
  });

  testWidgets('English keeps the dot, whatever is typed', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(amountField(const Locale('en'), controller));
    await tester.pumpAndSettle();

    expect(find.text('0.00'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '12,34');
    expect(controller.text, '12.34');
  });

  test('a saved amount opens with the separator of the language', () {
    expect(
      ExpenseFormController.formatAmountForInput(54.5, decimalSeparator: ','),
      '54,50',
    );
    expect(
      ExpenseFormController.formatAmountForInput(12, decimalSeparator: ','),
      '12',
    );
  });

  testWidgets('percentages follow the language', (tester) async {
    await tester.pumpWidget(
      _app(
        const Locale('it'),
        const StatCard(
          title: 'Alloggio',
          value: 1,
          currency: '€',
          percent: 12.5,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12,5%'), findsOneWidget);
  });
}
