import 'dart:convert';

import 'package:caravella_core/model/expense_group.dart';
import 'package:caravella_core/services/logging/logger_service.dart';
import 'package:caravella_core/sync/utils/sync_clock.dart';

/// Schema version for the sync payload format.
///
/// Increment this when the payload structure changes in a breaking way.
const int _schemaVersion = 1;

/// Serializes and deserializes [ExpenseGroup] objects with sync metadata for
/// the JSON-based sync channel.
///
/// The format is compatible with [DeltaBuilder] but adds a schema-versioned
/// envelope around the payload for file-based / cloud-relay transport.
class GroupSerializer {
  static const _tag = 'sync.json.serializer';

  GroupSerializer._();

  /// Serializes an [ExpenseGroup] with sync metadata to a JSON map.
  ///
  /// The returned map contains the full group JSON (via [ExpenseGroup.toJson])
  /// plus a nested `_sync` object holding [deviceId], [updatedAt],
  /// [syncVersion], and [deleted] flag.
  static Map<String, dynamic> toJson(
    ExpenseGroup group, {
    required String deviceId,
    required int updatedAt,
    required int syncVersion,
    bool deleted = false,
  }) {
    final json = group.toJson();
    json['_sync'] = <String, dynamic>{
      'device_id': deviceId,
      'updated_at': updatedAt,
      'sync_version': syncVersion,
      'deleted': deleted,
    };
    return json;
  }

  /// Deserializes a JSON map back to an [ExpenseGroup].
  ///
  /// Returns `null` if the JSON is malformed or missing required fields.
  /// Malformed entries are logged as warnings.
  static ExpenseGroup? fromJson(Map<String, dynamic> json) {
    try {
      if (!json.containsKey('id') || !json.containsKey('title')) {
        LoggerService.warning(
          'Skipping malformed group JSON: missing id or title',
          name: _tag,
        );
        return null;
      }
      return ExpenseGroup.fromJson(json);
    } catch (e, st) {
      LoggerService.warning(
        'Failed to deserialize group from JSON',
        name: _tag,
      );
      LoggerService.debug('$e\n$st', name: _tag);
      return null;
    }
  }

  /// Serializes a list of [groups] into a complete sync payload JSON string.
  ///
  /// The payload includes a schema version header, device identity, and
  /// separate lists for active and [deletedGroups].
  ///
  /// [syncMetadata] maps each group ID to its sync metadata (`device_id`,
  /// `updated_at`, `sync_version`, `deleted`). When metadata is available for
  /// a group it is used verbatim — ensuring the serialized timestamps match
  /// the values stored in the database (critical for LWW conflict resolution).
  /// Groups without an entry in [syncMetadata] receive a default metadata
  /// block using [deviceId] and the current time.
  ///
  /// The [deletedGroups] list should contain maps with `id` and `updated_at`.
  static String serializePayload({
    required List<ExpenseGroup> groups,
    required String deviceId,
    required String deviceName,
    required List<Map<String, dynamic>> deletedGroups,
    Map<String, Map<String, dynamic>> syncMetadata = const {},
  }) {
    final payload = <String, dynamic>{
      'schema': _schemaVersion,
      'device_id': deviceId,
      'device_name': deviceName,
      'exported_at': SyncClock.nowMs(),
      'groups': groups.map((g) {
        final json = g.toJson();
        // Use caller-supplied sync metadata when available so that
        // timestamps match what the database stores (required for LWW).
        final meta = syncMetadata[g.id];
        json['_sync'] = meta ?? <String, dynamic>{
          'device_id': deviceId,
          'updated_at': SyncClock.nowMs(),
          'sync_version': 1,
          'deleted': false,
        };
        return json;
      }).toList(),
      'deleted_groups': deletedGroups,
    };

    return jsonEncode(payload);
  }

  /// Deserializes a sync payload JSON string back into structured data.
  ///
  /// Returns a [Map] matching the envelope structure (schema, device_id,
  /// device_name, exported_at, groups, deleted_groups), or `null` if parsing
  /// fails.
  static Map<String, dynamic>? deserializePayload(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        LoggerService.warning(
          'Payload is not a JSON object',
          name: _tag,
        );
        return null;
      }

      // Validate required envelope fields
      if (!decoded.containsKey('schema') || decoded['schema'] is! int) {
        LoggerService.warning(
          'Payload missing or invalid "schema" field',
          name: _tag,
        );
        return null;
      }
      if (!decoded.containsKey('device_id') ||
          decoded['device_id'] is! String) {
        LoggerService.warning(
          'Payload missing or invalid "device_id" field',
          name: _tag,
        );
        return null;
      }
      if (!decoded.containsKey('groups') || decoded['groups'] is! List) {
        LoggerService.warning(
          'Payload missing or invalid "groups" field',
          name: _tag,
        );
        return null;
      }

      return decoded;
    } catch (e, st) {
      LoggerService.warning(
        'Failed to deserialize sync payload',
        name: _tag,
      );
      LoggerService.debug('$e\n$st', name: _tag);
      return null;
    }
  }
}
