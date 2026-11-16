import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

/// Whether [error] is one the app expects and may ignore: the network not
/// answering (offline, a host that can't be reached, a map tile or a remote
/// image that fails to load).
///
/// Decided by the error's type, and for map tiles by where it comes from
/// ([stack] or the message naming `flutter_map` / its tile provider). It
/// used to be decided by words in the message — any error mentioning
/// "Connection" or "Image provider" was dropped — which could hide a real
/// bug. Everything else is unexpected and must be logged as an error.
bool isExpectedNetworkError(Object error, [StackTrace? stack]) {
  if (error is SocketException ||
      error is HttpException ||
      error is TlsException ||
      error is http.ClientException ||
      error is NetworkImageLoadException) {
    return true;
  }
  // Map tiles: flutter_map reports failed loads in several shapes.
  bool fromTiles(String text) =>
      text.contains('NetworkTileImageProvider') ||
      text.contains('package:flutter_map/');
  return fromTiles(error.toString()) || fromTiles(stack?.toString() ?? '');
}
