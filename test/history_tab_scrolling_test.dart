import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/history/expenses_history_page.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/state/expense_group_notifier.dart';

void main() {
  Widget createTestApp({required Widget home}) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier()),
          ],
          child: home,
        ),
      );

  group('History Page Tab Scrolling Tests', () {
    testWidgets('TabBar has scrollable properties configured correctly', (
      WidgetTester tester,
    ) async {
      // Pump the history page
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      // Wait for the page to settle
      await tester.pumpAndSettle();

      // Find the TabBar widget
      final tabBarFinder = find.byType(TabBar);
      expect(tabBarFinder, findsOneWidget);

      // Get the TabBar widget and verify scrollable properties
      final TabBar tabBar = tester.widget(tabBarFinder);
      
      // Verify that isScrollable is set to true
      expect(
        tabBar.isScrollable,
        true,
        reason: 'TabBar should be scrollable to enable horizontal scrolling',
      );

      // Verify that tabAlignment is set to center (consistent with existing code)
      expect(
        tabBar.tabAlignment,
        TabAlignment.center,
        reason: 'TabBar alignment should be center for consistency with overview page',
      );

      // Verify that indicatorSize is set to label for better scrolling behavior
      expect(
        tabBar.indicatorSize,
        TabBarIndicatorSize.label,
        reason: 'Indicator size should be label for better visual feedback when scrolling',
      );
    });

    testWidgets('TabBar has correct number of tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      await tester.pumpAndSettle();

      // Find all tabs
      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsNWidgets(2));

      // Verify tab texts (these should be localized)
      final tabs = tester.widgetList<Tab>(tabFinder).toList();
      expect(tabs.length, 2);
      
      // The actual text will depend on locale, but there should be 2 tabs
      expect(tabs[0].text, isNotNull);
      expect(tabs[1].text, isNotNull);
    });

    testWidgets('TabController is properly configured for 2 tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      await tester.pumpAndSettle();

      // Find the TabBar and verify it has a controller
      final TabBar tabBar = tester.widget(find.byType(TabBar));
      expect(tabBar.controller, isNotNull);
      expect(tabBar.controller!.length, 2);
    });
  });
}