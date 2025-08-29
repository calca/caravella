import 'package:flutter_test/flutter_test.dart';
import 'package:org_app_caravella/manager/group/group_form_controller.dart';
import 'package:org_app_caravella/manager/group/group_edit_mode.dart';
import 'package:org_app_caravella/manager/group/data/group_form_state.dart';
import 'package:org_app_caravella/data/model/expense_group.dart';
import 'package:org_app_caravella/data/model/expense_details.dart';
import 'package:org_app_caravella/data/model/expense_participant.dart';
import 'package:org_app_caravella/data/model/expense_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GroupFormController removal guard', () {
    test('blocks participant removal when assigned to expense', () async {
      final state = GroupFormState();
      final participant = ExpenseParticipant(name: 'Alice', id: 'p1');
      state.addParticipant(participant);
      final category = ExpenseCategory(name: 'Food', id: 'c1');
      state.addCategory(category);

      final expense = ExpenseDetails(
        amount: 10,
        paidBy: participant,
        category: category,
        date: DateTime.now(),
        name: 'Lunch',
      );
      final original = ExpenseGroup(
        id: 'g1',
        title: 'Trip',
        participants: [participant],
        categories: [category],
        expenses: [expense],
        currency: 'EUR',
      );

      final controller = GroupFormController(state, GroupEditMode.edit);
      controller.load(original);

      // Attempt to remove participant at index 0
      final removed = await controller.removeParticipantIfUnused(0);
      expect(removed, isFalse);
      expect(state.participants.length, 1);
    });

    test('allows participant removal when unused', () async {
      final state = GroupFormState();
      final participant = ExpenseParticipant(name: 'Bob', id: 'p2');
      state.addParticipant(participant);

      final controller = GroupFormController(state, GroupEditMode.create);
      controller.load(null); // no original

      final removed = await controller.removeParticipantIfUnused(0);
      expect(removed, isTrue);
      expect(state.participants.length, 0);
    });

    test('blocks category removal when assigned to expense', () async {
      final state = GroupFormState();
      final participant = ExpenseParticipant(name: 'Alice', id: 'p3');
      state.addParticipant(participant);
      final category = ExpenseCategory(name: 'Drinks', id: 'c2');
      state.addCategory(category);

      final expense = ExpenseDetails(
        amount: 5,
        paidBy: participant,
        category: category,
        date: DateTime.now(),
        name: 'Coffee',
      );
      final original = ExpenseGroup(
        id: 'g2',
        title: 'Trip2',
        participants: [participant],
        categories: [category],
        expenses: [expense],
        currency: 'EUR',
      );

      final controller = GroupFormController(state, GroupEditMode.edit);
      controller.load(original);

      final removed = await controller.removeCategoryIfUnused(0);
      expect(removed, isFalse);
      expect(state.categories.length, 1);
    });

    test('allows category removal when unused', () async {
      final state = GroupFormState();
      final category = ExpenseCategory(name: 'Misc', id: 'c3');
      state.addCategory(category);

      final controller = GroupFormController(state, GroupEditMode.create);
      controller.load(null);

      final removed = await controller.removeCategoryIfUnused(0);
      expect(removed, isTrue);
      expect(state.categories.length, 0);
    });
  });
}
