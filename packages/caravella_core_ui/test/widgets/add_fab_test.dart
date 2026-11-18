import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The "+" is one node for TalkBack, labeled and tappable: a labeled node
/// around the button's own node was a "button" TalkBack couldn't activate.
void main() {
  testWidgets('one labeled node that can be activated', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AddFab(tooltip: 'New expense', onPressed: () => taps++),
          ),
        ),
      ),
    );
    final nodes = find.semantics.byLabel('New expense');
    expect(nodes, findsOne);
    final node = nodes.evaluate().single;
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(nodes);
    expect(taps, 1);
    handle.dispose();
  });
}
