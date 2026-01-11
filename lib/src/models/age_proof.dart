/// Age proof model representing a Zero-Knowledge Proof.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:typed_data';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'zkp_protocol.dart';

part 'age_proof.g.dart';

/// Represents a Zero-Knowledge Proof for age verification.
///
/// This proof can be verified to confirm that a user meets a minimum
/// age requirement without revealing their actual age or birth date.
@JsonSerializable()
class AgeProof {
  /// The cryptographic proof data.
  final Uint8List proofData;

  /// The minimum age this proof verifies (e.g., 18 for 18+).
  final int minimumAge;

  /// The ZKP protocol used to generate this proof.
  final ZKPProtocol protocol;

  /// Timestamp when the proof was generated.
  final DateTime generatedAt;

  /// Optional expiration time for the proof.
  /// After this time, the proof should be considered invalid.
  final DateTime? expiresAt;

  /// Public inputs used in the proof (safe to reveal).
  final Map<String, dynamic>? publicInputs;

  /// Unique identifier for this proof.
  final String proofId;

  /// Version of the SDK that generated this proof.
  final String sdkVersion;

  const AgeProof({
    required this.proofData,
    required this.minimumAge,
    required this.protocol,
    required this.generatedAt,
    required this.proofId,
    required this.sdkVersion,
    this.expiresAt,
    this.publicInputs,
  });

  /// Creates an AgeProof from JSON.
  factory AgeProof.fromJson(Map<String, dynamic> json) =>
      _$AgeProofFromJson(json);

  /// Converts this AgeProof to JSON.
  Map<String, dynamic> toJson() => _$AgeProofToJson(this);

  /// Gets the size of the proof in bytes.
  int get proofSize => proofData.length;

  /// Checks if this proof has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Gets a human-readable description of this proof.
  String get description {
    return 'Age ${minimumAge}+ proof (${protocol.name})';
  }

  @override
  String toString() {
    return 'AgeProof(minimumAge: $minimumAge, protocol: ${protocol.name}, '
        'generated: $generatedAt, size: ${proofSize} bytes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgeProof &&
        other.proofId == proofId &&
        other.minimumAge == minimumAge &&
        other.protocol == protocol;
  }

  @override
  int get hashCode => proofId.hashCode;

  /// Creates a copy of this proof with modified fields.
  AgeProof copyWith({
    Uint8List? proofData,
    int? minimumAge,
    ZKPProtocol? protocol,
    DateTime? generatedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? publicInputs,
    String? proofId,
    String? sdkVersion,
  }) {
    return AgeProof(
      proofData: proofData ?? this.proofData,
      minimumAge: minimumAge ?? this.minimumAge,
      protocol: protocol ?? this.protocol,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      publicInputs: publicInputs ?? this.publicInputs,
      proofId: proofId ?? this.proofId,
      sdkVersion: sdkVersion ?? this.sdkVersion,
    );
  }
}
