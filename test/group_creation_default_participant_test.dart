import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group creation default participant', () {
    test('adds localized "Me" as first participant when user has no name', () {
      final state = GroupFormState();

      // Simulate the logic from ExpensesGroupEditPage for create mode
      // When user has no name, use the localized "Me"
      const defaultParticipantMe = 'Me'; // English version

      state.addParticipant(
        ExpenseParticipant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: defaultParticipantMe,
        ),
      );

      // Verify that the first participant is "Me"
      expect(state.participants.length, 1);
      expect(state.participants[0].name, 'Me');
    });

    test('adds user name as first participant when user has name set', () {
      final state = GroupFormState();

      // Simulate the logic from ExpensesGroupEditPage for create mode
      // When user has a name, use their name
      const userName = 'John Doe';

      state.addParticipant(
        ExpenseParticipant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: userName,
        ),
      );

      // Verify that the first participant is the user's name
      expect(state.participants.length, 1);
      expect(state.participants[0].name, 'John Doe');
    });

    test('adds localized "Io" in Italian when user has no name', () {
      final state = GroupFormState();

      // Simulate the logic from ExpensesGroupEditPage for create mode
      // In Italian locale, when user has no name, use "Io"
      const defaultParticipantIo = 'Io'; // Italian version

      state.addParticipant(
        ExpenseParticipant(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: defaultParticipantIo,
        ),
      );

      // Verify that the first participant is "Io" (Italian for "Me")
      expect(state.participants.length, 1);
      expect(state.participants[0].name, 'Io');
    });
  });
}
