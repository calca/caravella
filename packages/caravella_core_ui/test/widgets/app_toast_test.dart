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
          // As in the app: no viewer delay, each toast hides itself.
          const ToastViewer(
            alignment: Alignment.bottomCenter,
            delay: null,
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
    await tester.pumpWidget(_app((context) => AppToast.show(context, 'Saved')));
    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget); // only "show"
  });

  testWidgets('info goes after 3 s, an error stays 5 s', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      _app((context) {
        ctx = context;
        AppToast.show(context, 'Saved');
        AppToast.show(context, 'Couldn’t save', type: ToastType.error);
      }),
    );
    await tester.tap(find.text('show'));
    // zentoast keeps hidden toasts (faded out) until all are gone: what
    // it hides is in willDeleteToastIndex (0: info, 1: error).
    Set<int> hidden() => ToastProvider.of(ctx).willDeleteToastIndex.toSet();
    await tester.pump(); // shown

    await tester.pump(const Duration(milliseconds: 2900));
    expect(hidden(), isEmpty);
    await tester.pump(const Duration(milliseconds: 200));
    expect(hidden(), {0});
    await tester.pump(const Duration(milliseconds: 1800));
    expect(hidden(), {0});
    await tester.pump(const Duration(milliseconds: 200));
    expect(hidden(), {0, 1});
    await tester.pumpAndSettle();
    expect(find.text('Couldn’t save'), findsNothing);
  });

  testWidgets('an error is on the error container color', (tester) async {
    await tester.pumpWidget(
      _app(
        (context) =>
            AppToast.show(context, 'Couldn’t save', type: ToastType.error),
      ),
    );
    await tester.tap(find.text('show'));
    await tester.pump(const Duration(milliseconds: 500));
    final scheme = Theme.of(tester.element(find.text('show'))).colorScheme;
    final pill = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Couldn’t save'),
            matching: find.byType(Container),
          )
          .last,
    );
    expect((pill.decoration! as BoxDecoration).color, scheme.errorContainer);
  });

  testWidgets('with TalkBack a toast with an action waits to be used', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      _app(
        (context) => AppToast.show(
          context,
          '“Norway” archived',
          actionLabel: 'Undo',
          onAction: () {},
        ),
      ),
    );
    await tester.tap(find.text('show'));
    await tester.pump(const Duration(seconds: 20));
    expect(find.text('Undo'), findsOneWidget);
  });
}
