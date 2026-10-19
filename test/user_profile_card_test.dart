import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/settings/widgets/general_settings_section.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('saving an emptied name closes the dialog without errors', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'user_name': 'Anna'});
    final user = UserNameNotifier();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: user,
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: UserProfileCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Anna'), findsOneWidget);

    await tester.tap(find.byType(UserProfileCard));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsNothing);
    expect(user.hasName, isFalse);
  });
}
