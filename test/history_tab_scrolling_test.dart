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

  group('History Page Tab Scrolling and Swipe Tests', () {
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

    testWidgets('TabBarView is present and enables swipe gestures', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      await tester.pumpAndSettle();

      // Find the TabBarView widget
      final tabBarViewFinder = find.byType(TabBarView);
      expect(
        tabBarViewFinder, 
        findsOneWidget,
        reason: 'TabBarView should be present to enable swipe gestures between tabs'
      );

      // Get the TabBarView widget and verify it has correct controller
      final TabBarView tabBarView = tester.widget(tabBarViewFinder);
      expect(
        tabBarView.controller, 
        isNotNull,
        reason: 'TabBarView should have a controller'
      );
      
      // Verify that the controller has 2 tabs (Active and Archived)
      expect(
        tabBarView.controller!.length, 
        2,
        reason: 'TabBarView should have 2 tabs for Active and Archived'
      );
    });

    testWidgets('User can swipe between Active and Archived tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      await tester.pumpAndSettle();

      // Find TabBar and TabBarView
      final tabBarFinder = find.byType(TabBar);
      final tabBarViewFinder = find.byType(TabBarView);
      
      expect(tabBarFinder, findsOneWidget);
      expect(tabBarViewFinder, findsOneWidget);

      // Get initial tab index (should be 0 for Active tab)
      final TabBar tabBar = tester.widget(tabBarFinder);
      final initialIndex = tabBar.controller?.index ?? 0;
      expect(initialIndex, 0, reason: 'Should start on Active tab (index 0)');

      // Perform swipe gesture from right to left (to go to next tab)
      await tester.drag(tabBarViewFinder, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify that we've moved to the second tab (Archived)
      final newIndex = tabBar.controller?.index ?? 0;
      expect(
        newIndex, 
        1, 
        reason: 'After swiping left, should be on Archived tab (index 1)'
      );

      // Perform swipe gesture from left to right (to go back to first tab)
      await tester.drag(tabBarViewFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Verify that we've moved back to the first tab (Active)
      final finalIndex = tabBar.controller?.index ?? 1;
      expect(
        finalIndex, 
        0, 
        reason: 'After swiping right, should be back on Active tab (index 0)'
      );
    });

    testWidgets('Tab taps work correctly with TabBarView', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(home: const ExpesensHistoryPage()),
      );
      
      await tester.pumpAndSettle();

      // Find all tabs
      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsNWidgets(2));

      final TabBar tabBar = tester.widget(find.byType(TabBar));
      expect(tabBar.controller?.index, 0, reason: 'Should start on first tab');

      // Tap on the second tab (Archived)
      await tester.tap(tabFinder.at(1));
      await tester.pumpAndSettle();

      // Verify we've switched to the second tab
      expect(
        tabBar.controller?.index, 
        1, 
        reason: 'Should be on second tab after tapping it'
      );

      // Tap on the first tab (Active)
      await tester.tap(tabFinder.at(0));
      await tester.pumpAndSettle();

      // Verify we've switched back to the first tab
      expect(
        tabBar.controller?.index, 
        0, 
        reason: 'Should be back on first tab after tapping it'
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