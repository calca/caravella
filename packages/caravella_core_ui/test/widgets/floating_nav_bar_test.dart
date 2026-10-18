import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _items = [
  FloatingNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Home',
  ),
  FloatingNavItem(
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder,
    label: 'Groups',
  ),
];

Widget _bar({
  int selected = 0,
  ValueChanged<int>? onSelected,
  FloatingNavAction? action,
}) => MaterialApp(
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: FloatingNavBar(
        items: _items,
        selectedIndex: selected,
        onSelected: onSelected ?? (_) {},
        action: action,
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the label of the selected destination only', (
    tester,
  ) async {
    await tester.pumpWidget(_bar(selected: 0));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Groups'), findsNothing);

    await tester.pumpWidget(_bar(selected: 1));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(find.text('Groups'), findsOneWidget);
  });

  testWidgets('tapping a destination reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(_bar(onSelected: (i) => tapped = i));
    await tester.tap(find.byIcon(Icons.folder_outlined));
    expect(tapped, 1);
  });

  testWidgets('screen readers get the label and selected state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_bar(selected: 1));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Groups')),
      containsSemantics(
        label: 'Groups',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Home'))
          .hasFlag(SemanticsFlag.isSelected),
      isFalse,
    );
    handle.dispose();
  });

  testWidgets('the action button runs its callback and has a label', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      _bar(
        action: FloatingNavAction(
          icon: Icons.add,
          label: 'New expense',
          onPressed: () => pressed++,
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.add));
    expect(pressed, 1);
    final handle = tester.ensureSemantics();
    await tester.pump();
    expect(
      tester.getSemantics(find.bySemanticsLabel('New expense')),
      containsSemantics(isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('no action, no round button', (tester) async {
    await tester.pumpWidget(_bar());
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
