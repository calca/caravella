import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_content.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Home card and group page in the group's tint: chip (Home), big type
/// icon, "Total | Today"; no color is neutral grey; on the group page the
/// type is an icon on the favorite's row.
void main() {
  const sky = Color(0xFFAED6EE);

  ExpenseGroup group({int? color, bool pinned = false}) => ExpenseGroup(
    id: 'g1',
    title: 'Lisbon',
    expenses: [],
    participants: [ExpenseParticipant(id: '1', name: 'Anna')],
    categories: [ExpenseCategory(id: '1', name: 'Food')],
    currency: '€',
    timestamp: DateTime(2026, 12, 1),
    groupType: ExpenseGroupType.travel,
    color: color,
    pinned: pinned,
  );

  Widget app(Widget Function(BuildContext) child) => MaterialApp(
    localizationsDelegates: const [
      gen.AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ExpenseGroupNotifier(),
        child: Builder(builder: child),
      ),
    ),
  );

  Future<void> pumpHome(WidgetTester tester, Color? cover) => tester.pumpWidget(
    app(
      (context) => Center(
        child: SizedBox(
          width: 368,
          height: 390,
          child: GroupCardContent(
            group: group(),
            localizations: gen.AppLocalizations.of(context),
            theme: Theme.of(context),
            onExpenseAdded: () {},
            showAddButton: false,
            coverColor: cover,
          ),
        ),
      ),
    ),
  );

  bool hasFill(Color c) => find
      .byWidgetPredicate((w) => w is ColoredBox && w.color == c)
      .evaluate()
      .isNotEmpty;

  testWidgets('Home: tint, chip, mark, Total | Today, no chart', (
    tester,
  ) async {
    await pumpHome(tester, sky);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final look = GroupLook.of(sky, Brightness.light);
    expect(hasFill(look.tint), isTrue);
    expect(find.byType(TypeChip), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);
    expect(find.byType(TypeMark), findsOneWidget);
    expect(find.byType(FigureRow), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(SpendingWave), findsNothing);
    expect(tester.widget<Text>(find.text('Lisbon')).style?.color, look.onTint);
  });

  testWidgets('Home without a color: neutral grey', (tester) async {
    await pumpHome(tester, null);
    await tester.pumpAndSettle();
    expect(hasFill(GroupLook.of(null, Brightness.light).tint), isTrue);
    expect(find.byType(TypeMark), findsOneWidget);
  });

  testWidgets('group page: type icon on the favorite row, no chip; '
      'budget ring in the text color', (tester) async {
    final index = ExpenseGroupColorPalette.defaultIndexFor(
      ExpenseGroupType.travel,
    );
    final g = group(color: index, pinned: true).copyWith(
      budget: const GroupBudget(amount: 50, period: BudgetPeriod.daily),
    );
    await tester.pumpWidget(
      app(
        (context) => SingleChildScrollView(
          child: GroupHeaderBand(
            group: g,
            topInset: 24,
            header: (fg) => GroupDetailHeader(group: g, foreground: fg),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TypeChip), findsNothing);
    expect(find.byType(TypeMark), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('Travel'), findsOneWidget);
    expect(find.byType(FigureRow), findsOneWidget);
    final s = Theme.of(tester.element(find.text('Lisbon'))).colorScheme;
    final look = GroupLook.of(GroupLook.colorOf(g, s), s.brightness);
    expect(tester.widget<Text>(find.text('Lisbon')).style?.color, look.onTint);
    expect(
      tester.widget<BudgetRing>(find.byType(BudgetRing)).color,
      look.onTint,
    );
  });
}
