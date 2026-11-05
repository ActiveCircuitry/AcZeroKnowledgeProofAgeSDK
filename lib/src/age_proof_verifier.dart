/// Age proof verifier for validating Zero-Knowledge Proofs.
///
/// This class handles the verification of cryptographic proofs that confirm
/// a user's age meets a minimum threshold without revealing the actual age.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:async';
import 'package:flutter/services.dart' as services;
import 'models/age_proof.dart';
import 'models/proof_result.dart';
import 'exceptions/zkp_exception.dart';
import 'platform/ac_zkp_platform_interface.dart';

/// Verifies Zero-Knowledge Proofs for age verification.
///
/// Example:
/// ```dart
/// final verifier = AgeProofVerifier();
/// final isValid = await verifier.verifyAgeProof(proof);
/// ```
class AgeProofVerifier {
  final AcZkpPlatformInterface _platform = AcZkpPlatformInterface.instance;

  /// Verifies a Zero-Knowledge Proof for age verification.
  ///
  /// [proof]: The proof to verify
  ///
  /// Returns `true` if the proof is valid and the user meets the age requirement.
  /// Returns `false` if the proof is invalid or the user doesn't meet the requirement.
  ///
  /// Throws [ZkpException] if verification fails due to technical errors.
  Future<bool> verifyAgeProof(
    AgeProof proof, {
    int maxRetries = 2,
  }) async {
    // Pre-validation
    _validateProof(proof);

    int attemptCount = 0;
    Exception? lastException;

    while (attemptCount < maxRetries) {
      try {
        attemptCount++;
        final result = await _platform.verifyAgeProof(proof);
        return result.isValid;
      } on ProofVerificationException catch (e) {
        if (e.code == 'CRYPTO_BACKEND_UNAVAILABLE') rethrow;
        lastException = e;
        if (attemptCount >= maxRetries) {
          throw ProofVerificationException(
            'Failed to verify proof after $maxRetries attempts: ${e.message}',
            code: 'VERIFICATION_MAX_RETRIES',
            cause: e,
          );
        }
        await Future.delayed(Duration(milliseconds: 500 * attemptCount));
      } on services.PlatformException catch (e) {
        if (e.code == 'CRYPTO_BACKEND_UNAVAILABLE') {
          throw ProofVerificationException(
            'Cryptographic backend is unavailable: ${e.message}',
            code: e.code,
            cause: e,
          );
        }
        lastException = e;
        if (attemptCount >= maxRetries) break;
        await Future.delayed(Duration(milliseconds: 500 * attemptCount));
      } catch (e) {
        lastException = Exception(e.toString());
        if (attemptCount >= maxRetries) break;
        await Future.delayed(Duration(milliseconds: 500 * attemptCount));
      }
    }

    throw ProofVerificationException(
      'Failed to verify age proof after $maxRetries attempts',
      code: 'VERIFICATION_FAILED',
      cause: lastException,
    );
  }

  void _validateProof(AgeProof proof) {
    if (proof.proofData.isEmpty) {
      throw ProofVerificationException(
        'Proof data is empty',
        code: 'EMPTY_PROOF',
      );
    }

    if (proof.minimumAge < 0 || proof.minimumAge > 150) {
      throw ProofVerificationException(
        'Invalid minimum age in proof: ${proof.minimumAge}',
        code: 'INVALID_AGE',
      );
    }

    if (isProofExpired(proof)) {
      throw ProofVerificationException(
        'Proof has expired',
        code: 'PROOF_EXPIRED',
      );
    }
  }

  /// Verifies a proof and returns detailed result information.
  ///
  /// Returns a [ProofResult] containing validity, protocol info, and metadata.
  Future<ProofResult> verifyAgeProofDetailed(AgeProof proof) async {
    _validateProof(proof);
    try {
      return await _platform.verifyAgeProof(proof);
    } on services.PlatformException catch (e) {
      if (e.code == 'CRYPTO_BACKEND_UNAVAILABLE') {
        throw ProofVerificationException(
          'Cryptographic backend is unavailable: ${e.message}',
          code: e.code,
          cause: e,
        );
      }
      throw ZkpException(
        'Failed to verify age proof: $e',
        code: e.code,
        cause: e,
      );
    } catch (e) {
      throw ZkpException('Failed to verify age proof: $e');
    }
  }

  /// Verifies multiple proofs in batch.
  ///
  /// More efficient than verifying proofs individually.
  /// Returns a list of verification results in the same order as input.
  Future<List<bool>> verifyBatchProofs(List<AgeProof> proofs) async {
    final results = <bool>[];

    for (final proof in proofs) {
      final isValid = await verifyAgeProof(proof);
      results.add(isValid);
    }

    return results;
  }

  /// Checks if a proof has expired.
  ///
  /// Proofs may have a validity period to prevent replay attacks.
  bool isProofExpired(AgeProof proof) {
    if (proof.expiresAt == null) return false;
    return DateTime.now().isAfter(proof.expiresAt!);
  }

  /// Validates the structure and format of a proof without cryptographic verification.
  ///
  /// Useful for quick pre-checks before expensive cryptographic operations.
  Future<bool> validateProofStructure(AgeProof proof) async {
    try {
      // Check basic structure
      if (proof.proofData.isEmpty) return false;
      if (proof.minimumAge < 0 || proof.minimumAge > 150) return false;
      if (isProofExpired(proof)) return false;

      // Platform-specific validation
      return await _platform.validateProofStructure(proof);
    } catch (e) {
      return false;
    }
  }

  /// Extracts public information from a proof without verification.
  ///
  /// Returns information that can be safely revealed:
  /// - Minimum age threshold
  /// - Protocol used
  /// - Generation timestamp
  /// - Expiration time
  Future<Map<String, dynamic>> getProofMetadata(AgeProof proof) async {
    return {
      'minimumAge': proof.minimumAge,
      'protocol': proof.protocol.name,
      'generatedAt': proof.generatedAt.toIso8601String(),
      'expiresAt': proof.expiresAt?.toIso8601String(),
      'proofSize': proof.proofData.length,
      'isExpired': isProofExpired(proof),
    };
  }

  /// Estimates the time required to verify a proof.
  ///
  /// Returns estimated duration in milliseconds.
  /// Verification is typically much faster than generation.
  Future<int> estimateVerificationTime(AgeProof proof) async {
    try {
      return await _platform.estimateVerificationTime(proof.protocol);
    } catch (e) {
      throw ZkpException('Failed to estimate verification time: $e');
    }
  }
}
