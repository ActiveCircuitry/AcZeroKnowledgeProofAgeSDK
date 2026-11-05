/// Age proof generator for creating Zero-Knowledge Proofs.
///
/// This class handles the generation of cryptographic proofs that verify
/// a user's age meets a minimum threshold without revealing the actual age.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:async';
import 'package:flutter/services.dart' as services;
import 'models/age_proof.dart';
import 'models/zkp_protocol.dart';
import 'models/age_threshold.dart';
import 'exceptions/zkp_exception.dart';
import 'platform/ac_zkp_platform_interface.dart';

/// Generates Zero-Knowledge Proofs for age verification.
///
/// Example:
/// ```dart
/// final generator = AgeProofGenerator();
/// final proof = await generator.generateAgeProof(
///   birthDate: DateTime(1990, 1, 1),
///   minimumAge: 18,
/// );
/// ```
class AgeProofGenerator {
  final AcZkpPlatformInterface _platform = AcZkpPlatformInterface.instance;

  /// Generates a Zero-Knowledge Proof for age verification.
  ///
  /// [birthDate]: The user's birth date (not revealed in the proof)
  /// [minimumAge]: The minimum age to prove (e.g., 18 for 18+)
  /// [protocol]: The ZKP protocol to use (default: Groth16)
  /// [useHardwareSecurity]: Whether to use Android TEE/KeyStore (default: true)
  ///
  /// Returns an [AgeProof] that can be verified without revealing the birth date.
  ///
  /// Throws [ZkpException] if proof generation fails.
  Future<AgeProof> generateAgeProof({
    required DateTime birthDate,
    required int minimumAge,
    ZKPProtocol protocol = ZKPProtocol.groth16,
    bool useHardwareSecurity = true,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    // Validate inputs
    _validateInputs(birthDate, minimumAge);

    int attemptCount = 0;
    Exception? lastException;

    while (attemptCount < maxRetries) {
      try {
        attemptCount++;

        // Call platform-specific implementation
        final result = await _platform.generateAgeProof(
          birthDate: birthDate,
          minimumAge: minimumAge,
          protocol: protocol,
          useHardwareSecurity: useHardwareSecurity,
        );

        return result;
      } on ProofGenerationException catch (e) {
        if (e.code == 'CRYPTO_BACKEND_UNAVAILABLE') rethrow;
        lastException = e;
        if (attemptCount >= maxRetries) {
          throw ProofGenerationException(
            'Failed to generate proof after $maxRetries attempts: ${e.message}',
            code: 'MAX_RETRIES_EXCEEDED',
            cause: e,
          );
        }
        // Wait before retry
        await Future.delayed(retryDelay * attemptCount);
      } on services.PlatformException catch (e) {
        if (e.code == 'CRYPTO_BACKEND_UNAVAILABLE') {
          throw ProofGenerationException(
            'Cryptographic backend is unavailable: ${e.message}',
            code: e.code,
            cause: e,
          );
        }
        lastException = e;
        if (attemptCount >= maxRetries) break;
        await Future.delayed(retryDelay * attemptCount);
      } catch (e) {
        lastException = Exception(e.toString());
        if (attemptCount >= maxRetries) break;
        await Future.delayed(retryDelay * attemptCount);
      }
    }

    throw ProofGenerationException(
      'Failed to generate age proof after $maxRetries attempts',
      code: 'GENERATION_FAILED',
      cause: lastException,
    );
  }

  void _validateInputs(DateTime birthDate, int minimumAge) {
    final now = DateTime.now();

    if (birthDate.isAfter(now)) {
      throw ProofGenerationException(
        'Birth date cannot be in the future',
        code: 'INVALID_BIRTH_DATE',
      );
    }

    if (birthDate.year < 1900) {
      throw ProofGenerationException(
        'Birth date must be after year 1900',
        code: 'INVALID_BIRTH_DATE',
      );
    }

    if (minimumAge < 0) {
      throw ProofGenerationException(
        'Minimum age cannot be negative',
        code: 'INVALID_AGE',
      );
    }

    if (minimumAge > 150) {
      throw ProofGenerationException(
        'Minimum age cannot exceed 150 years',
        code: 'INVALID_AGE',
      );
    }
  }

  /// Generates a proof for a predefined age threshold.
  ///
  /// Convenience method for common age thresholds (13+, 16+, 18+, 21+).
  Future<AgeProof> generateAgeProofForThreshold({
    required DateTime birthDate,
    required AgeThreshold threshold,
    ZKPProtocol protocol = ZKPProtocol.groth16,
  }) async {
    return generateAgeProof(
      birthDate: birthDate,
      minimumAge: threshold.age,
      protocol: protocol,
    );
  }

  /// Generates multiple proofs for different age thresholds in batch.
  ///
  /// More efficient than generating proofs individually.
  Future<List<AgeProof>> generateBatchProofs({
    required DateTime birthDate,
    required List<int> minimumAges,
    ZKPProtocol protocol = ZKPProtocol.groth16,
  }) async {
    final proofs = <AgeProof>[];

    for (final age in minimumAges) {
      final proof = await generateAgeProof(
        birthDate: birthDate,
        minimumAge: age,
        protocol: protocol,
      );
      proofs.add(proof);
    }

    return proofs;
  }

  /// Estimates the time required to generate a proof.
  ///
  /// Returns estimated duration in milliseconds.
  Future<int> estimateProofGenerationTime({
    required ZKPProtocol protocol,
  }) async {
    try {
      return await _platform.estimateProofTime(protocol);
    } catch (e) {
      throw ZkpException('Failed to estimate proof time: $e');
    }
  }

  /// Checks if hardware security features are available.
  Future<bool> isHardwareSecurityAvailable() async {
    try {
      return await _platform.isHardwareSecurityAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Stream of proof generation progress (0.0 to 1.0).
  ///
  /// Useful for showing progress indicators during long operations.
  Stream<double> getProofGenerationProgress() {
    return _platform.getProofGenerationProgress();
  }
}
