import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    GroupCardFace face, {
    double width = 320,
    double height = GroupCardFace.wideHeight,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: face),
        ),
      ),
    ),
  );

  const icon = Icons.flight_takeoff_outlined;

  testWidgets('wide card: name, line, total and icon on the color', (
    tester,
  ) async {
    await pump(
      tester,
      const GroupCardFace(
        title: 'Lisbon',
        subtitle: 'Trip',
        total: 0,
        currency: '€',
        icon: icon,
        color: Color(0xFFAED6EE),
        wide: true,
      ),
    );
    expect(find.text('Lisbon'), findsOneWidget);
    expect(find.text('Trip'), findsOneWidget);
    expect(find.byType(CurrencyDisplay), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);
  });

  testWidgets('the favorite row shows only with its label', (tester) async {
    await pump(
      tester,
      const GroupCardFace(
        title: 'Lisbon',
        total: 12.5,
        currency: '€',
        icon: icon,
        wide: true,
        favoriteLabel: 'Favorite',
      ),
    );
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });

  testWidgets('a photo that is gone leaves the color and the icon', (
    tester,
  ) async {
    await pump(
      tester,
      const GroupCardFace(
        title: 'Lisbon',
        total: 0,
        currency: '€',
        icon: icon,
        photoPath: '/nowhere/photo.jpg',
        color: Color(0xFFAED6EE),
      ),
    );
    expect(find.byType(PhotoVeil), findsNothing);
    expect(find.byIcon(icon), findsOneWidget);
  });

  testWidgets('the compact card fits its height', (tester) async {
    await pump(
      tester,
      const GroupCardFace(
        title: 'A rather long name for a group of friends',
        subtitle: '5/12/2030 - 5/18/2030',
        total: 0,
        currency: '€',
        icon: icon,
        color: Color(0xFFAED6EE),
        wide: true,
        compact: true,
      ),
      height: GroupCardFace.compactHeight,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a color melts into the surface like a photo: theme text, '
      'icon on the color', (tester) async {
    const tint = Color(0xFFAED6EE);
    await pump(
      tester,
      const GroupCardFace(
        title: 'Lisbon',
        total: 0,
        currency: '€',
        icon: icon,
        color: tint,
      ),
      width: 179,
      height: 218,
    );
    final veil = tester.widget<ColorVeil>(find.byType(ColorVeil));
    expect(veil.color, tint);
    expect(veil.solidExtent, PhotoVeilSpot.groupsCard.solidExtent);
    expect(veil.fadeExtent, PhotoVeilSpot.groupsCard.fadeExtent);

    final scheme = Theme.of(tester.element(find.text('Lisbon'))).colorScheme;
    expect(veil.surface, scheme.raisedSurface);
    expect(
      tester.widget<Text>(find.text('Lisbon')).style?.color,
      scheme.onSurface,
    );
    expect(
      tester.widget<Icon>(find.byIcon(icon)).color,
      ExpenseGroupColorPalette.getContrastingTextColor(tint),
    );
  });
}
