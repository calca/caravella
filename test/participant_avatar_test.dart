import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_header.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  testWidgets('ParticipantAvatar displays participant initials', (tester) async {
    final participant = ExpenseParticipant(
      name: 'John Doe',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParticipantAvatar(
            participant: participant,
            size: 32,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the CircleAvatar widget
    final avatarFinder = find.byType(CircleAvatar);
    expect(avatarFinder, findsOneWidget);

    // Check that the initials are displayed
    final textFinder = find.text('JD');
    expect(textFinder, findsOneWidget);

    // Check CircleAvatar properties
    final avatar = tester.widget<CircleAvatar>(avatarFinder);
    expect(avatar.radius, 16.0); // size / 2 = 32 / 2 = 16
  });

  testWidgets('ParticipantAvatar handles single character names', (tester) async {
    final participant = ExpenseParticipant(
      name: 'A',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParticipantAvatar(
            participant: participant,
            size: 32,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Check that single character is displayed
    final textFinder = find.text('A');
    expect(textFinder, findsOneWidget);
  });
}