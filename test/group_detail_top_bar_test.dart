import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_detail_top_bar.dart';
import 'package:material_ui/material_ui.dart';

const _tint = Color(0xFF233B6E);
const _fg = Color(0xFFE8EEFA);

Future<void> _pump(
  WidgetTester tester, {
  required double fill,
  bool overPhoto = false,
}) => tester.pumpWidget(
  MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(
      body: GroupDetailTopBar(
        title: 'Norway',
        fill: fill,
        titleVisible: fill == 1,
        tint: _tint,
        foreground: _fg,
        overPhoto: overPhoto,
        onSearch: () {},
        menuItems: const [],
      ),
    ),
  ),
);

Color? _barColor(WidgetTester tester) => tester
    .widget<Container>(
      find
          .descendant(
            of: find.byType(GroupDetailTopBar),
            matching: find.byType(Container),
          )
          .first,
    )
    .color;

/// The round button's circle (the IconButton has a transparent Material of
/// its own inside it).
Color _buttonColor(WidgetTester tester, IconData icon) => tester
    .widgetList<Material>(
      find.ancestor(of: find.byIcon(icon), matching: find.byType(Material)),
    )
    .firstWhere((m) => m.shape is CircleBorder)
    .color!;

void main() {
  testWidgets('at rest: see-through bar, faint buttons in the band colors', (
    tester,
  ) async {
    await _pump(tester, fill: 0);
    expect(_barColor(tester)!.a, 0);
    // Not the white raised surface: the band's text color, faint.
    expect(
      _buttonColor(tester, Icons.arrow_back_rounded),
      _fg.withValues(alpha: 0.16),
    );
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.search_rounded),
          )
          .color,
      _fg,
    );
  });

  testWidgets('scrolled: the bar takes the band tint, buttons go flat', (
    tester,
  ) async {
    await _pump(tester, fill: 0.5);
    expect(_barColor(tester), _tint.withValues(alpha: 0.5));

    await _pump(tester, fill: 1);
    expect(_barColor(tester), _tint);
    expect(_buttonColor(tester, Icons.arrow_back_rounded).a, 0);
    final title = tester.widget<Text>(find.text('Norway'));
    expect(title.style?.color, _fg);
  });

  testWidgets('over a photo: a stronger veil of its tone', (tester) async {
    await _pump(tester, fill: 0, overPhoto: true);
    expect(
      _buttonColor(tester, Icons.arrow_back_rounded),
      _tint.withValues(alpha: 0.6),
    );
  });
}
