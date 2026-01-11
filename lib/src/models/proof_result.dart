/// Result of proof verification with detailed information.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'package:json_annotation/json_annotation.dart';
import 'zkp_protocol.dart';

part 'proof_result.g.dart';

/// Result of a Zero-Knowledge Proof verification.
@JsonSerializable()
class ProofResult {
  /// Whether the proof is valid.
  final bool isValid;

  /// The minimum age verified by the proof.
  final int minimumAge;

  /// The protocol used in the proof.
  final ZKPProtocol protocol;

  /// Timestamp when verification was performed.
  final DateTime verifiedAt;

  /// Time taken to verify the proof in milliseconds.
  final int verificationTimeMs;

  /// Optional error message if verification failed.
  final String? errorMessage;

  /// Additional metadata about the verification.
  final Map<String, dynamic>? metadata;

  const ProofResult({
    required this.isValid,
    required this.minimumAge,
    required this.protocol,
    required this.verifiedAt,
    required this.verificationTimeMs,
    this.errorMessage,
    this.metadata,
  });

  /// Creates a ProofResult from JSON.
  factory ProofResult.fromJson(Map<String, dynamic> json) =>
      _$ProofResultFromJson(json);

  /// Converts this ProofResult to JSON.
  Map<String, dynamic> toJson() => _$ProofResultToJson(this);

  /// Creates a successful verification result.
  factory ProofResult.success({
    required int minimumAge,
    required ZKPProtocol protocol,
    required int verificationTimeMs,
    Map<String, dynamic>? metadata,
  }) {
    return ProofResult(
      isValid: true,
      minimumAge: minimumAge,
      protocol: protocol,
      verifiedAt: DateTime.now(),
      verificationTimeMs: verificationTimeMs,
      metadata: metadata,
    );
  }

  /// Creates a failed verification result.
  factory ProofResult.failure({
    required int minimumAge,
    required ZKPProtocol protocol,
    required String errorMessage,
    required int verificationTimeMs,
    Map<String, dynamic>? metadata,
  }) {
    return ProofResult(
      isValid: false,
      minimumAge: minimumAge,
      protocol: protocol,
      verifiedAt: DateTime.now(),
      verificationTimeMs: verificationTimeMs,
      errorMessage: errorMessage,
      metadata: metadata,
    );
  }

  @override
  String toString() {
    return 'ProofResult(isValid: $isValid, minimumAge: $minimumAge, '
        'protocol: ${protocol.name}, time: ${verificationTimeMs}ms)';
  }

  /// Gets a human-readable status message.
  String get statusMessage {
    if (isValid) {
      return 'User verified as $minimumAge or older';
    } else {
      return errorMessage ?? 'Verification failed';
    }
  }
}
