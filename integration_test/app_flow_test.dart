import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:io_caravella_egm/main.dart' as app;
import 'package:material_ui/material_ui.dart';

/// The main flows of the real app on a device, from a fresh install: the
/// welcome screen, a new group with two people, an expense added from Home,
/// the balances and Settle up, then the expense changed and deleted.
///
/// Runs on an emulator in the pre-release workflow (each rc), not in every
/// PR's CI. Locally, on a running emulator or phone, with the dev flavor
/// (its data is wiped first, so use a device you test on):
///
///     adb shell pm clear io.caravella.egm.dev
///     flutter test integration_test --flavor dev --dart-define=FLAVOR=dev
///
/// The texts are the English ones: the device must be in English.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a trip from the first start to settling up', (tester) async {
    // The app installs its own error handlers, which would swallow a failed
    // expectation and leave the test hanging: give the test its own back.
    final onError = FlutterError.onError;
    app.main();
    await _settle(tester, 40);
    FlutterError.onError = onError;

    // Welcome → the group wizard: your name, the kind, its name, people.
    await _tap(tester, find.bySemanticsLabel('Get started'));
    expect(find.text('What’s your name?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Anna');
    await _tap(tester, find.text('Continue'));

    expect(find.text('What kind of group?'), findsOneWidget);
    await _tap(tester, find.text('Travel'));
    await _tap(tester, find.text('Continue'));

    expect(find.text('What shall we call it?'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Norway');
    await _settle(tester);
    await _tap(tester, find.text('Continue'));

    expect(find.text('Who’s participating?'), findsOneWidget);
    expect(find.text('Anna (you)'), findsOneWidget);
    await _tap(tester, find.text('Add participant'));
    await tester.enterText(find.byType(TextField), 'Bruno');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _settle(tester);
    await _tap(tester, find.text('Create group'), frames: 20);

    // Home shows the new group, with nothing spent yet.
    expect(find.text('Norway'), findsWidgets);
    expect(_amountAfter('Total'), '0.00');

    // An expense from Home's + : the quick sheet.
    await _tap(tester, find.bySemanticsLabel('New expense in Norway'));
    await tester.enterText(find.byType(TextField).at(0), '60');
    await tester.enterText(find.byType(TextField).at(1), 'Dinner');
    await _settle(tester);
    await _tap(tester, find.text('Add expense'), frames: 20);

    expect(_amountAfter('Total'), '60.00');
    expect(find.text('Dinner'), findsWidgets);

    // The group page: the expense, then the balances.
    await _tap(tester, find.text('Norway').first, frames: 20);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Dinner'), findsOneWidget);
    await _tap(tester, find.text('Balances'), frames: 20);
    expect(find.bySemanticsLabel(RegExp(r'^Anna gets back 30\.00')), findsOne);
    expect(find.bySemanticsLabel(RegExp(r'^Bruno owes 30\.00')), findsOne);
    expect(
      find.bySemanticsLabel(RegExp(r'^Bruno pays Anna 30\.00')),
      findsOneWidget,
    );

    // Change the amount: the balances follow.
    await _tap(tester, find.text('Expenses'));
    await _tap(tester, find.text('Dinner').first, frames: 16);
    expect(find.text('Edit expense'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '80');
    await _settle(tester);
    await _tap(tester, find.text('Save'), frames: 20);
    await _tap(tester, find.text('Balances'), frames: 20);
    expect(
      find.bySemanticsLabel(RegExp(r'^Bruno pays Anna 40\.00')),
      findsOneWidget,
    );

    // Delete it: nothing left to settle, the total back to zero.
    await _tap(tester, find.text('Expenses'));
    await _tap(tester, find.text('Dinner').first, frames: 16);
    await _tap(tester, find.byTooltip('Delete expense'));
    await _tap(tester, find.text('Delete').last, frames: 20);
    expect(find.text('Dinner'), findsNothing);
    expect(_amountAfter('Total'), '0.00');
  });
}

/// Pumps [frames] frames of 250 ms: the app animates and loads from the
/// database, so `pumpAndSettle` can't tell when it is done.
Future<void> _settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _tap(WidgetTester tester, Finder finder, {int frames = 8}) async {
  expect(finder, findsWidgets, reason: 'nothing to tap: $finder');
  await tester.tap(finder.first);
  await _settle(tester, frames);
}

/// The number shown right after the [label] text (e.g. "Total" → "60.00").
String? _amountAfter(String label) {
  final texts = find.byType(Text).evaluate().map((e) {
    final text = e.widget as Text;
    return text.data ?? text.textSpan?.toPlainText();
  }).toList();
  final i = texts.indexOf(label);
  return i < 0 || i + 1 >= texts.length ? null : texts[i + 1];
}
