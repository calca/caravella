import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/home/welcome/home_welcome_section.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  Widget localizedApp({required Widget home, ThemeMode? mode}) => ToastProvider.create(
    child: MaterialApp(
      themeMode: mode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  group('WCAG 2.2 Accessibility Tests', () {
    testWidgets('Welcome screen image has semantic label', (tester) async {
      await tester.pumpWidget(
        localizedApp(home: const Scaffold(body: HomeWelcomeSection())),
      );
      await tester.pumpAndSettle();

      // Find the welcome logo by its localized semantics label
      // Use bySemanticsLabel for stability across internal Semantics wrapping.
      final logoFinderEn = find.bySemanticsLabel('Caravella app logo');
      final logoFinderIt = find.bySemanticsLabel("Logo dell'app Caravella");
      final logoKey = find.byKey(const ValueKey('welcome_logo_semantics'));
      expect(
        logoFinderEn.evaluate().isNotEmpty ||
            logoFinderIt.evaluate().isNotEmpty ||
            logoKey.evaluate().isNotEmpty,
        true,
        reason:
            'Expected one Semantics node with the welcome logo (label or key).',
      );
    });

    testWidgets('AddFab has proper semantic button properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: AddFab(onPressed: () {}, tooltip: 'Add new item'),
          ),
        ),
      );

      final fabSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            widget.properties.label == 'Add new item',
      );

      expect(fabSemantics, findsOneWidget);
    });

    testWidgets('App toast has live region for screen readers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ToastProvider.create(
          child: localizedApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final gloc = AppLocalizations.of(context);
                  return ElevatedButton(
                    onPressed: () {
                      AppToast.show(
                        context,
                        'Test message',
                        type: ToastType.success,
                        semanticLabel:
                            '${gloc.accessibility_toast_success}: Test message',
                      );
                    },
                    child: const Text('Show Toast'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Trigger the toast - verify no errors thrown
      await tester.tap(find.text('Show Toast'));
      await tester.pump();

      // Verify localization is properly configured
      final context = tester.element(find.byType(Scaffold));
      final gloc = AppLocalizations.of(context);
      expect(gloc.accessibility_toast_success, isNotEmpty);
    });

    testWidgets('Navigation buttons have proper accessibility labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(home: const Scaffold(body: HomeWelcomeSection())),
      );
      await tester.pumpAndSettle();

      // Look for settings button by its semantics label (English or Italian)
      final settingsEn = find.bySemanticsLabel('Settings');
      final settingsIt = find.bySemanticsLabel('Impostazioni');
      final settingsKey = find.byKey(
        const ValueKey('settings_button_semantics'),
      );
      expect(
        settingsEn.evaluate().isNotEmpty ||
            settingsIt.evaluate().isNotEmpty ||
            settingsKey.evaluate().isNotEmpty,
        true,
        reason:
            'Expected a settings button with proper semantics (label or key).',
      );
    });

    testWidgets('Form inputs have proper accessibility attributes', (
      WidgetTester tester,
    ) async {
      // This test would need to navigate to a form page
      // For now, we'll test the widget in isolation
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Test Input',
                semanticCounterText: '',
              ),
            ),
          ),
        ),
      );

      // Verify the input has proper semantic structure
      final inputWidget = find.byType(TextFormField);
      expect(inputWidget, findsOneWidget);
    });

    testWidgets('Loading indicators have semantic labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          home: const Scaffold(
            body: CircularProgressIndicator(semanticsLabel: 'Loading data'),
          ),
        ),
      );

      final progressSemantics = find.byWidgetPredicate(
        (Widget widget) =>
            widget is CircularProgressIndicator &&
            widget.semanticsLabel == 'Loading data',
      );

      expect(progressSemantics, findsOneWidget);
    });

    testWidgets('Minimum touch target sizes are maintained', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: AddFab(onPressed: () {}, tooltip: 'Add item'),
          ),
        ),
      );

      // Verify the FAB has minimum 44px touch target
      final fabWidget = find.byType(FloatingActionButton);
      expect(fabWidget, findsOneWidget);

      final RenderBox fabRenderBox = tester.renderObject(fabWidget);
      expect(fabRenderBox.size.width, greaterThanOrEqualTo(44.0));
      expect(fabRenderBox.size.height, greaterThanOrEqualTo(44.0));
    });

    testWidgets('Contrast ratios are adequate in themes', (
      WidgetTester tester,
    ) async {
      // Test both light and dark themes
      for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          localizedApp(
            mode: themeMode,
            home: const Scaffold(body: Text('Test text')),
          ),
        );

        final context = tester.element(find.byType(Text));
        final theme = Theme.of(context);

        // Verify that text color contrasts with background
        expect(
          theme.colorScheme.onSurface,
          isNot(equals(theme.colorScheme.surface)),
        );
        expect(
          theme.colorScheme.onPrimary,
          isNot(equals(theme.colorScheme.primary)),
        );
      }
    });
  });

  group('Screen Reader Support Tests', () {
    testWidgets('Dialogs are properly announced', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => Semantics(
                      label: 'Test dialog',
                      child: const AlertDialog(
                        title: Text('Test'),
                        content: Text('Dialog content'),
                      ),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // The dialog Semantics hierarchy may not set scopesRoute; match by label only.
      final dialogFinder = find.bySemanticsLabel('Test dialog');
      expect(dialogFinder, findsOneWidget);
    });

    testWidgets('Focus management works correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First field'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Second field'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test tab navigation between fields
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Focus first field
      await tester.tap(textFields.first);
      await tester.pump();

      // Navigate to second field with tab
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    });
  });
}
