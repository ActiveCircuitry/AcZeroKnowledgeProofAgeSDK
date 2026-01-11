/**
 * Unit tests for ZKP models
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

void main() {
  group('AgeProof', () {
    test('creates AgeProof with valid parameters', () {
      final proof = AgeProof(
        proofData: Uint8List.fromList([1, 2, 3]),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      expect(proof.minimumAge, equals(18));
      expect(proof.protocol, equals(ZKPProtocol.groth16));
      expect(proof.proofSize, equals(3));
    });

    test('isExpired returns correct value', () {
      final expiredProof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      final validProof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      expect(expiredProof.isExpired, isTrue);
      expect(validProof.isExpired, isFalse);
    });

    test('description returns readable string', () {
      final proof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 21,
        protocol: ZKPProtocol.plonk,
        generatedAt: DateTime.now(),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      expect(proof.description, contains('21'));
      expect(proof.description, contains('plonk'));
    });

    test('copyWith creates modified copy', () {
      final original = AgeProof(
        proofData: Uint8List.fromList([1, 2, 3]),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      final modified = original.copyWith(minimumAge: 21);

      expect(modified.minimumAge, equals(21));
      expect(modified.protocol, equals(original.protocol));
      expect(modified.proofId, equals(original.proofId));
    });
  });

  group('ZKPProtocol', () {
    test('groth16 has correct properties', () {
      final protocol = ZKPProtocol.groth16;

      expect(protocol.displayName, equals('Groth16'));
      expect(protocol.typicalProofSize, equals(200));
      expect(protocol.typicalVerificationTime, equals(10));
      expect(protocol.supportsUniversalSetup, isFalse);
    });

    test('plonk has correct properties', () {
      final protocol = ZKPProtocol.plonk;

      expect(protocol.displayName, equals('PLONK'));
      expect(protocol.typicalProofSize, equals(500));
      expect(protocol.typicalVerificationTime, equals(50));
      expect(protocol.supportsUniversalSetup, isTrue);
    });
  });

  group('AgeThreshold', () {
    test('age13 has correct value', () {
      expect(AgeThreshold.age13.age, equals(13));
      expect(AgeThreshold.age13.displayName, equals('13+'));
    });

    test('age18 has correct use case', () {
      expect(AgeThreshold.age18.useCase, contains('adult'));
    });

    test('fromAge returns correct threshold', () {
      expect(AgeThresholdExtension.fromAge(13), equals(AgeThreshold.age13));
      expect(AgeThresholdExtension.fromAge(18), equals(AgeThreshold.age18));
      expect(AgeThresholdExtension.fromAge(21), equals(AgeThreshold.age21));
      expect(AgeThresholdExtension.fromAge(99), isNull);
    });

    test('all returns all thresholds', () {
      final all = AgeThresholdExtension.all;
      expect(all.length, equals(4));
      expect(all.contains(AgeThreshold.age13), isTrue);
      expect(all.contains(AgeThreshold.age18), isTrue);
    });

    test('ageMap contains all thresholds', () {
      final map = AgeThresholdExtension.ageMap;
      expect(map[13], equals(AgeThreshold.age13));
      expect(map[16], equals(AgeThreshold.age16));
      expect(map[18], equals(AgeThreshold.age18));
      expect(map[21], equals(AgeThreshold.age21));
    });
  });

  group('ProofResult', () {
    test('success factory creates valid result', () {
      final result = ProofResult.success(
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        verificationTimeMs: 10,
      );

      expect(result.isValid, isTrue);
      expect(result.minimumAge, equals(18));
      expect(result.errorMessage, isNull);
    });

    test('failure factory creates invalid result', () {
      final result = ProofResult.failure(
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        errorMessage: 'Test error',
        verificationTimeMs: 5,
      );

      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Test error'));
    });

    test('statusMessage returns correct message', () {
      final validResult = ProofResult.success(
        minimumAge: 21,
        protocol: ZKPProtocol.plonk,
        verificationTimeMs: 50,
      );

      final invalidResult = ProofResult.failure(
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        errorMessage: 'Invalid proof',
        verificationTimeMs: 5,
      );

      expect(validResult.statusMessage, contains('21'));
      expect(invalidResult.statusMessage, contains('Invalid'));
    });
  });

  group('ZkpException', () {
    test('creates exception with message', () {
      final exception = ZkpException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('Test error'));
    });

    test('creates exception with code', () {
      final exception = ZkpException('Test error', code: 'TEST_CODE');
      expect(exception.code, equals('TEST_CODE'));
      expect(exception.toString(), contains('TEST_CODE'));
    });

    test('specialized exceptions extend ZkpException', () {
      expect(KeyManagementException('test'), isA<ZkpException>());
      expect(ProofGenerationException('test'), isA<ZkpException>());
      expect(ProofVerificationException('test'), isA<ZkpException>());
      expect(PlatformException('test'), isA<ZkpException>());
    });
  });
}
