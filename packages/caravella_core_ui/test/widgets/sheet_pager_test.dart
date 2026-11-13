import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, Widget content) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                builder: (_) => SheetPager(child: content),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('a second screen opens inside the same sheet, the first keeps '
      'its state, and the result comes back', (tester) async {
    String? picked;
    await openSheet(
      tester,
      Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(key: Key('rate')),
            TextButton(
              onPressed: () async {
                picked = await showSheetPage<String>(
                  context,
                  title: 'Currency',
                  builder: (context) => TextButton(
                    onPressed: () => closeSheetPage(context, 'GBP'),
                    child: const Text('GBP'),
                  ),
                );
              },
              child: const Text('pick'),
            ),
          ],
        ),
      ),
    );
    await tester.enterText(find.byKey(const Key('rate')), '11.63');
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.byKey(const Key('rate')), findsNothing);

    await tester.tap(find.text('GBP'));
    await tester.pumpAndSettle();
    expect(picked, 'GBP');
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('11.63'), findsOneWidget);
  });

  testWidgets('back closes the second screen, not the sheet', (tester) async {
    await openSheet(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showSheetPage<void>(
            context,
            title: 'Color',
            builder: (_) => const Text('palette'),
          ),
          child: const Text('color'),
        ),
      ),
    );
    await tester.tap(find.text('color'));
    await tester.pumpAndSettle();
    expect(find.text('palette'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('palette'), findsNothing);
    expect(find.text('color'), findsOneWidget);

    // With no second screen open, back closes the sheet.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('outside a sheet, the page opens as a sheet of its own', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSheetPage<void>(
                context,
                title: 'Budget',
                builder: (_) => const Text('settings'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('settings'), findsOneWidget);
  });
}
