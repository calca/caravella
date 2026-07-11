import 'dart:convert';

import '../../model/group_type_template.dart';
import '../logging/logger_service.dart';
import 'preferences_service.dart';

class GroupTypeTemplateService {
  GroupTypeTemplateService({PreferencesService? preferencesService})
    : _preferencesService = preferencesService;

  final PreferencesService? _preferencesService;

  PreferencesService get _prefs => _preferencesService ?? PreferencesService.instance;

  List<GroupTypeTemplate> getTemplates() {
    final raw = _prefs.groupTypeTemplates.getTemplatesJson();
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        LoggerService.warning(
          'GroupTypeTemplateService.getTemplates: invalid payload type',
          name: 'settings.templates',
        );
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(GroupTypeTemplate.fromJson)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (error, stackTrace) {
      LoggerService.error(
        'GroupTypeTemplateService.getTemplates: failed to parse templates',
        name: 'settings.templates',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<void> saveTemplates(List<GroupTypeTemplate> templates) async {
    final payload = jsonEncode(templates.map((item) => item.toJson()).toList());
    await _prefs.groupTypeTemplates.setTemplatesJson(payload);
    LoggerService.debug(
      'GroupTypeTemplateService.saveTemplates: saved ${templates.length} templates',
      name: 'settings.templates',
    );
  }

  Future<void> upsertTemplate(GroupTypeTemplate template) async {
    final templates = getTemplates();
    final index = templates.indexWhere((item) => item.id == template.id);
    if (index == -1) {
      templates.add(template);
    } else {
      templates[index] = template;
    }
    await saveTemplates(templates);
  }

  Future<void> deleteTemplate(String templateId) async {
    final templates = getTemplates()
      ..removeWhere((item) => item.id == templateId);
    await saveTemplates(templates);
  }
}
