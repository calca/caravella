import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core_ui/widgets/chip_selector_row.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('shows all items as chips when five or fewer', (tester) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E'],
          selected: 'A',
          itemLabel: (v) => v,
          onSelected: (_) {},
          moreLabel: 'More',
        ),
      ),
    );

    for (final label in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.widgetWithText(FilterChip, label), findsOneWidget);
    }
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });

  testWidgets('collapses items beyond the 4th into a "more" chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E', 'F'],
          selected: 'A',
          itemLabel: (v) => v,
          onSelected: (_) {},
          moreLabel: 'More',
        ),
      ),
    );

    for (final label in ['A', 'B', 'C', 'D']) {
      expect(find.widgetWithText(FilterChip, label), findsOneWidget);
    }
    expect(find.widgetWithText(FilterChip, 'E'), findsNothing);
    expect(find.widgetWithText(FilterChip, 'F'), findsNothing);
    expect(find.text('+2'), findsNothing);
    expect(find.widgetWithText(FilterChip, 'More'), findsOneWidget);
  });

  testWidgets('shows the hidden selection label on the "more" chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ChipSelectorRow<String>(
          items: const ['A', 'B', 'C', 'D', 'E', 'F'],
          selected: 'F',
          itemLabel: (v) => v,
          onSelected: (_) {},
          moreLabel: 'More',
        ),
      ),
    );

    expect(find.text('+2'), findsNothing);
    expect(find.widgetWithText(FilterChip, 'More'), findsNothing);
    expect(find.widgetWithText(FilterChip, 'F'), findsOneWidget);
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
          moreLabel: 'More',
          onAddItemInline: (_) async {},
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
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
          moreLabel: 'More',
        ),
      ),
    );

    expect(find.byType(FilterChip), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
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
              moreLabel: 'More',
            );
          },
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'B'));
    await tester.pumpAndSettle();

    expect(selected, 'B');
  });
}
