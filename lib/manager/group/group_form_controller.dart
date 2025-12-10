import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:caravella_core/caravella_core.dart';
// ...existing code...
import 'data/group_form_state.dart';
import 'group_edit_mode.dart';

/// Controller encapsulates business logic for the group form.
class GroupFormController {
  final GroupFormState state;
  final GroupEditMode mode;
  final ExpenseGroupNotifier? _notifier;
  final VoidCallback? onSaveSuccess;
  final Function(String)? onSaveError;

  GroupFormController(
    this.state,
    this.mode, [
    this._notifier,
    this.onSaveSuccess,
    this.onSaveError,
  ]) {
    // No automatic auto-save: saving is performed explicitly (e.g. on back)
  }

  // Auto-save removed: saving performed explicitly (for example on back press)

  void load(ExpenseGroup? group) {
    if (mode == GroupEditMode.create) return; // nothing to load in create mode
    if (group == null) return;
    // controller no longer keeps a separate copy; state holds the original
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
    state.notificationEnabled = group.notificationEnabled;
    state.groupType = group.groupType;
    state.autoLocationEnabled = group.autoLocationEnabled;
    // Keep a snapshot in the state to avoid extra repository fetches
    state.setOriginalGroup(group.copyWith());
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
    if (state.originalGroup == null) return false;
    final g = state.originalGroup!;
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
    if (g.groupType != state.groupType) return true;
    if (g.autoLocationEnabled != state.autoLocationEnabled) return true;
    if (g.notificationEnabled != state.notificationEnabled) return true;
    return false;
  }

  Future<ExpenseGroup> save() async {
    state.setSaving(true);
    try {
      // If we're in edit mode but the controller was not initialized via
      // load(...), attempt to fetch the original group from storage so
      // subsequent diff-based updates have the correct baseline.
      // If missing the baseline in state, fall back to repository fetch
      if (mode == GroupEditMode.edit &&
          state.originalGroup == null &&
          state.id != null) {
        try {
          final fetched = await ExpenseGroupStorageV2.getTripById(state.id!);
          if (fetched != null) {
            state.setOriginalGroup(fetched.copyWith());
          } else {
            debugPrint(
              'GroupFormController.save: original group not found for id ${state.id}',
            );
          }
        } catch (e, st) {
          debugPrint(
            'GroupFormController.save: failed to fetch original group: $e\n$st',
          );
        }
      }

      final now = DateTime.now();
      final group = (state.originalGroup ?? ExpenseGroup.empty()).copyWith(
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
        notificationEnabled: state.notificationEnabled,
        groupType: state.groupType,
        autoLocationEnabled: state.autoLocationEnabled,
        timestamp: state.originalGroup?.timestamp ?? now,
      );

      if (mode == GroupEditMode.edit) {
        await ExpenseGroupStorageV2.updateGroupMetadata(group);

        // After updating group metadata, propagate any participant or
        // category renames into the persisted expenses so embedded
        // references show the updated names. Compare with the original
        // loaded group to detect renames.
        if (state.originalGroup != null) {
          final orig = state.originalGroup!;

          // Build lists containing only the participants that were renamed
          // (same id, different display fields). New participants (no
          // matching id in orig) are ignored because they cannot be
          // referenced by existing expenses.
          final List<ExpenseParticipant> changedOrigParticipants = [];
          final List<ExpenseParticipant> changedUpdatedParticipants = [];
          for (final p in state.participants) {
            final idx = orig.participants.indexWhere((op) => op.id == p.id);
            if (idx == -1) continue;
            final origP = orig.participants[idx];
            if (origP.name != p.name) {
              changedOrigParticipants.add(origP);
              changedUpdatedParticipants.add(p.copyWith());
            }
          }
          if (changedOrigParticipants.isNotEmpty) {
            await ExpenseGroupStorageV2.updateParticipantReferencesFromDiff(
              group.id,
              changedOrigParticipants,
              changedUpdatedParticipants,
            );
          }

          // Same for categories
          final List<ExpenseCategory> changedOrigCategories = [];
          final List<ExpenseCategory> changedUpdatedCategories = [];
          for (final c in state.categories) {
            final idx = orig.categories.indexWhere((oc) => oc.id == c.id);
            if (idx == -1) continue;
            final origC = orig.categories[idx];
            if (origC.name != c.name) {
              changedOrigCategories.add(origC);
              changedUpdatedCategories.add(c.copyWith());
            }
          }
          if (changedOrigCategories.isNotEmpty) {
            await ExpenseGroupStorageV2.updateCategoryReferencesFromDiff(
              group.id,
              changedOrigCategories,
              changedUpdatedCategories,
            );
          }
        }
      } else {
        await ExpenseGroupStorageV2.addExpenseGroup(group);
      }

      // Ensure repository reloads fresh data and notify listeners globally
      ExpenseGroupStorageV2.forceReload();
      _notifier?.notifyGroupUpdated(group.id);

      // store snapshot in state (single source of truth for original)
      state.setOriginalGroup(group.copyWith());
      return group;
    } finally {
      state.setSaving(false);
    }
  }

