import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<Rect> boxAt(WidgetTester tester, double width, double max) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReadableWidth(
          maxWidth: max,
          child: ListView(children: const [SizedBox(height: 10)]),
        ),
      ),
    );
    return tester.getRect(find.byType(ListView));
  }

  testWidgets('a phone keeps the full width', (tester) async {
    expect(
      await boxAt(tester, 400, ReadableWidth.text),
      const Rect.fromLTWH(0, 0, 400, 800),
    );
  });

  testWidgets('a wide window centers the content at maxWidth, full height', (
    tester,
  ) async {
    expect(
      await boxAt(tester, 1280, ReadableWidth.text),
      const Rect.fromLTWH(280, 0, 720, 800),
    );
  });

  test('WindowSize switches at 600 and 840 dp', () {
    expect(WindowSize.forWidth(599), WindowSize.compact);
    expect(WindowSize.forWidth(600), WindowSize.medium);
    expect(WindowSize.forWidth(839), WindowSize.medium);
    expect(WindowSize.forWidth(840), WindowSize.expanded);
  });
}
