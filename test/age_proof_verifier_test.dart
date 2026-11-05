/**
 * Unit tests for AgeProofVerifier
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'dart:typed_data';
import 'package:flutter/services.dart' as services;
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
import 'support/fake_ac_zkp_platform.dart';

void main() {
  group('AgeProofVerifier', () {
    late AgeProofVerifier verifier;
    late AgeProofGenerator generator;
    late AcZkpPlatformInterface originalPlatform;

    setUp(() {
      originalPlatform = AcZkpPlatformInterface.instance;
      installFakeAcZkpPlatform();
      verifier = AgeProofVerifier();
      generator = AgeProofGenerator();
    });

    tearDown(() {
      AcZkpPlatformInterface.instance = originalPlatform;
    });

    test('verifyAgeProof validates correct proof', () async {
      final birthDate = DateTime(1990, 1, 1);
      final minimumAge = 18;

      final proof = await generator.generateAgeProof(
        birthDate: birthDate,
        minimumAge: minimumAge,
      );

      final isValid = await verifier.verifyAgeProof(proof);
      expect(isValid, isTrue);
    });

    test('verifyAgeProofDetailed returns detailed result', () async {
      final birthDate = DateTime(1990, 1, 1);
      final minimumAge = 21;

      final proof = await generator.generateAgeProof(
        birthDate: birthDate,
        minimumAge: minimumAge,
      );

      final result = await verifier.verifyAgeProofDetailed(proof);

      expect(result.isValid, isTrue);
      expect(result.minimumAge, equals(minimumAge));
      expect(result.verificationTimeMs, greaterThan(0));
    });

    test('verifyAgeProofDetailed rejects an expired proof before platform call',
        () async {
      final expiredProof = AgeProof(
        proofData: Uint8List.fromList([1]),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now().subtract(const Duration(days: 2)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        proofId: 'expired-proof',
        sdkVersion: 'test',
      );

      await expectLater(
        verifier.verifyAgeProofDetailed(expiredProof),
        throwsA(
          isA<ProofVerificationException>().having(
            (error) => error.code,
            'code',
            'PROOF_EXPIRED',
          ),
        ),
      );
    });

    test('verifyAgeProofDetailed rejects an empty proof', () async {
      final emptyProof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        proofId: 'empty-proof',
        sdkVersion: 'test',
      );

      await expectLater(
        verifier.verifyAgeProofDetailed(emptyProof),
        throwsA(
          isA<ProofVerificationException>().having(
            (error) => error.code,
            'code',
            'EMPTY_PROOF',
          ),
        ),
      );
    });

    test('backend unavailable is propagated without retries', () async {
      final fakePlatform = FakeAcZkpPlatform()
        ..verificationFailure = services.PlatformException(
          code: 'CRYPTO_BACKEND_UNAVAILABLE',
          message: 'No cryptographic backend is configured.',
        );
      AcZkpPlatformInterface.instance = fakePlatform;
      verifier = AgeProofVerifier();
      final proof = AgeProof(
        proofData: Uint8List.fromList([1]),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        proofId: 'test-proof',
        sdkVersion: 'test',
      );

      await expectLater(
        verifier.verifyAgeProof(proof),
        throwsA(
          isA<ProofVerificationException>().having(
            (error) => error.code,
            'code',
            'CRYPTO_BACKEND_UNAVAILABLE',
          ),
        ),
      );
    });

    test('verifyBatchProofs verifies multiple proofs', () async {
      final birthDate = DateTime(1990, 1, 1);

      final proofs = await generator.generateBatchProofs(
        birthDate: birthDate,
        minimumAges: [13, 18, 21],
      );

      final results = await verifier.verifyBatchProofs(proofs);

      expect(results.length, equals(proofs.length));
      expect(results.every((r) => r == true), isTrue);
    });

    test('isProofExpired detects expired proofs', () {
      final expiredProof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      expect(verifier.isProofExpired(expiredProof), isTrue);
    });

    test('isProofExpired returns false for valid proofs', () {
      final validProof = AgeProof(
        proofData: Uint8List(0),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        proofId: 'test-id',
        sdkVersion: '0.1.0',
      );

      expect(verifier.isProofExpired(validProof), isFalse);
    });

    test('getProofMetadata extracts public information', () async {
      final birthDate = DateTime(1990, 1, 1);
      final proof = await generator.generateAgeProof(
        birthDate: birthDate,
        minimumAge: 18,
      );

      final metadata = await verifier.getProofMetadata(proof);

      expect(metadata['minimumAge'], equals(18));
      expect(metadata['protocol'], equals('groth16'));
      expect(metadata['proofSize'], greaterThan(0));
      expect(metadata.containsKey('generatedAt'), isTrue);
    });

    test('estimateVerificationTime returns reasonable value', () async {
      final proof = await generator.generateAgeProof(
        birthDate: DateTime(1990, 1, 1),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
      );

      final time = await verifier.estimateVerificationTime(proof);

      expect(time, greaterThan(0));
      expect(time, lessThan(1000)); // Less than 1 second
    });
  });
}
