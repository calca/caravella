import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:caravella_core/caravella_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncEnvelope', () {
    test('encrypt then decrypt with the same key round-trips the payload',
        () async {
      final algorithm = AesGcm.with256bits();
      final key = await algorithm.newSecretKey();

      final payload = {
        'device_id': 'abc-123',
        'groups': [
          {'id': 'g1', 'title': 'Vacanza'},
        ],
      };

      final envelope = await SyncEnvelope.encrypt(key, payload);
      final decrypted = await SyncEnvelope.decrypt(key, envelope);

      expect(decrypted, equals(payload));
    });

    test('decrypting with the wrong key throws instead of returning garbage',
        () async {
      final algorithm = AesGcm.with256bits();
      final key = await algorithm.newSecretKey();
      final wrongKey = await algorithm.newSecretKey();

      final envelope = await SyncEnvelope.encrypt(key, {'foo': 'bar'});

      expect(
        () => SyncEnvelope.decrypt(wrongKey, envelope),
        throwsA(anything),
      );
    });

    test('tampering with the envelope bytes breaks decryption', () async {
      final algorithm = AesGcm.with256bits();
      final key = await algorithm.newSecretKey();

      final envelope = await SyncEnvelope.encrypt(key, {'foo': 'bar'});
      final bytes = base64Decode(envelope);
      // Flip a bit in the ciphertext (well past the nonce prefix).
      bytes[bytes.length - 1] ^= 0xFF;
      final tampered = base64Encode(bytes);

      expect(
        () => SyncEnvelope.decrypt(key, tampered),
        throwsA(anything),
      );
    });
  });

  group('X25519 ECDH + HKDF agreement', () {
    test(
        'two independently generated keypairs derive the identical shared '
        'key from each other\'s public key — mirrors DeviceKeyManager.deriveSharedKey',
        () async {
      final algorithm = X25519();
      final aliceKeyPair = await algorithm.newKeyPair();
      final bobKeyPair = await algorithm.newKeyPair();

      final alicePublicKey = await aliceKeyPair.extractPublicKey();
      final bobPublicKey = await bobKeyPair.extractPublicKey();

      final aliceSharedSecret = await algorithm.sharedSecretKey(
        keyPair: aliceKeyPair,
        remotePublicKey: bobPublicKey,
      );
      final bobSharedSecret = await algorithm.sharedSecretKey(
        keyPair: bobKeyPair,
        remotePublicKey: alicePublicKey,
      );

      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
      const info = 'caravella-sync-v1';

      final aliceDerived = await hkdf.deriveKey(
        secretKey: aliceSharedSecret,
        info: utf8.encode(info),
      );
      final bobDerived = await hkdf.deriveKey(
        secretKey: bobSharedSecret,
        info: utf8.encode(info),
      );

      expect(
        await aliceDerived.extractBytes(),
        equals(await bobDerived.extractBytes()),
      );
    });

    test('a third party\'s keypair derives a different shared key', () async {
      final algorithm = X25519();
      final aliceKeyPair = await algorithm.newKeyPair();
      final bobKeyPair = await algorithm.newKeyPair();
      final eveKeyPair = await algorithm.newKeyPair();

      final bobPublicKey = await bobKeyPair.extractPublicKey();

      final aliceSharedSecret = await algorithm.sharedSecretKey(
        keyPair: aliceKeyPair,
        remotePublicKey: bobPublicKey,
      );
      final eveSharedSecret = await algorithm.sharedSecretKey(
        keyPair: eveKeyPair,
        remotePublicKey: bobPublicKey,
      );

      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
      final aliceDerived = await hkdf.deriveKey(
        secretKey: aliceSharedSecret,
        info: utf8.encode('caravella-sync-v1'),
      );
      final eveDerived = await hkdf.deriveKey(
        secretKey: eveSharedSecret,
        info: utf8.encode('caravella-sync-v1'),
      );

      expect(
        await aliceDerived.extractBytes(),
        isNot(equals(await eveDerived.extractBytes())),
      );
    });
  });
}
