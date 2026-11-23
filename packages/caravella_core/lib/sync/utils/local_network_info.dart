import 'dart:io';

import '../../services/logging/logger_service.dart';

/// Resolves this device's local (LAN) IPv4 address for embedding in a QR
/// pairing payload, so the scanning device can connect directly to it
/// without waiting for mDNS discovery to resolve the peer first.
class LocalNetworkInfo {
  /// The Wi-Fi (or hotspot / Ethernet) IPv4 address the other phone can
  /// reach, or `null` if there is none (e.g. no Wi-Fi connection).
  ///
  /// A phone has several interfaces at once: mobile data (`rmnet…`,
  /// `ccmni…`), a VPN (`tun…`), Wi-Fi (`wlan…`), a hotspot (`swlan…`,
  /// `ap…`). Taking just the first one put the mobile-data address in the
  /// QR code on some phones (a Galaxy S25 with mobile data on), and the
  /// scanning phone could never connect: "pairing failed".
  static Future<String?> resolveLocalIPv4() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      final candidates = [
        for (final interface in interfaces)
          for (final address in interface.addresses)
            (name: interface.name, address: address.address),
      ];
      final chosen = pickLanAddress(candidates);
      LoggerService.debug(
        'LAN address for pairing: $chosen '
        '(from ${candidates.map((c) => '${c.name}=${c.address}').join(', ')})',
        name: 'sync.lan',
      );
      return chosen;
    } catch (_) {
      // Fall through to null — caller should handle "no local network".
    }
    return null;
  }

  /// Picks the address another device on the same Wi-Fi can reach: a
  /// private address (RFC 1918) on a Wi-Fi, hotspot or Ethernet interface
  /// first, then any private address not on mobile data or a VPN. Mobile
  /// data, VPNs, carrier-grade NAT (100.64/10) and public addresses are
  /// never offered: nothing on the local network can reach them.
  static String? pickLanAddress(
    List<({String name, String address})> candidates,
  ) {
    final usable = [
      for (final c in candidates)
        if (_isPrivate(c.address) && !_isRemoteInterface(c.name)) c,
    ];
    for (final c in usable) {
      if (_isLocalInterface(c.name)) return c.address;
    }
    return usable.firstOrNull?.address;
  }

  static final _localInterface = RegExp(
    r'^(wlan|swlan|ap|softap|wifi|eth|en|wl|p2p|bridge|br)',
    caseSensitive: false,
  );

  static final _remoteInterface = RegExp(
    r'^(rmnet|ccmni|pdp|radio|seth|v4-|clat|tun|ppp|ipsec|utun|wg|dummy)',
    caseSensitive: false,
  );

  static bool _isLocalInterface(String name) => _localInterface.hasMatch(name);

  static bool _isRemoteInterface(String name) =>
      _remoteInterface.hasMatch(name);

  static bool _isPrivate(String address) {
    final parts = address.split('.').map(int.tryParse).toList();
    if (parts.length != 4 || parts.any((p) => p == null)) return false;
    final a = parts[0]!, b = parts[1]!;
    return a == 10 ||
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168);
  }
}
