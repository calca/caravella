import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:io_caravella_egm/main/expected_errors.dart';

/// Which uncaught errors the app drops: network failures by type, and map
/// tiles by origin. Anything else is logged, even if its message happens to
/// mention a connection.
void main() {
  test('network failures are expected', () {
    expect(isExpectedNetworkError(const SocketException('offline')), isTrue);
    expect(isExpectedNetworkError(const HttpException('reset')), isTrue);
    expect(isExpectedNetworkError(const HandshakeException('tls')), isTrue);
    expect(isExpectedNetworkError(http.ClientException('no host')), isTrue);
    expect(
      isExpectedNetworkError(
        NetworkImageLoadException(
          statusCode: 503,
          uri: Uri.parse('https://example.org/a.png'),
        ),
      ),
      isTrue,
    );
  });

  test('a failed map tile is expected, by message or by stack', () {
    expect(
      isExpectedNetworkError(Exception('NetworkTileImageProvider failed')),
      isTrue,
    );
    expect(
      isExpectedNetworkError(
        Exception('decode'),
        StackTrace.fromString(
          '#0 TileImage.load (package:flutter_map/src/layer/tile.dart:10)',
        ),
      ),
      isTrue,
    );
  });

  test('other errors are not, whatever their message says', () {
    // These were dropped when the filter looked for words in the message.
    expect(isExpectedNetworkError(StateError('Connection closed')), isFalse);
    expect(isExpectedNetworkError(Exception('Image provider: null')), isFalse);
    expect(
      isExpectedNetworkError(StateError('MapController disposed')),
      isFalse,
    );
    expect(
      isExpectedNetworkError(ArgumentError('fitCamera: no bounds')),
      isFalse,
    );
    expect(isExpectedNetworkError(const FormatException('bad json')), isFalse);
    expect(isExpectedNetworkError(TypeError()), isFalse);
  });
}
