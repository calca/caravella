import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group creation default categories initialization', () {
    test('initializes categories for default personal type in CREATE mode', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Verify default type is set
      expect(state.groupType, ExpenseGroupType.personal);
      expect(state.categories.isEmpty, isTrue);

      // Simulate calling initializeDefaultCategories with localized names
      final defaultCategories = [
        'Shopping',
        'Health',
        'Entertainment',
      ];

      controller.initializeDefaultCategories(defaultCategories);

      // Verify categories were added
      expect(state.categories.length, 3);
      expect(state.categories[0].name, 'Shopping');
      expect(state.categories[1].name, 'Health');
      expect(state.categories[2].name, 'Entertainment');
    });

    test('does not initialize categories in EDIT mode', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.edit);

      expect(state.groupType, ExpenseGroupType.personal);
      expect(state.categories.isEmpty, isTrue);

      final defaultCategories = ['Shopping', 'Health', 'Entertainment'];
      controller.initializeDefaultCategories(defaultCategories);

      // Verify categories were NOT added in EDIT mode
      expect(state.categories.isEmpty, isTrue);
    });

    test('does not reinitialize if categories already exist', () {
      final state = GroupFormState();
      final controller = GroupFormController(state, GroupEditMode.create);

      // Add an existing category first
      state.addCategory(ExpenseCategory(name: 'Existing'));

      final defaultCategories = ['Shopping', 'Health', 'Entertainment'];
      controller.initializeDefaultCategories(defaultCategories);

      // Verify only the existing category remains (no initialization)
      expect(state.categories.length, 1);
      expect(state.categories[0].name, 'Existing');
    });

    test('does not initialize if groupType is null', () {
      final state = GroupFormState();
      state.setGroupType(null); // Set groupType to null
      final controller = GroupFormController(state, GroupEditMode.create);

      expect(state.groupType, isNull);
      expect(state.categories.isEmpty, isTrue);

      final defaultCategories = ['Shopping', 'Health', 'Entertainment'];
      controller.initializeDefaultCategories(defaultCategories);

      // Verify categories were NOT added when groupType is null
      expect(state.categories.isEmpty, isTrue);
    });

    test('initializes travel type categories correctly', () {
      final state = GroupFormState();
      state.setGroupType(ExpenseGroupType.travel);
      final controller = GroupFormController(state, GroupEditMode.create);

      final travelCategories = [
        'Transport',
        'Accommodation',
        'Restaurants',
      ];

      controller.initializeDefaultCategories(travelCategories);

      expect(state.categories.length, 3);
      expect(state.categories[0].name, 'Transport');
      expect(state.categories[1].name, 'Accommodation');
      expect(state.categories[2].name, 'Restaurants');
    });

    test('initializes family type categories correctly', () {
      final state = GroupFormState();
      state.setGroupType(ExpenseGroupType.family);
      final controller = GroupFormController(state, GroupEditMode.create);

      final familyCategories = [
        'Groceries',
        'Home',
        'Bills',
      ];

      controller.initializeDefaultCategories(familyCategories);

      expect(state.categories.length, 3);
      expect(state.categories[0].name, 'Groceries');
      expect(state.categories[1].name, 'Home');
      expect(state.categories[2].name, 'Bills');
    });

    test('initializes other type categories correctly', () {
      final state = GroupFormState();
      state.setGroupType(ExpenseGroupType.other);
      final controller = GroupFormController(state, GroupEditMode.create);

      final otherCategories = [
        'Misc',
        'Utilities',
        'Services',
      ];

      controller.initializeDefaultCategories(otherCategories);

      expect(state.categories.length, 3);
      expect(state.categories[0].name, 'Misc');
      expect(state.categories[1].name, 'Utilities');
      expect(state.categories[2].name, 'Services');
    });
  });
}
