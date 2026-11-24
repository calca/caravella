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
      testWidgets('wide card: name, line, total; the type icon as the mark', (
        tester,
      ) async {
        await pump(
          tester,
          GroupCardFace(
            title: 'Lisbon',
            total: 0,
            currency: '€',
            icon: icon,
            color: sky,
            wide: true,
            meta: (fg) => const Text('Trip'),
          ),
        );
        expect(find.text('Lisbon'), findsOneWidget);
        expect(find.text('Trip'), findsOneWidget);
        expect(find.byType(CurrencyDisplay), findsOneWidget);
        expect(find.byType(TypeMark), findsOneWidget);
        // Only the big faint one: there is no chip.
        expect(find.byIcon(icon), findsOneWidget);
      });

      testWidgets('the line is in the card\'s text color, under the name', (
        tester,
      ) async {
        Color? given;
        await pump(
          tester,
          GroupCardFace(
            title: 'Lisbon',
            total: 0,
            currency: '€',
            icon: icon,
            color: sky,
            meta: (fg) {
              given = fg;
              return const Text('♥ 4 participants');
            },
          ),
          width: 180,
          height: GroupCardFace.tileHeight(TextScaler.noScaling),
        );
        expect(find.text('♥ 4 participants'), findsOneWidget);
        expect(given, GroupLook.of(sky, Brightness.light).onTint);
        expect(
          tester.getTopLeft(find.text('♥ 4 participants')).dy,
          greaterThan(tester.getBottomLeft(find.text('Lisbon')).dy),
        );
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
            meta: (fg) => const Text('Travel · 5/12/2030 - 5/18/2030'),
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
            meta: (fg) => const Text('♥ 12 people'),
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