  Future<void> deleteGroup() async {
    if (mode == GroupEditMode.create || state.originalGroup == null) return;
    // Use the repository delete API which handles loading/saving atomically
    await ExpenseGroupStorageV2.deleteGroup(state.originalGroup!.id);
    // Force reload and notify so UI updates across the app
    ExpenseGroupStorageV2.forceReload();
    _notifier?.notifyGroupDeleted(state.originalGroup!.id);
  }

  /// Attempt to remove a participant from the current group if it's unused.
  /// Returns true if removal succeeded and the state was updated.
  Future<bool> removeParticipantIfUnused(int index) async {
    if (index < 0 || index >= state.participants.length) return false;
    final participant = state.participants[index];
    // If no original (create mode), we can remove locally.
    if (state.originalGroup == null) {
      state.removeParticipant(index);
      return true;
    }

    final removed = await ExpenseGroupStorageV2.removeParticipantIfUnused(
      state.originalGroup!.id,
      participant.id,
      state.originalGroup!,
    );
    if (removed) {
      state.removeParticipant(index);
    }
    return removed;
  }

  /// Attempt to remove a category from the current group if it's unused.
  /// Returns true if removal succeeded and the state was updated.
  Future<bool> removeCategoryIfUnused(int index) async {
    if (index < 0 || index >= state.categories.length) return false;
    final category = state.categories[index];
    if (state.originalGroup == null) {
      state.removeCategory(index);
      return true;
    }

    final removed = await ExpenseGroupStorageV2.removeCategoryIfUnused(
      state.originalGroup!.id,
      category.id,
      state.originalGroup!,
    );
    if (removed) {
      state.removeCategory(index);
    }
    return removed;
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

  /// Remove currently selected background (image and/or color) from disk and clear state.
  /// Safe to call even if no background is set.
  Future<void> removeImage() async {
    final path = state.imagePath;
    if (path != null) {
      try {
        final f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (e, st) {
        debugPrint('removeImage error: $e\n$st');
      }
    }
    // Clear both background image and color completely by directly setting the fields
    // to avoid any interdependency logic in the setters
    state.imagePath = null;
    state.color = null;
    state.refresh();
  }

  /// Sets the group type and manages default categories based on edit mode.
  ///
  /// In CREATE mode:
  /// - Removes categories from the previous type (if any)
  /// - Adds categories for the new type
  ///
  /// In EDIT mode:
  /// - Only updates the type, categories are never modified
  ///
  /// [defaultCategoryNames] should be the localized category names to populate.
  /// [previousTypeCategoryNames] are the localized names from the previous type to remove.
  void setGroupType(
    ExpenseGroupType? type, {
    bool autoPopulateCategories = true,
    List<String>? defaultCategoryNames,
    List<String>? previousTypeCategoryNames,
  }) {
    state.setGroupType(type);

    // In edit mode, never modify categories
    if (mode == GroupEditMode.edit) return;

    // In create mode, manage category replacement
    if (autoPopulateCategories && type != null) {
      if (defaultCategoryNames == null) {
        throw ArgumentError(
          'defaultCategoryNames is required when autoPopulateCategories is true',
        );
      }

      // Remove categories from previous type
      if (previousTypeCategoryNames != null) {
        state.categories.removeWhere(
          (category) => previousTypeCategoryNames.contains(category.name),
        );
      }

      // Add new categories if not already present
      for (final categoryName in defaultCategoryNames) {
        if (!state.categories.any((c) => c.name == categoryName)) {
          state.addCategory(ExpenseCategory(name: categoryName));
        }
      }

      state.refresh();
    }
  }

  void dispose() {
    // Nothing to dispose related to auto-save; keep method for symmetry.
  }
}
