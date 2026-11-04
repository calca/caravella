import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/manager/group/data/group_form_state.dart';
import 'package:io_caravella_egm/manager/group/group_edit_mode.dart';
import 'package:io_caravella_egm/manager/group/group_form_controller.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  late final String _tempDir = Directory.systemTemp
      .createTempSync('group_default_color_test')
      .path;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
}

GroupFormState _form(ExpenseGroupType? type) {
  final state = GroupFormState()
    ..setTitle('Lisbon')
    ..setGroupType(type);
  state.addParticipant(ExpenseParticipant(name: 'Anna'));
  state.addCategory(ExpenseCategory(name: 'Food'));
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = _FakePathProvider();

  setUpAll(() {
    ExpenseGroupRepositoryFactory.reset();
    ExpenseGroupRepositoryFactory.getRepository(useJsonBackend: true);
  });
  setUp(ExpenseGroupStorageV2.clearCache);

  test('a new group with no background gets its type\'s color', () async {
    for (final type in [...ExpenseGroupType.values, null]) {
      final state = _form(type);
      final controller = GroupFormController(state, GroupEditMode.create);
      expect(controller.hasChanges, isTrue); // the title, not the color
      expect(state.color, isNull);
      final group = await controller.save();
      expect(group.color, ExpenseGroupColorPalette.defaultIndexFor(type));
    }
  });

  test('a color or a photo chosen wins over the default', () async {
    final colored = _form(ExpenseGroupType.travel)..setColor(1);
    expect(
      (await GroupFormController(colored, GroupEditMode.create).save()).color,
      1,
    );

    final photo = _form(ExpenseGroupType.travel)..setImage('/tmp/photo.jpg');
    final group = await GroupFormController(photo, GroupEditMode.create).save();
    expect(group.color, isNull);
    expect(group.file, '/tmp/photo.jpg');
  });

  test('editing a group with no background leaves it without one', () async {
    final original = ExpenseGroup(
      title: 'Rome',
      participants: [ExpenseParticipant(name: 'Anna')],
      categories: [ExpenseCategory(name: 'Food')],
      expenses: [],
      currency: 'EUR',
    );
    await ExpenseGroupStorageV2.addExpenseGroup(original);
    final state = GroupFormState();
    final controller = GroupFormController(state, GroupEditMode.edit)
      ..load(original);
    state.setTitle('Rome 2');
    expect((await controller.save()).color, isNull);
  });
}
