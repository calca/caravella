import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/services/permission_dialog.dart';
import 'package:material_ui/material_ui.dart';

/// A refused permission asks, with a way to the settings, instead of a
/// toast with nothing to tap (#618).
void main() {
  Future<void> open(WidgetTester tester, DeniedPermission p) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showPermissionDeniedDialog(context, p),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('camera: the question, Open settings and Not now', (
    tester,
  ) async {
    await open(tester, DeniedPermission.camera);
    expect(find.text('Allow the camera?'), findsOneWidget);
    expect(find.text('Open settings'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Allow the camera?'), findsNothing);
  });

  testWidgets('each permission has its own question', (tester) async {
    await open(tester, DeniedPermission.notifications);
    expect(find.text('Allow notifications?'), findsOneWidget);
  });
}
