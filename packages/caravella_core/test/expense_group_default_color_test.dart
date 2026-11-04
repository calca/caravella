import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each kind of group has its own default palette color', () {
    final indices = [
      for (final type in ExpenseGroupType.values)
        ExpenseGroupColorPalette.defaultIndexFor(type),
    ];
    expect(indices.toSet(), hasLength(ExpenseGroupType.values.length));
    expect(
      indices.every((i) => i >= 0 && i < ExpenseGroupColorPalette.paletteSize),
      isTrue,
    );
    expect(
      ExpenseGroupColorPalette.defaultIndexFor(null),
      ExpenseGroupColorPalette.defaultIndexFor(ExpenseGroupType.other),
    );
  });
}
