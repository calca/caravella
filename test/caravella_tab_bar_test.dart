import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  group('CaravellaTabBar', () {
    testWidgets('renders with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Column(
                children: [
                  CaravellaTabBar(
                    tabs: const [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Content 1')),
                        Center(child: Text('Content 2')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify TabBar is present
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);

      // Verify styling is applied (through TabBar widget)
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 2);
      expect(tabBar.isScrollable, false);
    });

    testWidgets('works with scrollable tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 5,
            child: Scaffold(
              body: Column(
                children: [
                  CaravellaTabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    tabs: const [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                      Tab(text: 'Tab 3'),
                      Tab(text: 'Tab 4'),
                      Tab(text: 'Tab 5'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Content 1')),
                        Center(child: Text('Content 2')),
                        Center(child: Text('Content 3')),
                        Center(child: Text('Content 4')),
                        Center(child: Text('Content 5')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, true);
      expect(tabBar.tabAlignment, TabAlignment.center);
      expect(tabBar.tabs.length, 5);
    });

    testWidgets('works with custom TabController', (WidgetTester tester) async {
      final controller = TabController(length: 3, vsync: const TestVSync());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CaravellaTabBar(
                  controller: controller,
                  tabs: const [
                    Tab(text: 'Tab A'),
                    Tab(text: 'Tab B'),
                    Tab(text: 'Tab C'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller,
                    children: const [
                      Center(child: Text('Content A')),
                      Center(child: Text('Content B')),
                      Center(child: Text('Content C')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Tab A'), findsOneWidget);
      expect(find.text('Tab B'), findsOneWidget);
      expect(find.text('Tab C'), findsOneWidget);

      // Verify controller is properly connected
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.controller, controller);

      controller.dispose();
    });

    testWidgets('applies correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: DefaultTabController(
            length: 2,
            child: Scaffold(
              body: Column(
                children: [
                  CaravellaTabBar(
                    tabs: const [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Content 1')),
                        Center(child: Text('Content 2')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify TabBar uses theme colors
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      final context = tester.element(find.byType(CaravellaTabBar));
      final colorScheme = Theme.of(context).colorScheme;

      expect(tabBar.labelColor, colorScheme.onSurface);
      expect(tabBar.unselectedLabelColor, colorScheme.outline);
      expect(tabBar.indicatorColor, colorScheme.primary);
    });
  });
}

class TestVSync extends TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
