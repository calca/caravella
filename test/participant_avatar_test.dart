import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/details/widgets/group_header.dart';
import 'package:io_caravella_egm/data/model/expense_participant.dart';

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

    // Find the avatar container
    final containerFinder = find.byType(Container);
    expect(containerFinder, findsOneWidget);

    // Check that the initials are displayed
    final textFinder = find.text('JD');
    expect(textFinder, findsOneWidget);

    // Check container properties
    final container = tester.widget<Container>(containerFinder);
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
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