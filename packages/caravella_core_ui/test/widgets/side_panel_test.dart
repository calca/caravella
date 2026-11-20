import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Sheets open from the bottom on phones and tablets in portrait, and as a
/// side panel on expanded windows, through the same showAppBottomSheet.
void main() {
  Future<void> open(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showAppBottomSheet<void>(
                  context: context,
                  builder: (_) => const CaravellaBottomSheetScaffold(
                    title: 'Sheet title',
                    child: Text('sheet body'),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('phone: a bottom sheet with its handle', (tester) async {
    await open(tester, 400);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(CloseButton), findsNothing);
  });

  testWidgets('medium windows keep the bottom sheet', (tester) async {
    await open(tester, 700);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('expanded: a full-height panel at the end, with a close button', (
    tester,
  ) async {
    await open(tester, 1280);
    expect(find.byType(BottomSheet), findsNothing);
    final panel = tester.getRect(
      find
          .ancestor(
            of: find.text('sheet body'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(panel.right, 1280);
    expect(panel.width, SidePanelScope.width);
    expect(panel.height, 800);
    expect(find.byType(CloseButton), findsOneWidget);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('sheet body'), findsNothing);
  });

  testWidgets('expanded: Esc and a tap outside close the panel', (
    tester,
  ) async {
    await open(tester, 1280);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('sheet body'), findsNothing);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(100, 400));
    await tester.pumpAndSettle();
    expect(find.text('sheet body'), findsNothing);
  });

  testWidgets('a FAB stays in the corner of the readable column', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: ReadableWidth.fabLocation(
            ReadableWidth.text,
          ),
        ),
      ),
    );
    // 720 column centered in 1280: it ends at 1000; the FAB keeps its
    // usual 16 margin inside it.
    expect(tester.getRect(find.byType(FloatingActionButton)).right, 1000 - 16);
  });
}
