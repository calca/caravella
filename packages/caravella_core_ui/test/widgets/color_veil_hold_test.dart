import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Where the surface starts covering, as a stop (0 top, 1 bottom).
double _fadeStart(LinearGradient g) {
  for (var i = 0; i < g.colors.length; i++) {
    if (g.colors[i].a > 0) return g.stops![i - 1];
  }
  return 1;
}

void main() {
  const surface = Colors.white;
  LinearGradient fade({double hold = 0}) => PhotoVeil.fadeGradient(
    color: surface,
    height: 218,
    solidExtent: 84,
    fadeExtent: 110,
    hold: hold,
  );

  test('hold starts the fade lower and ends it at the same point', () {
    final photo = fade();
    final color = fade(hold: ColorVeil.hold);
    // Photo: the fade starts 84 + 110 px from the bottom.
    expect(_fadeStart(photo), closeTo((218 - 84 - 110) / 218, 1e-9));
    // Color: 45% of it is held, so it starts lower down.
    expect(
      _fadeStart(color),
      closeTo((218 - 84 - 110 * (1 - ColorVeil.hold)) / 218, 1e-9),
    );
    // Both are fully the surface from the same point (the text area).
    double solidFrom(LinearGradient g) =>
        g.stops![g.colors.indexWhere((c) => c.a == 1)];
    expect(solidFrom(color), closeTo(solidFrom(photo), 1e-9));
  });

  test('no hold is the photo fade', () {
    final a = fade();
    final b = PhotoVeil(
      path: 'x',
      color: surface,
      solidExtent: 84,
      fadeExtent: 110,
    ).gradientFor(218);
    expect(a.stops, b.stops);
    expect(a.colors, b.colors);
  });
}
