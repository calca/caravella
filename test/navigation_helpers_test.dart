import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:caravella_core/caravella_core.dart';

import 'package:io_caravella_egm/home/navigation_helpers.dart';
import 'package:io_caravella_egm/manager/group/pages/group_creation_wizard_page.dart';

void main() {
  group('NavigationHelpers Tests', () {
    testWidgets(
      'openGroupCreationWithCallback should NOT call callback when wizard is cancelled',
      (WidgetTester tester) async {
        bool callbackInvoked = false;
        String? receivedGroupId;

        // Create a test app with the wizard
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
              ChangeNotifierProvider(create: (_) => UserNameNotifier()),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                gen.AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: gen.AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await NavigationHelpers.openGroupCreationWithCallback(
                            context,
                            onGroupAdded: ([groupId]) {
                              callbackInvoked = true;
                              receivedGroupId = groupId;
                            },
                          );
                        },
                        child: const Text('Open Wizard'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the button to open the wizard
        await tester.tap(find.text('Open Wizard'));
        await tester.pumpAndSettle();

        // Verify wizard is shown
        expect(find.byType(GroupCreationWizardPage), findsOneWidget);

        // Tap the back button to cancel the wizard
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Try to confirm the discard dialog if it appears
        final discardButton = find.text('Discard').hitTestable();
        if (tester.any(discardButton)) {
          await tester.tap(discardButton);
          await tester.pumpAndSettle();
        }

        // Verify callback was NOT invoked when wizard was cancelled
        expect(callbackInvoked, isFalse,
            reason: 'Callback should not be invoked when wizard is cancelled');
        expect(receivedGroupId, isNull,
            reason: 'Group ID should be null when wizard is cancelled');
      },
    );

    testWidgets(
      'openGroupCreation should return null when wizard is cancelled',
      (WidgetTester tester) async {
        String? result;

        // Create a test app with the wizard
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
              ChangeNotifierProvider(create: (_) => UserNameNotifier()),
            ],
            child: MaterialApp(
              localizationsDelegates: const [
                gen.AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: gen.AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          result = await NavigationHelpers.openGroupCreation(
                            context,
                          );
                        },
                        child: const Text('Open Wizard'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap the button to open the wizard
        await tester.tap(find.text('Open Wizard'));
        await tester.pumpAndSettle();

        // Verify wizard is shown
        expect(find.byType(GroupCreationWizardPage), findsOneWidget);

        // Tap the back button to cancel the wizard
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // Try to confirm the discard dialog if it appears
        final discardButton = find.text('Discard').hitTestable();
        if (tester.any(discardButton)) {
          await tester.tap(discardButton);
          await tester.pumpAndSettle();
        }

        // Verify result is null when wizard was cancelled
        expect(result, isNull,
            reason: 'Should return null when wizard is cancelled');
      },
    );
  });
}
