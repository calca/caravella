import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late MapTileStatus status;

  Widget app() => MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLoadingOverlay(status: status, message: 'Loading'),
          ),
          MapUnavailableCard(
            status: status,
            title: 'No map',
            message: 'Check',
            retryLabel: 'Retry',
          ),
        ],
      ),
    ),
  );

  // In the test's body, for its timer to run on the test's fake clock.
  void start() {
    status = MapTileStatus(slowAfter: const Duration(seconds: 1));
    addTearDown(status.dispose);
  }

  testWidgets('says it is loading only when it takes a while', (tester) async {
    start();
    await tester.pumpWidget(app());
    expect(find.text('Loading'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(status.state, MapTileState.slow);
    expect(find.text('Loading'), findsOneWidget);

    status.tileLoaded();
    await tester.pump();
    await tester.pump();
    expect(status.state, MapTileState.ready);
    expect(find.text('Loading'), findsNothing);
  });

  testWidgets('with no tiles the card offers to try again', (tester) async {
    start();
    await tester.pumpWidget(app());
    final resets = <void>[];
    final sub = status.reset.listen(resets.add);
    addTearDown(sub.cancel);

    status.tileFailed();
    await tester.pump();
    expect(find.text('No map'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(resets, hasLength(1));
    expect(status.state, MapTileState.waiting);
    expect(find.text('No map'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a failure next to tiles that loaded is ignored', (tester) async {
    start();
    await tester.pumpWidget(app());

    status.tileLoaded();
    await tester.pump();
    await tester.pump();
    status.tileFailed();
    await tester.pump();

    expect(status.state, MapTileState.ready);
    expect(find.text('No map'), findsNothing);
  });
}
