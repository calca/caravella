import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GroupTypeTemplateService', () {
    late GroupTypeTemplateService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PreferencesService.reset();
      await PreferencesService.initialize();
      service = GroupTypeTemplateService();
    });

    test('returns empty list when storage is empty', () {
      expect(service.getTemplates(), isEmpty);
    });

    test('upserts template and loads it back', () async {
      final template = GroupTypeTemplate(
        id: 'tpl-1',
        name: 'Weekend',
        iconCodePoint: 0xe539,
        defaultCategories: ['Fuel', 'Food'],
      );

      await service.upsertTemplate(template);
      final templates = service.getTemplates();

      expect(templates.length, 1);
      expect(templates.first.id, 'tpl-1');
      expect(templates.first.name, 'Weekend');
      expect(templates.first.defaultCategories, ['Fuel', 'Food']);
    });

    test('delete removes template', () async {
      await service.saveTemplates([
        GroupTypeTemplate(
          id: 'tpl-1',
          name: 'Weekend',
          iconCodePoint: 0xe539,
          defaultCategories: ['Fuel'],
        ),
      ]);

      await service.deleteTemplate('tpl-1');
      expect(service.getTemplates(), isEmpty);
    });
  });
}
