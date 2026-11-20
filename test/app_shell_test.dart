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

/// The floating bar is the phone layout: the default 800 dp test window
/// would already be a "medium" window, with the side navigation.
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('switches tabs and shows each tab\'s primary action', (
    tester,
  ) async {
    _phone(tester);
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
    _phone(tester);
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
    _phone(tester);
    await tester.pumpWidget(_app(hideNav: true));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingNavBar), findsNothing);
  });

  testWidgets('fade through keeps both tabs alive while switching', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.folder_copy_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    // Mid-animation: the old tab is fading out, the new one is on stage.
    expect(find.text('page home'), findsOneWidget);
    expect(find.text('page groups'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('page home'), findsNothing); // offstage, still alive
    expect(find.text('page home', skipOffstage: false), findsOneWidget);
    expect(find.text('page groups'), findsOneWidget);
  });

  testWidgets('switches instantly when animations are disabled', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.folder_copy_outlined));
    await tester.pump();
    expect(find.text('page home'), findsNothing);
    expect(find.text('page groups'), findsOneWidget);
  });

  group('wide windows', () {
    Future<void> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('phone width keeps the floating bar', (tester) async {
      await pumpAt(tester, 400);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(find.byType(FloatingNavBar), findsOneWidget);
      expect(find.byType(SideNav), findsNothing);
    });

    testWidgets('medium: a rail with both destinations and the action', (
      tester,
    ) async {
      var home = 0;
      await pumpAt(tester, 700);
      await tester.pumpWidget(_app(onHomeAction: () => home++));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingNavBar), findsNothing);
      final rail = tester.widget<SideNav>(find.byType(SideNav));
      expect(rail.extended, isFalse);
      // The rail shows every label, the floating bar only the selected one.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      expect(home, 1);
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<SideNav>(find.byType(SideNav)).selectedIndex,
        AppTab.groups.index,
      );
      expect(find.byIcon(Icons.create_new_folder_outlined), findsOneWidget);
      // The tab content sits beside the rail, not under it.
      expect(
        tester.getTopLeft(find.text('page groups')).dx,
        greaterThan(SideNav.railWidth),
      );
    });

    testWidgets('expanded: the side navigation shows labels and the '
        'action\'s label', (tester) async {
      await pumpAt(tester, 1280);
      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(tester.widget<SideNav>(find.byType(SideNav)).extended, isTrue);
      // At the top of the window, not centered beside the page.
      expect(tester.getTopLeft(find.byType(SideNav)).dy, 0);
      expect(find.text('home'), findsOneWidget); // the action, labelled
      expect(
        AppShellScope.navReserve(tester.element(find.text('page home'))),
        0,
      );
    });

    testWidgets('a tab can hide the side navigation too', (tester) async {
      await pumpAt(tester, 1280);
      await tester.pumpWidget(_app(hideNav: true));
      await tester.pumpAndSettle();
      expect(find.byType(SideNav), findsNothing);
    });
  });
}
