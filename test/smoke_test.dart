import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:org_app_caravella/main.dart';

void main() {
  testWidgets('App builds without crashing', (tester) async {
    await tester.pumpWidget(createAppForTest());
    // Pump a few frames to allow first build & async microtasks.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
