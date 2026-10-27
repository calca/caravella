import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/expense/coordination/route_settled.dart';
import 'package:material_ui/material_ui.dart';

class _Probe extends StatefulWidget {
  final VoidCallback onSettled;
  const _Probe({required this.onSettled});

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    routeSettled(context).then((_) {
      if (mounted) widget.onSettled();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

void main() {
  testWidgets('waits for the sheet to finish sliding in', (tester) async {
    var settled = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              sheetAnimationStyle: const AnimationStyle(
                duration: Duration(milliseconds: 300),
              ),
              builder: (_) => _Probe(onSettled: () => settled = true),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(settled, isFalse, reason: 'still sliding in');

    await tester.pumpAndSettle();
    expect(settled, isTrue);
  });

  testWidgets('completes right away without a route animation', (
    tester,
  ) async {
    var settled = false;
    await tester.pumpWidget(
      MaterialApp(home: _Probe(onSettled: () => settled = true)),
    );
    await tester.pump();
    expect(settled, isTrue);
  });
}
