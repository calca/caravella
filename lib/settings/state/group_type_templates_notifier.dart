import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';

class GroupTypeTemplatesNotifier extends ChangeNotifier {
  GroupTypeTemplatesNotifier({GroupTypeTemplateService? service})
    : _service = service ?? GroupTypeTemplateService() {
    load();
  }

  final GroupTypeTemplateService _service;
  List<GroupTypeTemplate> _templates = [];

  List<GroupTypeTemplate> get templates => List.unmodifiable(_templates);

  void load() {
    try {
      _templates = _service.getTemplates();
    } on StateError {
      LoggerService.warning(
        'Group templates preferences are unavailable',
        name: 'state.notifier',
      );
      _templates = [];
    }
    notifyListeners();
  }

  Future<void> upsert(GroupTypeTemplate template) async {
    await _service.upsertTemplate(template);
    load();
  }

  Future<void> delete(String id) async {
    await _service.deleteTemplate(id);
    load();
  }
}
