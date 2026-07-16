import 'package:caravella_core/model/expense_group.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/json/group_serializer.dart';

/// Merges multiple JSON shards (from different devices) using Last Writer Wins.
///
/// Each shard is a JSON string produced by [GroupSerializer.serializePayload].
/// When the same group ID appears in multiple shards the one with the higher
/// `_sync.updated_at` timestamp wins.
class JsonMerger {
  static const _tag = 'sync.json.merger';

  JsonMerger._();

  /// Merges multiple JSON [jsonShards] using LWW.
  ///
  /// Each shard is a JSON string in the format produced by
  /// [GroupSerializer.serializePayload]. Returns a merged list of
  /// [ExpenseGroup] objects sorted by `updated_at` descending (newest first).
  ///
  /// Groups marked as deleted (via `_sync.deleted == true`) are excluded from
  /// the result.
  static List<ExpenseGroup> mergeShards(List<String> jsonShards) {
    // groupId → (group JSON map, updated_at)
    final winners = <String, _GroupEntry>{};
    // Track deleted group IDs and their timestamps
    final deletedIds = <String, int>{};

    for (final shard in jsonShards) {
      final payload = GroupSerializer.deserializePayload(shard);
      if (payload == null) {
        LoggerService.warning(
          'Skipping unparsable shard',
          name: _tag,
        );
        continue;
      }

      final groups = payload['groups'] as List? ?? [];
      for (final raw in groups) {
        if (raw is! Map<String, dynamic>) continue;

        final groupId = raw['id'] as String?;
        if (groupId == null) continue;

        final syncMeta = raw['_sync'] as Map<String, dynamic>? ?? {};
        final updatedAt = syncMeta['updated_at'] as int? ?? 0;
        final deleted = syncMeta['deleted'] as bool? ?? false;

        if (deleted) {
          // Track deletion — only keep the newest deletion timestamp
          final existing = deletedIds[groupId] ?? 0;
          if (updatedAt > existing) {
            deletedIds[groupId] = updatedAt;
          }
          continue;
        }

        final existing = winners[groupId];
        if (existing == null || updatedAt > existing.updatedAt) {
          winners[groupId] = _GroupEntry(json: raw, updatedAt: updatedAt);
        }
      }

      // Process deleted_groups list from the payload
      final deletedGroups = payload['deleted_groups'] as List? ?? [];
      for (final entry in deletedGroups) {
        if (entry is! Map<String, dynamic>) continue;
        final id = entry['id'] as String?;
        final ts = entry['updated_at'] as int? ?? 0;
        if (id == null) continue;

        final existing = deletedIds[id] ?? 0;
        if (ts > existing) {
          deletedIds[id] = ts;
        }
      }
    }

    // Remove groups whose deletion timestamp beats the update timestamp
    for (final entry in deletedIds.entries) {
      final winner = winners[entry.key];
      if (winner != null && entry.value >= winner.updatedAt) {
        winners.remove(entry.key);
      }
    }

    // Deserialize winners and sort by updated_at descending
    final merged = <_SortableGroup>[];
    for (final entry in winners.entries) {
      final group = GroupSerializer.fromJson(entry.value.json);
      if (group != null) {
        merged.add(_SortableGroup(group: group, updatedAt: entry.value.updatedAt));
      }
    }

    merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    LoggerService.info(
      'Merged ${jsonShards.length} shards → ${merged.length} groups '
      '(${deletedIds.length} deleted)',
      name: _tag,
    );

    return merged.map((e) => e.group).toList();
  }

  /// Computes the diff between [local] and [merged] groups.
  ///
  /// Returns only groups from [merged] that are new (not in [local]) or
  /// have been updated. Since [ExpenseGroup] does not carry sync-level
  /// `_sync.updated_at` metadata after deserialization, the comparison uses
  /// the model-level [ExpenseGroup.timestamp] field as a proxy for change
  /// detection.
  ///
  /// **Limitation:** changes that only affect sync metadata (e.g. a
  /// `sync_version` bump without a model-level `timestamp` change) will not
  /// be detected by this method. For full sync-metadata-aware diffing, use
  /// the database layer directly.
  static List<ExpenseGroup> diff(
    List<ExpenseGroup> local,
    List<ExpenseGroup> merged,
  ) {
    final localMap = <String, ExpenseGroup>{
      for (final g in local) g.id: g,
    };

    final changes = <ExpenseGroup>[];
    for (final group in merged) {
      final localGroup = localMap[group.id];
      if (localGroup == null) {
        // New group — not present locally
        changes.add(group);
      } else if (group.timestamp != localGroup.timestamp) {
        // Updated group — timestamps differ
        changes.add(group);
      }
    }

    LoggerService.debug(
      'Diff: ${changes.length} changes from ${merged.length} merged vs '
      '${local.length} local',
      name: _tag,
    );

    return changes;
  }
}

/// Internal helper to track a group JSON map alongside its `updated_at`.
class _GroupEntry {
  final Map<String, dynamic> json;
  final int updatedAt;

  _GroupEntry({required this.json, required this.updatedAt});
}

/// Internal helper for sorting deserialized groups by `updated_at`.
class _SortableGroup {
  final ExpenseGroup group;
  final int updatedAt;

  const _SortableGroup({required this.group, required this.updatedAt});
}
