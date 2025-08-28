import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/model/expense_group.dart';
import '../../data/expense_group_storage_v2.dart';
// ...existing code...
import '../../data/model/expense_details.dart';
import 'data/group_form_state.dart';
import 'group_edit_mode.dart';
import '../../state/expense_group_notifier.dart';

/// Controller encapsulates business logic for the group form.
class GroupFormController {
  final GroupFormState state;
  final GroupEditMode mode;
  final ExpenseGroupNotifier? _notifier;
  ExpenseGroup? _original;

  GroupFormController(this.state, this.mode, [this._notifier]);

  void load(ExpenseGroup? group) {
    if (mode == GroupEditMode.create) return; // nothing to load in create mode
    if (group == null) return;
    _original = group;
    state.id = group.id;
    state.title = group.title;
    state.participants
      ..clear()
      ..addAll(group.participants.map((p) => p.copyWith()));
    state.categories
      ..clear()
      ..addAll(group.categories.map((c) => c.copyWith()));
    state.startDate = group.startDate;
    state.endDate = group.endDate;
    state.currency = _currencyFromGroup(group.currency);
    state.imagePath = group.file;
    state.color = group.color;
    state.refresh();
  }

  Map<String, String> _currencyFromGroup(String codeOrSymbol) {
    // Minimal mapping: if code length 3 treat as code, else assume EUR.
    if (codeOrSymbol.length == 3) {
      return {
        'symbol': _symbolFor(codeOrSymbol),
        'code': codeOrSymbol,
        'name': codeOrSymbol,
      };
    }
    return {'symbol': codeOrSymbol, 'code': 'EUR', 'name': 'Euro'};
  }

  String _symbolFor(String code) {
    switch (code) {
      case 'EUR':
        return '€';
      case 'USD':
        return '';
      default:
        return code;
    }
  }

  bool get hasChanges {
    if (mode == GroupEditMode.create) {
      return state.title.isNotEmpty ||
          state.participants.isNotEmpty ||
          state.categories.isNotEmpty ||
          state.startDate != null ||
          state.endDate != null ||
          state.imagePath != null ||
          state.color != null;
    }
    if (_original == null) return false;
    final g = _original!;
    if (g.title != state.title) return true;
    if (g.startDate != state.startDate || g.endDate != state.endDate) {
      return true;
    }
    if (g.participants.length != state.participants.length) return true;
    for (int i = 0; i < g.participants.length; i++) {
      if (g.participants[i].name != state.participants[i].name) return true;
    }
    if (g.categories.length != state.categories.length) return true;
    for (int i = 0; i < g.categories.length; i++) {
      if (g.categories[i].name != state.categories[i].name) return true;
    }
    if (g.currency != state.currency['code'] &&
        g.currency != state.currency['symbol']) {
      return true;
    }
    if (g.file != state.imagePath) return true;
    if (g.color != state.color) return true;
    return false;
  }

  Future<ExpenseGroup> save() async {
    state.setSaving(true);
    try {
      final now = DateTime.now();
      final group = (_original ?? ExpenseGroup.empty()).copyWith(
        id: state.id,
        title: state.title.trim(),
        // Preserve existing participant IDs when editing: state.participants
        // already contains ExpenseParticipant instances (loaded via copyWith),
        // so reuse their ids by copying them instead of creating brand new ones.
        participants: state.participants.map((e) => e.copyWith()).toList(),
        // Same for categories: preserve ids to keep referential integrity
        categories: state.categories.map((e) => e.copyWith()).toList(),
        startDate: state.startDate,
        endDate: state.endDate,
        currency: state.currency['symbol'] ?? state.currency['code'] ?? 'EUR',
        file: state.imagePath,
        color: state.color,
        timestamp: _original?.timestamp ?? now,
        // Preserve existing expenses explicitly when editing an existing group
        expenses: _original != null
            ? List<ExpenseDetails>.from(_original!.expenses)
            : const [],
      );

      if (mode == GroupEditMode.edit) {
        await ExpenseGroupStorageV2.updateGroupMetadata(group);
      } else {
        await ExpenseGroupStorageV2.addExpenseGroup(group);
      }

      // Ensure repository reloads fresh data and notify listeners globally
      ExpenseGroupStorageV2.forceReload();
      _notifier?.notifyGroupUpdated(group.id);

      _original = group;
      return group;
    } finally {
      state.setSaving(false);
    }
  }

  Future<void> deleteGroup() async {
    if (mode == GroupEditMode.create || _original == null) return;
    // Use the repository delete API which handles loading/saving atomically
    await ExpenseGroupStorageV2.deleteGroup(_original!.id);
    // Force reload and notify so UI updates across the app
    ExpenseGroupStorageV2.forceReload();
    _notifier?.notifyGroupDeleted(_original!.id);
  }

  Future<String?> persistPickedImage(File file) async {
    try {
      state.setLoading(true);
      final dir = await getApplicationDocumentsDirectory();
      final name = 'group_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final target = File('${dir.path}/$name');
      await file.copy(target.path);
      state.setImage(target.path);
      return target.path;
    } catch (e, st) {
      debugPrint('persistPickedImage error: $e\n$st');
      return null;
    } finally {
      state.setLoading(false);
    }
  }
}
