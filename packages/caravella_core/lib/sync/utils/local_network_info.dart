import 'dart:io';

/// Resolves this device's local (LAN) IPv4 address for embedding in a QR
/// pairing payload, so the scanning device can connect directly to it
/// without waiting for mDNS discovery to resolve the peer first.
class LocalNetworkInfo {
  /// Returns the first non-loopback IPv4 address found on any network
  /// interface, or `null` if none is available (e.g. no Wi-Fi connection).
  static Future<String?> resolveLocalIPv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) return address.address;
        }
      }
    } catch (_) {
      // Fall through to null — caller should handle "no local network".
    }
    return null;
  }
}
