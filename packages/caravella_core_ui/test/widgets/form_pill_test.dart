import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('tapping calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(FormPill(label: 'Food', onTap: () => taps++)));
    await tester.tap(find.text('Food'));
    expect(taps, 1);
  });

  testWidgets('exposes selected state and spoken label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(
        FormPill(
          label: 'Today',
          semanticsLabel: 'Date: Today',
          style: FormPillStyle.selected,
          onTap: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(FormPill)),
      isSemantics(
        label: 'Date: Today',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the selected pill is filled in the text color', (tester) async {
    await tester.pumpWidget(
      wrap(
        FormPill(label: 'Anna', style: FormPillStyle.selected, onTap: () {}),
      ),
    );
    final context = tester.element(find.byType(FormPill));
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(FormPill),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, Theme.of(context).colorScheme.onSurface);
  });

  testWidgets('the add pill draws a dashed border', (tester) async {
    await tester.pumpWidget(
      wrap(FormPill(label: 'Note', style: FormPillStyle.add, onTap: () {})),
    );
    expect(
      find.descendant(
        of: find.byType(FormPill),
        matching: find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              '${w.foregroundPainter.runtimeType}'.contains('Dashed'),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('without onTap it is disabled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const FormPill(label: 'Place')));
    expect(
      tester.getSemantics(find.byType(FormPill)),
      isSemantics(label: 'Place', isButton: false, hasTapAction: false),
    );
    handle.dispose();
  });

  testWidgets('meets the 48dp touch target', (tester) async {
    await tester.pumpWidget(wrap(FormPill(label: 'Food', onTap: () {})));
    expect(tester.getSize(find.byType(FormPill)).height, 48);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });

  testWidgets('a tap just outside the visual pill still counts', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(wrap(FormPill(label: 'Food', onTap: () => taps++)));
    final rect = tester.getRect(find.byType(FormPill));
    await tester.tapAt(Offset(rect.center.dx, rect.top + 1));
    expect(taps, 1);
  });
}
