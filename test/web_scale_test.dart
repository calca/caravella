import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/main/caravella_app.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('the web scale grows with the window, from 1600 up to 1.3', () {
    expect(WebScale.factorFor(1280), 1);
    expect(WebScale.factorFor(1600), 1);
    expect(WebScale.factorFor(2000), 1.25);
    expect(WebScale.factorFor(3000), 1.3);
  });

  Future<Size> sizeSeen(WidgetTester tester, {required bool enabled}) async {
    tester.view.physicalSize = const Size(2080, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late Size seen;
    await tester.pumpWidget(
      MaterialApp(
        home: WebScale(
          enabled: enabled,
          child: Builder(
            builder: (context) {
              seen = MediaQuery.sizeOf(context);
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    return seen;
  }

  testWidgets('on a large web window the app lays out smaller and is '
      'drawn scaled up to fill it', (tester) async {
    expect(await sizeSeen(tester, enabled: true), const Size(1600, 1000));
  });

  testWidgets('off the web nothing changes', (tester) async {
    expect(await sizeSeen(tester, enabled: false), const Size(2080, 1300));
  });
}
