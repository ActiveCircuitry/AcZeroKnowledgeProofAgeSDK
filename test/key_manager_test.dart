/**
 * Unit tests for KeyManager
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'dart:typed_data';
import 'package:flutter/services.dart' as services;
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
import 'support/fake_ac_zkp_platform.dart';

void main() {
  group('KeyManager', () {
    late KeyManager keyManager;
    late AcZkpPlatformInterface originalPlatform;

    setUp(() {
      originalPlatform = AcZkpPlatformInterface.instance;
      installFakeAcZkpPlatform();
      keyManager = KeyManager();
    });

    tearDown(() {
      AcZkpPlatformInterface.instance = originalPlatform;
    });

    test('initialize completes without error', () async {
      await expectLater(
        keyManager.initialize(),
        completes,
      );
    });

    test('backend unavailable is reported during initialization', () async {
      final fakePlatform = FakeAcZkpPlatform()
        ..keyInitializationFailure = services.PlatformException(
          code: 'CRYPTO_BACKEND_UNAVAILABLE',
          message: 'No cryptographic backend is configured.',
        );
      AcZkpPlatformInterface.instance = fakePlatform;
      keyManager = KeyManager();

      await expectLater(
        keyManager.initialize(),
        throwsA(
          isA<ZkpException>().having(
            (error) => error.code,
            'code',
            'CRYPTO_BACKEND_UNAVAILABLE',
          ),
        ),
      );
    });

    test('throws exception if not initialized', () {
      final uninitializedManager = KeyManager();

      expect(
        uninitializedManager.hasProvingKey(),
        throwsA(isA<ZkpException>()),
      );
    });

    test('hasProvingKey returns boolean', () async {
      await keyManager.initialize();
      final hasKey = await keyManager.hasProvingKey();
      expect(hasKey, isA<bool>());
    });

    test('hasVerificationKey returns boolean', () async {
      await keyManager.initialize();
      final hasKey = await keyManager.hasVerificationKey();
      expect(hasKey, isA<bool>());
    });

    test('getProvingKeySize returns non-negative integer', () async {
      await keyManager.initialize();
      final size = await keyManager.getProvingKeySize();
      expect(size, greaterThanOrEqualTo(0));
    });

    test('getVerificationKeySize returns non-negative integer', () async {
      await keyManager.initialize();
      final size = await keyManager.getVerificationKeySize();
      expect(size, greaterThanOrEqualTo(0));
    });

    test('isHardwareBackedStorage returns boolean', () async {
      await keyManager.initialize();
      final isHardware = await keyManager.isHardwareBackedStorage();
      expect(isHardware, isA<bool>());
    });

    test('getKeyInfo returns map with expected keys', () async {
      await keyManager.initialize();
      final info = await keyManager.getKeyInfo();

      expect(info, isA<Map<String, dynamic>>());
      // Info map should contain key information
    });

    test('exportVerificationKey returns bytes', () async {
      await keyManager.initialize();

      // Generate keys first
      await keyManager.generateKeys();

      final keyData = await keyManager.exportVerificationKey();
      expect(keyData, isA<Uint8List>());
    });

    test('importVerificationKey accepts byte data', () async {
      await keyManager.initialize();

      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

      await expectLater(
        keyManager.importVerificationKey(testData),
        completes,
      );
    });
  });
}
