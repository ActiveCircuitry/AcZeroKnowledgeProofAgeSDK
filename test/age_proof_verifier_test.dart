/**
 * Unit tests for AgeProofVerifier
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

void main() {
  group('AgeProofVerifier', () {
    late AgeProofVerifier verifier;
    late AgeProofGenerator generator;

    setUp(() {
      verifier = AgeProofVerifier();
      generator = AgeProofGenerator();
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
