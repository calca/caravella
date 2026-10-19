import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/history/expenses_history_page.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';

Widget _app() => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => ExpenseGroupNotifier())],
    child: const ExpesensHistoryPage(),
  ),
);

/// Groups page: title, search, Active/Archived switch, empty states.
/// (It replaced the TabBar/TabBarView layout covered by the old
/// history_tab_scrolling_test.dart.)
void main() {
  testWidgets('shows the title, the search button and the status switch', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Groups'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.textContaining('Active ·'), findsOneWidget);
    expect(find.textContaining('Archived ·'), findsOneWidget);
    // No tab bar any more.
    expect(find.byType(TabBar), findsNothing);
  });

  testWidgets('the switch shows archived groups and back', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.textContaining('Archived ·'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No archived groups'), findsOneWidget);

    await tester.tap(find.textContaining('Active ·'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No archived groups'), findsNothing);
  });

  testWidgets('the switch exposes the selected state to screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));

    final active = find.bySemanticsLabel(RegExp(r'^Active ·'));
    expect(
      tester.getSemantics(active),
      isSemantics(isButton: true, isSelected: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('outside the app shell it keeps a back button and its FAB', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(RoundBackButton), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
