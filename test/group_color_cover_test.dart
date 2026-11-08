import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_content.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:io_caravella_egm/manager/details/widgets/group_detail_header.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// A group color takes the photo's place on Home and on the group page: it
/// melts into the surface with the same extents as a photo (ColorVeil).
void main() {
  const tint = Color(0xFFAED6EE);

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

  Future<void> pumpHome(WidgetTester tester, Color? cover) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        gen.AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => ExpenseGroupNotifier(),
          child: Builder(
            builder: (context) => SizedBox(
              width: 360,
              height: 420,
              child: GroupCardContent(
                group: group(),
                localizations: gen.AppLocalizations.of(context),
                theme: Theme.of(context),
                onExpenseAdded: () {},
                coverColor: cover,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('Home card: the color is a cover with the type icon', (
    tester,
  ) async {
    await pumpHome(tester, tint);
    await tester.pumpAndSettle();
    final veil = tester.widget<ColorVeil>(find.byType(ColorVeil));
    expect(veil.color, tint);
    expect(veil.solidExtent, PhotoVeilSpot.home.solidExtent);
    expect(veil.fadeExtent, PhotoVeilSpot.home.fadeExtent);
    expect(find.byIcon(ExpenseGroupType.travel.icon), findsOneWidget);
  });

  testWidgets('Home card without a color: no cover', (tester) async {
    await pumpHome(tester, null);
    await tester.pumpAndSettle();
    expect(find.byType(ColorVeil), findsNothing);
    expect(find.byIcon(ExpenseGroupType.travel.icon), findsNothing);
  });

  testWidgets('group page: the color melts into the page like a photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final s = Theme.of(context).colorScheme;
            final index = ExpenseGroupColorPalette.defaultIndexFor(
              ExpenseGroupType.travel,
            );
            return GroupHeaderBand(
              group: group(color: index),
              pageColor: s.surface,
            );
          },
        ),
      ),
    );
    final veil = tester.widget<ColorVeil>(find.byType(ColorVeil));
    expect(veil.solidExtent, PhotoVeilSpot.groupPage.solidExtent);
    expect(veil.fadeExtent, PhotoVeilSpot.groupPage.fadeExtent);
  });
}
