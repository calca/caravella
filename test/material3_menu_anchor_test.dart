import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/widgets/material3_menu_anchor.dart';

void main() {
  group('Material3MenuAnchor', () {
    testWidgets('should render with menu items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3MenuAnchor(
              menuItems: [
                Material3MenuItem(
                  text: 'Item 1',
                  onPressed: () {},
                ),
                Material3MenuItem(
                  text: 'Item 2',
                  onPressed: () {},
                ),
              ],
              child: const Text('Anchor'),
            ),
          ),
        ),
      );

      expect(find.text('Anchor'), findsOneWidget);
      expect(find.byType(MenuAnchor), findsOneWidget);
    });

    testWidgets('should handle menu open/close callbacks', (WidgetTester tester) async {
      bool onOpenCalled = false;
      bool onCloseCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3MenuAnchor(
              menuItems: [
                Material3MenuItem(
                  text: 'Item 1',
                  onPressed: () {},
                ),
              ],
              onOpen: () => onOpenCalled = true,
              onClose: () => onCloseCalled = true,
              child: const Text('Anchor'),
            ),
          ),
        ),
      );

      // Find the MenuAnchor and trigger menu interactions
      final menuAnchor = tester.widget<MenuAnchor>(find.byType(MenuAnchor));
      expect(menuAnchor.onOpen, isNotNull);
      expect(menuAnchor.onClose, isNotNull);
    });
  });

  group('Material3MenuItem', () {
    testWidgets('should render with text and icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3MenuItem(
              text: 'Test Item',
              leadingIcon: Icons.star,
              trailingIcon: Icons.arrow_forward,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byType(MenuItemButton), findsOneWidget);
    });

    testWidgets('should handle disabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3MenuItem(
              text: 'Disabled Item',
              enabled: false,
            ),
          ),
        ),
      );

      final menuButton = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
      expect(menuButton.onPressed, isNull);
    });
  });

  group('Material3SubmenuButton', () {
    testWidgets('should render with submenu items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material3SubmenuButton(
              text: 'Submenu',
              leadingIcon: Icons.folder,
              menuItems: [
                Material3MenuItem(
                  text: 'Sub Item 1',
                  onPressed: () {},
                ),
                Material3MenuItem(
                  text: 'Sub Item 2',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Submenu'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
      expect(find.byType(SubmenuButton), findsOneWidget);
    });
  });

  group('Material3MenuDivider', () {
    testWidgets('should render as divider', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Material3MenuDivider(),
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });
  });
}