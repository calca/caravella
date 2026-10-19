import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('shows all items as chips when five or fewer', (tester) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E'],
          selected: 'A',
          itemLabel: (v) => v,
          onSelected: (_) {},
        ),
      ),
    );

    for (final label in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.widgetWithText(FormPill, label), findsOneWidget);
    }
    expect(find.widgetWithText(FormPill, '...'), findsNothing);
  });

  testWidgets('collapses items beyond the 4th into a "..." chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E', 'F'],
          selected: 'A',
          itemLabel: (v) => v,
          onSelected: (_) {},
        ),
      ),
    );

    for (final label in ['A', 'B', 'C', 'D']) {
      expect(find.widgetWithText(FormPill, label), findsOneWidget);
    }
    expect(find.widgetWithText(FormPill, 'E'), findsNothing);
    expect(find.widgetWithText(FormPill, 'F'), findsNothing);
    expect(find.text('+2'), findsNothing);
    expect(find.widgetWithText(FormPill, '...'), findsOneWidget);
  });

  testWidgets('shows the hidden selection label on the "..." chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E', 'F'],
          selected: 'F',
          itemLabel: (v) => v,
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.text('+2'), findsNothing);
    expect(find.widgetWithText(FormPill, '...'), findsNothing);
    expect(find.widgetWithText(FormPill, 'F'), findsOneWidget);
  });

  testWidgets('renders an add chip when onAddItemInline is provided', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B'],
          selected: 'A',
          itemLabel: (v) => v,
          onSelected: (_) {},
          onAddItemInline: (_) async {},
        ),
      ),
    );

    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });

  testWidgets('renders nothing when there are no items and no add action', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const [],
          selected: null,
          itemLabel: (v) => v,
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.byType(FormPill), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsNothing);
  });

  testWidgets('tapping a chip selects it', (tester) async {
    String? selected;
    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return ChipSelectorRow<String>(
              items: const ['A', 'B', 'C'],
              selected: selected,
              itemLabel: (v) => v,
              onSelected: (v) => setState(() => selected = v),
            );
          },
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FormPill, 'B'));
    await tester.pumpAndSettle();

    expect(selected, 'B');
  });
}
