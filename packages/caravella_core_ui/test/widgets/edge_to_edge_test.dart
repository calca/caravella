import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('edgeToEdge makes the navigation bar transparent, no scrim', (
    tester,
  ) async {
    late SystemUiOverlayStyle style;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            style = AppSystemUI.resolveStyle(
              context,
              navigationBarColor: Colors.transparent,
            );
            return AppSystemUI.edgeToEdge(child: const SizedBox());
          },
        ),
      ),
    );
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.systemNavigationBarContrastEnforced, isFalse);
    expect(find.byType(AppSystemUI), findsOneWidget);
  });

  testWidgets('status bar fade covers the status bar and fades below it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: 40)),
          child: const Align(
            alignment: Alignment.topCenter,
            child: StatusBarFade(color: Colors.white),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(StatusBarFade)).height, 64);
  });

  testWidgets('no status bar, no fade', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: StatusBarFade(color: Colors.white),
        ),
      ),
    );
    expect(tester.getSize(find.byType(StatusBarFade)).height, 0);
  });
}
