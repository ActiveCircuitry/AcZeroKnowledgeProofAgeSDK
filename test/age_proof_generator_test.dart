/**
 * Unit tests for AgeProofGenerator
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' as services;
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
import 'support/fake_ac_zkp_platform.dart';

void main() {
  group('AgeProofGenerator', () {
    late AgeProofGenerator generator;
    late AcZkpPlatformInterface originalPlatform;

    setUp(() {
      originalPlatform = AcZkpPlatformInterface.instance;
      installFakeAcZkpPlatform();
      generator = AgeProofGenerator();
    });

    tearDown(() {
      AcZkpPlatformInterface.instance = originalPlatform;
    });

    test('generateAgeProof creates valid proof for valid birth date', () async {
      final birthDate = DateTime(1990, 1, 1);
      final minimumAge = 18;

      final proof = await generator.generateAgeProof(
        birthDate: birthDate,
        minimumAge: minimumAge,
      );

      expect(proof, isNotNull);
      expect(proof.minimumAge, equals(minimumAge));
      expect(proof.proofData.isNotEmpty, isTrue);
      expect(proof.protocol, equals(ZKPProtocol.groth16));
    });

    test('generateAgeProof with PLONK protocol', () async {
      final birthDate = DateTime(1990, 1, 1);
      final minimumAge = 21;

      final proof = await generator.generateAgeProof(
        birthDate: birthDate,
        minimumAge: minimumAge,
        protocol: ZKPProtocol.plonk,
      );

      expect(proof.protocol, equals(ZKPProtocol.plonk));
      expect(proof.minimumAge, equals(minimumAge));
    });

    test('generateAgeProofForThreshold uses correct age', () async {
      final birthDate = DateTime(1990, 1, 1);

      final proof = await generator.generateAgeProofForThreshold(
        birthDate: birthDate,
        threshold: AgeThreshold.age18,
      );

      expect(proof.minimumAge, equals(18));
    });

    test('generateBatchProofs creates multiple proofs', () async {
      final birthDate = DateTime(1990, 1, 1);
      final ages = [13, 16, 18, 21];

      final proofs = await generator.generateBatchProofs(
        birthDate: birthDate,
        minimumAges: ages,
      );

      expect(proofs.length, equals(ages.length));
      for (var i = 0; i < proofs.length; i++) {
        expect(proofs[i].minimumAge, equals(ages[i]));
      }
    });

    test('generateAgeProof throws on invalid age', () async {
      final birthDate = DateTime(1990, 1, 1);

      expect(
        () => generator.generateAgeProof(
          birthDate: birthDate,
          minimumAge: -1,
        ),
        throwsA(isA<ZkpException>()),
      );

      expect(
        () => generator.generateAgeProof(
          birthDate: birthDate,
          minimumAge: 200,
        ),
        throwsA(isA<ZkpException>()),
      );
    });

    test('backend unavailable is propagated without retries', () async {
      final fakePlatform = FakeAcZkpPlatform()
        ..generationFailure = services.PlatformException(
          code: 'CRYPTO_BACKEND_UNAVAILABLE',
          message: 'No cryptographic backend is configured.',
        );
      AcZkpPlatformInterface.instance = fakePlatform;
      generator = AgeProofGenerator();

      await expectLater(
        generator.generateAgeProof(
          birthDate: DateTime(1990, 1, 1),
          minimumAge: 18,
        ),
        throwsA(
          isA<ProofGenerationException>().having(
            (error) => error.code,
            'code',
            'CRYPTO_BACKEND_UNAVAILABLE',
          ),
        ),
      );
    });

    test('estimateProofGenerationTime returns reasonable value', () async {
      final time = await generator.estimateProofGenerationTime(
        protocol: ZKPProtocol.groth16,
      );

      expect(time, greaterThan(0));
      expect(time, lessThan(60000)); // Less than 1 minute
    });
  });
}
