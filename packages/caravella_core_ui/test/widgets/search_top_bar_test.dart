import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// On a narrow phone (a Galaxy S25: 384 dp) the search hint ran up to the
/// pill's rounded end: the field had no padding at the end.
void main() {
  testWidgets('the hint stays clear of the pill\'s rounded end', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384 * 2.8125, 300 * 2.8125);
    tester.view.devicePixelRatio = 2.8125;
    addTearDown(tester.view.reset);
    const hint = 'Search groups and expenses…';
    await tester.pumpWidget(
      MaterialApp(
        theme: CaravellaThemes.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTopBar(
              controller: TextEditingController(),
              hintText: hint,
              onChanged: (_) {},
              onFilters: () {},
              filtersTooltip: 'Filters',
              clearTooltip: 'Clear',
            ),
          ),
        ),
      ),
    );
    final pill = tester.getRect(
      find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final text = tester.getRect(find.text(hint));
    expect(text.right, lessThanOrEqualTo(pill.right - 12));
  });
}
