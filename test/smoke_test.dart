import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/main.dart';

void main() {
  testWidgets('App builds without crashing', (tester) async {
    await tester.pumpWidget(createAppForTest());
    // Pump a few frames to allow first build & async microtasks.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // Let post-frame delayed checks (like the weekly update check) run.
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
