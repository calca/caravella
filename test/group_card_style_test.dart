import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_content.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// Home card and group page in both card styles (the A/B test): a color is
/// a cover in A and a tint in B, with the type chip and the big type icon;
/// no color is neutral grey; the figures are "Total | Today".
void main() {
  const sky = Color(0xFFAED6EE);

  ExpenseGroup group({int? color}) => ExpenseGroup(
    id: 'g1',
    title: 'Lisbon',
    expenses: [],
    participants: [ExpenseParticipant(id: '1', name: 'Anna')],
    categories: [ExpenseCategory(id: '1', name: 'Food')],
    currency: '€',
    timestamp: DateTime(2026, 12, 1),
    groupType: ExpenseGroupType.travel,
    color: color,
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

  Future<void> pumpHome(
    WidgetTester tester,
    GroupCardStyle style,
    Color? cover,
  ) => tester.pumpWidget(
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
            style: style,
          ),
        ),
      ),
    ),
  );

  bool hasFill(Color c) => find
      .byWidgetPredicate((w) => w is ColoredBox && w.color == c)
      .evaluate()
      .isNotEmpty;

  for (final style in GroupCardStyle.values) {
    testWidgets('Home ${style.name}: chip, mark, Total | Today', (
      tester,
    ) async {
      await pumpHome(tester, style, sky);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final look = GroupLook.of(sky, Brightness.light);
      expect(
        hasFill(style == GroupCardStyle.a ? look.cover : look.tint),
        isTrue,
      );
      expect(find.byType(TypeChip), findsOneWidget);
      expect(find.text('Travel'), findsOneWidget);
      expect(find.byType(TypeMark), findsOneWidget);
      expect(find.byType(FigureRow), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byType(SpendingWave), findsNothing);
    });

    testWidgets('Home ${style.name} without a color: neutral grey', (
      tester,
    ) async {
      await pumpHome(tester, style, null);
      await tester.pumpAndSettle();
      final look = GroupLook.of(null, Brightness.light);
      expect(
        hasFill(style == GroupCardStyle.a ? look.cover : look.tint),
        isTrue,
      );
      expect(find.byType(TypeMark), findsOneWidget);
    });

    testWidgets('group page ${style.name}: chip, mark and header', (
      tester,
    ) async {
      final index = ExpenseGroupColorPalette.defaultIndexFor(
        ExpenseGroupType.travel,
      );
      await tester.pumpWidget(
        app(
          (context) => SingleChildScrollView(
            child: GroupHeaderBand(
              group: group(color: index),
              topInset: 24,
              style: style,
              header: (fg) => GroupDetailHeader(
                group: group(color: index),
                foreground: fg,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TypeChip), findsOneWidget);
      expect(find.byType(TypeMark), findsOneWidget);
      expect(find.text('Lisbon'), findsOneWidget);
      expect(find.byType(FigureRow), findsOneWidget);
      final title = tester.widget<Text>(find.text('Lisbon'));
      final s = Theme.of(tester.element(find.text('Lisbon'))).colorScheme;
      final look = GroupLook.of(
        GroupLook.colorOf(group(color: index), s),
        s.brightness,
      );
      expect(
        title.style?.color,
        style == GroupCardStyle.a ? s.onSurface : look.onTint,
      );
    });
  }
}
