import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    GroupCardFace face, {
    double width = 320,
    double height = GroupCardFace.wideHeight,
    Brightness brightness = Brightness.light,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, height: height, child: face),
        ),
      ),
    ),
  );

  const icon = Icons.flight_takeoff;
  const sky = Color(0xFFAED6EE);

  {
    group('tile and wide card', () {
      testWidgets('wide card: name, line, total; type icon on chip and mark', (
        tester,
      ) async {
        await pump(
          tester,
          GroupCardFace(
            title: 'Lisbon',
            subtitle: 'Trip',
            total: 0,
            currency: '€',
            icon: icon,
            color: sky,
            wide: true,
          ),
        );
        expect(find.text('Lisbon'), findsOneWidget);
        expect(find.text('Trip'), findsOneWidget);
        expect(find.byType(CurrencyDisplay), findsOneWidget);
        expect(find.byType(TypeMark), findsOneWidget);
        expect(find.byIcon(icon), findsNWidgets(2));
        expect(find.byIcon(Icons.favorite_rounded), findsNothing);
      });

      testWidgets('the favorite has a heart on its chip', (tester) async {
        await pump(
          tester,
          GroupCardFace(
            title: 'Lisbon',
            total: 12.5,
            currency: '€',
            icon: icon,
            favorite: true,
            typeLabel: 'Travel',
          ),
          width: 170,
          height: 170,
        );
        expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
        expect(find.bySemanticsLabel('Travel'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a photo that is gone leaves the color and the mark', (
        tester,
      ) async {
        await pump(
          tester,
          GroupCardFace(
            title: 'Lisbon',
            total: 0,
            currency: '€',
            icon: icon,
            photoPath: '/nowhere/photo.jpg',
            color: sky,
          ),
          width: 170,
          height: 170,
        );
        expect(find.byType(PhotoBand), findsNothing);
        expect(find.byType(TypeMark), findsOneWidget);
      });

      testWidgets('the compact card fits its height', (tester) async {
        await pump(
          tester,
          GroupCardFace(
            title: 'A rather long name for a group of friends',
            subtitle: '5/12/2030 - 5/18/2030',
            total: 0,
            currency: '€',
            icon: icon,
            color: sky,
            wide: true,
            compact: true,
          ),
          height: GroupCardFace.compactHeight,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('a grid tile fits its height with large text', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pump(
          tester,
          GroupCardFace(
            title: 'A rather long name for a group of friends',
            subtitle: '12 people',
            total: 12345.67,
            currency: '€',
            icon: icon,
            color: sky,
          ),
          width: 170,
          height: GroupCardFace.tileHeight(const TextScaler.linear(1.6)),
        );
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets('the whole card in the tint, its own text color', (tester) async {
    await pump(
      tester,
      const GroupCardFace(
        title: 'Lisbon',
        total: 0,
        currency: '€',
        icon: icon,
        color: sky,
      ),
      width: 170,
      height: 170,
    );
    final look = GroupLook.of(sky, Brightness.light);
    expect(
      find.byWidgetPredicate((w) => w is ColoredBox && w.color == look.tint),
      findsOneWidget,
    );
    expect(tester.widget<Text>(find.text('Lisbon')).style?.color, look.onTint);
  });
}
