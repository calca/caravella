import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/models/global_balance.dart';
import 'package:io_caravella_egm/home/models/group_item.dart';
import 'package:io_caravella_egm/home/new_home/new_home_page.dart';
import 'package:io_caravella_egm/home/new_home/widgets/our_tab_header.dart';
import 'package:io_caravella_egm/home/new_home/widgets/global_balance_card.dart';
import 'package:io_caravella_egm/home/new_home/widgets/group_list_section.dart';
import 'package:io_caravella_egm/home/new_home/widgets/group_card_widget.dart';

void main() {
  group('GlobalBalance Model', () {
    test('creates instance with correct values', () {
      const balance = GlobalBalance(
        total: 100.0,
        owedToYou: 150.0,
        youOwe: 50.0,
      );

      expect(balance.total, 100.0);
      expect(balance.owedToYou, 150.0);
      expect(balance.youOwe, 50.0);
    });

    test('toJson and fromJson work correctly', () {
      const balance = GlobalBalance(
        total: 100.0,
        owedToYou: 150.0,
        youOwe: 50.0,
      );

      final json = balance.toJson();
      final recreated = GlobalBalance.fromJson(json);

      expect(recreated.total, balance.total);
      expect(recreated.owedToYou, balance.owedToYou);
      expect(recreated.youOwe, balance.youOwe);
    });
  });

  group('GroupItem Model', () {
    test('creates instance with correct values', () {
      final group = GroupItem(
        id: '1',
        name: 'Test Group',
        lastActivity: DateTime(2024, 1, 1),
        amount: 50.0,
        status: GroupStatus.positive,
        emoji: '🎉',
      );

      expect(group.id, '1');
      expect(group.name, 'Test Group');
      expect(group.amount, 50.0);
      expect(group.status, GroupStatus.positive);
      expect(group.emoji, '🎉');
    });

    test('toJson and fromJson work correctly', () {
      final group = GroupItem(
        id: '1',
        name: 'Test Group',
        lastActivity: DateTime(2024, 1, 1),
        amount: 50.0,
        status: GroupStatus.positive,
        emoji: '🎉',
      );

      final json = group.toJson();
      final recreated = GroupItem.fromJson(json);

      expect(recreated.id, group.id);
      expect(recreated.name, group.name);
      expect(recreated.amount, group.amount);
      expect(recreated.status, group.status);
      expect(recreated.emoji, group.emoji);
    });
  });

  group('OurTabHeader Widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OurTabHeader(
              userName: 'Test User',
              hasNotifications: true,
            ),
          ),
        ),
      );

      expect(find.text('Ciao, Test User 👋'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });

  group('GlobalBalanceCard Widget', () {
    testWidgets('renders correctly with positive balance', (WidgetTester tester) async {
      const balance = GlobalBalance(
        total: 100.0,
        owedToYou: 150.0,
        youOwe: 50.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalBalanceCard(balance: balance),
          ),
        ),
      );

      expect(find.text('Il tuo bilancio totale'), findsOneWidget);
      expect(find.textContaining('+100.00'), findsOneWidget);
      expect(find.text('Ti devono'), findsOneWidget);
      expect(find.text('Devi'), findsOneWidget);
    });

    testWidgets('renders correctly with negative balance', (WidgetTester tester) async {
      const balance = GlobalBalance(
        total: -50.0,
        owedToYou: 100.0,
        youOwe: 150.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlobalBalanceCard(balance: balance),
          ),
        ),
      );

      expect(find.textContaining('-50.00'), findsOneWidget);
    });
  });

  group('GroupCardWidget', () {
    testWidgets('renders correctly for positive status', (WidgetTester tester) async {
      final group = GroupItem(
        id: '1',
        name: 'Test Group',
        lastActivity: DateTime.now(),
        amount: 50.0,
        status: GroupStatus.positive,
        emoji: '🎉',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCardWidget(group: group),
          ),
        ),
      );

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.text('🎉'), findsOneWidget);
      expect(find.text('Ti devono'), findsOneWidget);
    });

    testWidgets('renders correctly for negative status', (WidgetTester tester) async {
      final group = GroupItem(
        id: '2',
        name: 'Another Group',
        lastActivity: DateTime.now(),
        amount: -25.0,
        status: GroupStatus.negative,
        emoji: '💰',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCardWidget(group: group),
          ),
        ),
      );

      expect(find.text('Another Group'), findsOneWidget);
      expect(find.text('Devi'), findsOneWidget);
    });

    testWidgets('renders correctly for settled status', (WidgetTester tester) async {
      final group = GroupItem(
        id: '3',
        name: 'Settled Group',
        lastActivity: DateTime.now(),
        amount: 0.0,
        status: GroupStatus.settled,
        emoji: '✅',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupCardWidget(group: group),
          ),
        ),
      );

      expect(find.text('Settled Group'), findsOneWidget);
      expect(find.text('Saldato'), findsOneWidget);
    });
  });

  group('GroupListSection Widget', () {
    testWidgets('renders empty state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupListSection(groups: []),
          ),
        ),
      );

      expect(find.text('Gruppi Attivi'), findsOneWidget);
      expect(find.text('Nessun gruppo attivo'), findsOneWidget);
    });

    testWidgets('renders groups list correctly', (WidgetTester tester) async {
      final groups = [
        GroupItem(
          id: '1',
          name: 'Group 1',
          lastActivity: DateTime.now(),
          amount: 50.0,
          status: GroupStatus.positive,
        ),
        GroupItem(
          id: '2',
          name: 'Group 2',
          lastActivity: DateTime.now(),
          amount: -25.0,
          status: GroupStatus.negative,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupListSection(groups: groups),
          ),
        ),
      );

      expect(find.text('Gruppi Attivi'), findsOneWidget);
      expect(find.text('Group 1'), findsOneWidget);
      expect(find.text('Group 2'), findsOneWidget);
    });
  });

  group('NewHomePage Widget', () {
    testWidgets('renders complete page correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewHomePage(),
        ),
      );

      // Verify header is present
      expect(find.text('Ciao, Alessandro 👋'), findsOneWidget);
      
      // Verify balance card is present
      expect(find.text('Il tuo bilancio totale'), findsOneWidget);
      
      // Verify groups section is present
      expect(find.text('Gruppi Attivi'), findsOneWidget);
      
      // Verify FAB is present
      expect(find.widgetWithText(FloatingActionButton, 'Nuovo'), findsOneWidget);
      
      // Verify bottom navigation items
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Amici'), findsOneWidget);
      expect(find.text('Attività'), findsOneWidget);
      expect(find.text('Profilo'), findsOneWidget);
    });

    testWidgets('bottom navigation responds to taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewHomePage(),
        ),
      );

      // Tap on "Amici" tab
      await tester.tap(find.text('Amici'));
      await tester.pump();
      
      // The tap should work without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('FAB responds to tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NewHomePage(),
        ),
      );

      // Tap on FAB
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Nuovo'));
      await tester.pump();
      
      // A snackbar should appear
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Aggiungi nuovo gruppo o spesa'), findsOneWidget);
    });
  });
}
