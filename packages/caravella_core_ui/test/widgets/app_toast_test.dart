import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zentoast/zentoast.dart';

Widget _app(void Function(BuildContext) onPressed) => ToastProvider.create(
  child: MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => onPressed(context),
                child: const Text('show'),
              ),
            ),
          ),
          const ToastViewer(
            alignment: Alignment.bottomCenter,
            delay: Duration(seconds: 10),
            visibleCount: 3,
          ),
        ],
      ),
    ),
  ),
);

void main() {
  testWidgets('a toast with an action runs it and hides', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      _app(
        (context) => AppToast.show(
          context,
          'Pixel 9 shared “Norway” with you',
          actionLabel: 'Open',
          onAction: () => opened++,
        ),
      ),
    );
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('without an action there is no button', (tester) async {
    await tester.pumpWidget(
      _app((context) => AppToast.show(context, 'Saved')),
    );
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget); // only "show"
  });
}
