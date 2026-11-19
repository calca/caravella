import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/main/caravella_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zentoast/zentoast.dart';

/// Toasts used to keep the floating navigation's room on every page, so
/// away from Home and Groups they hung far above the bottom of the screen.
/// They now sit just above what the page on top keeps at the bottom.
void main() {
  const screenHeight = 2400 / 2.625;

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ToastProvider.create(
        child: MaterialApp(
          theme: CaravellaThemes.light,
          builder: (context, child) => AppFrame(child: child),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<Rect> showToast(WidgetTester tester, String message) async {
    AppToast.show(tester.element(find.byType(Scaffold).last), message);
    // The toast's motion runs on its own clock: let it slide in.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return tester.getRect(find.text(message));
  }

  Future<void> hideToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('a page with nothing at the bottom: near the bottom', (
    tester,
  ) async {
    await pumpApp(tester, const Scaffold(body: Text('page')));
    final toast = await showToast(tester, 'Saved');
    // The pill's text, not 88 dp of navigation room above the bottom.
    expect(screenHeight - toast.bottom, lessThan(60));
    await hideToasts(tester);
  });

  testWidgets('a "+" button: the toast clears it, and not on a page above', (
    tester,
  ) async {
    await pumpApp(
      tester,
      Scaffold(
        body: const Text('group'),
        floatingActionButton: AddFab(onPressed: () {}, tooltip: 'Add'),
      ),
    );
    final fab = tester.getRect(find.byType(AddFab));
    var toast = await showToast(tester, 'Expense deleted');
    expect(toast.bottom, lessThan(fab.top));
    await hideToasts(tester);

    // A page pushed over it has no "+": back near the bottom.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('settings')),
      ),
    );
    await tester.pumpAndSettle();
    toast = await showToast(tester, 'Copied');
    expect(screenHeight - toast.bottom, lessThan(60));
    await hideToasts(tester);

    // And above the "+" again once back.
    navigator.pop();
    await tester.pumpAndSettle();
    toast = await showToast(tester, 'Undone');
    expect(toast.bottom, lessThan(fab.top));
    await hideToasts(tester);
  });

  testWidgets('the floating navigation: above it', (tester) async {
    await pumpApp(
      tester,
      Scaffold(
        body: Stack(
          children: [
            const Text('home'),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingNavBar(
                selectedIndex: 0,
                onSelected: (_) {},
                items: const [
                  FloatingNavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: 'Home',
                  ),
                  FloatingNavItem(
                    icon: Icons.list,
                    selectedIcon: Icons.list,
                    label: 'Groups',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final bar = tester.getRect(find.byType(FloatingNavBar));
    final toast = await showToast(tester, 'Group archived');
    expect(toast.bottom, lessThan(bar.top));
    await hideToasts(tester);
  });
}
