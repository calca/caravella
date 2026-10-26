import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/sync/group_sync_badge.dart';
import 'package:material_ui/material_ui.dart';

final _group = ExpenseGroup(
  title: 'Norway',
  expenses: const [],
  participants: const [],
  categories: const [],
  currency: '€',
  syncEnabled: true,
);

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('on the group page the Shared badge opens sync', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      _wrap(
        GroupSyncBadge(
          group: _group,
          background: Colors.black12,
          foreground: Colors.black,
          onTap: () => opened++,
        ),
      ),
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    await tester.tap(find.text('Shared'));
    expect(opened, 1);
    // Touch target of at least 48 dp, though the pill itself is small.
    expect(tester.getSize(find.byType(GroupSyncBadge)).height, 48);
    final top = tester.getRect(find.byType(GroupSyncBadge)).topCenter;
    await tester.tapAt(top + const Offset(0, 2));
    expect(opened, 2);
  });

  testWidgets('without onTap it is a plain label (Home card)', (tester) async {
    await tester.pumpWidget(
      _wrap(
        GroupSyncBadge(
          group: _group,
          background: Colors.black12,
          foreground: Colors.black,
        ),
      ),
    );
    expect(find.text('Shared'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });
}
