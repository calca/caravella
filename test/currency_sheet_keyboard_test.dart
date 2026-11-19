import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/group/widgets/currency_selector_sheet.dart';
import 'package:material_ui/material_ui.dart';

/// Opened on its own (the group wizard), the currency sheet sat behind the
/// keyboard its focused search field brings up: only the title and the
/// field showed, the list was hidden.
void main() {
  testWidgets('the currency list shows above the keyboard', (tester) async {
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
                onPressed: () => showAppBottomSheet<Map<String, String>>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const CurrencySelectorSheet(),
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

    // The keyboard comes up: 380 dp, with its suggestion strip.
    tester.view.viewInsets = const FakeViewPadding(bottom: 380 * 2.625);
    await tester.pumpAndSettle();

    final screen = tester.view.physicalSize.height / 2.625;
    final keyboardTop = screen - 380;
    // The whole list sits above the keyboard, its first row on show.
    final list = tester.getRect(find.byType(ListView));
    expect(list.bottom, lessThanOrEqualTo(keyboardTop + 0.5));
    expect(
      tester.getRect(find.byType(ListTile).first).bottom,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getRect(find.byType(TextField)).bottom,
      lessThan(keyboardTop),
    );
    expect(tester.takeException(), isNull);
  });
}
