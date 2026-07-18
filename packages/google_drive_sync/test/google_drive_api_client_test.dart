import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_drive_sync/google_drive_sync.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// [GoogleDriveApiClient] wraps `googleapis`' generated Drive client, whose
/// only I/O seam is the `http.Client` passed to its constructor — so these
/// tests fake the Drive v3 REST responses instead of hitting the network,
/// covering the error-swallowing behavior in `downloadAllShards` that has no
/// coverage today (the only existing test in this package, in
/// `google_drive_sync_factory_test.dart`, only covers the build-flag gate).
void main() {
  group('GoogleDriveApiClient.downloadAllShards', () {
    test(
        'a single shard failing to download does not abort the others — '
        'it is logged and skipped', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/drive/v3/files') &&
            request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'files': [
                {'id': 'ok-id', 'name': 'caravella_shard_device-ok.json'},
                {'id': 'broken-id', 'name': 'caravella_shard_device-broken.json'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        if (request.url.path.endsWith('/drive/v3/files/ok-id')) {
          return http.Response(
            '{"delta":"ok"}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        if (request.url.path.endsWith('/drive/v3/files/broken-id')) {
          // Simulates a transient Drive API failure for this one file.
          return http.Response(
            jsonEncode({
              'error': {'code': 500, 'message': 'Internal error'},
            }),
            500,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        fail('Unexpected request: ${request.method} ${request.url}');
      });

      final client = GoogleDriveApiClient(mockClient);

      final shards = await client.downloadAllShards();

      expect(shards, hasLength(1));
      expect(shards.single, '{"delta":"ok"}');
    });

    test('no shard files at all returns an empty list', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'files': <Map<String, String>>[]}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = GoogleDriveApiClient(mockClient);

      expect(await client.downloadAllShards(), isEmpty);
    });
  });
}
