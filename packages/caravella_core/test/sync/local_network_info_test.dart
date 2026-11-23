import 'package:caravella_core/sync/utils/local_network_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// The QR code carries one address: it must be the one another phone on the
/// same Wi-Fi can reach, whatever order the interfaces come in.
void main() {
  ({String name, String address}) i(String name, String address) =>
      (name: name, address: address);

  test('mobile data listed first: the Wi-Fi address wins', () {
    expect(
      LocalNetworkInfo.pickLanAddress([
        i('rmnet_data0', '10.161.4.22'),
        i('wlan0', '192.168.1.34'),
      ]),
      '192.168.1.34',
    );
  });

  test('a VPN or carrier-grade NAT is never offered', () {
    expect(
      LocalNetworkInfo.pickLanAddress([
        i('tun0', '10.8.0.2'),
        i('rmnet_data1', '100.72.10.5'),
        i('wlan0', '172.20.10.3'),
      ]),
      '172.20.10.3',
    );
  });

  test('a phone sharing its hotspot offers the hotspot address', () {
    expect(
      LocalNetworkInfo.pickLanAddress([
        i('rmnet_data0', '100.80.1.9'),
        i('swlan0', '192.168.43.1'),
      ]),
      '192.168.43.1',
    );
  });

  test('an emulator (eth0 only) still works', () {
    expect(
      LocalNetworkInfo.pickLanAddress([i('eth0', '10.0.2.15')]),
      '10.0.2.15',
    );
  });

  test('only mobile data: no address, so the QR is not offered', () {
    expect(
      LocalNetworkInfo.pickLanAddress([
        i('rmnet_data0', '10.161.4.22'),
        i('ccmni1', '100.64.0.7'),
      ]),
      isNull,
    );
  });

  test('an unknown interface name with a private address is a fallback', () {
    expect(
      LocalNetworkInfo.pickLanAddress([
        i('rmnet_data0', '10.161.4.22'),
        i('mlan0', '192.168.0.12'),
      ]),
      '192.168.0.12',
    );
  });
}
