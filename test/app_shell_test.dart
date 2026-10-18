import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/l10n/app_localization_delegates.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart';
import 'package:io_caravella_egm/main/app_shell.dart';
import 'package:material_ui/material_ui.dart';

/// Stand-in tab that registers a primary action like the real tabs do.
class _Tab extends StatelessWidget {
  final AppTab tab;
  final String text;
  final IconData actionIcon;
  final VoidCallback onAction;
  final bool hideNav;

  const _Tab(
    this.tab,
    this.text,
    this.actionIcon,
    this.onAction, {
    this.hideNav = false,
  });

  @override
  Widget build(BuildContext context) {
    final shell = AppShellScope.maybeOf(context);
    shell?.setPrimaryAction(
      tab,
      FloatingNavAction(icon: actionIcon, label: text, onPressed: onAction),
    );
    if (hideNav) shell?.setNavVisible(false);
    return Scaffold(body: Center(child: Text('page $text')));
  }
}

Widget _app({
  VoidCallback? onHomeAction,
  VoidCallback? onGroupsAction,
  bool hideNav = false,
}) => MaterialApp(
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: AppShell(
    home: _Tab(
      AppTab.home,
      'home',
      Icons.add,
      onHomeAction ?? () {},
      hideNav: hideNav,
    ),
    groups: _Tab(
      AppTab.groups,
      'groups',
      Icons.create_new_folder_outlined,
      onGroupsAction ?? () {},
    ),
  ),
);

void main() {
  testWidgets('switches tabs and shows each tab\'s primary action', (
    tester,
  ) async {
    var home = 0, groups = 0;
    await tester.pumpWidget(
      _app(onHomeAction: () => home++, onGroupsAction: () => groups++),
    );
    await tester.pumpAndSettle();

    expect(find.text('page home'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    expect(home, 1);

    await tester.tap(find.byIcon(Icons.folder_copy_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget); // selected label
    await tester.tap(find.byIcon(Icons.create_new_folder_outlined));
    expect(groups, 1);
  });

  testWidgets('back on Groups returns to Home', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.folder_copy_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Groups'), findsNothing);
  });

  testWidgets('a tab can hide the bar', (tester) async {
    await tester.pumpWidget(_app(hideNav: true));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsNothing);
  });
}
