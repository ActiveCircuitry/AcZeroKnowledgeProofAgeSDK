// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProofResult _$ProofResultFromJson(Map<String, dynamic> json) => ProofResult(
      isValid: json['isValid'] as bool,
      minimumAge: (json['minimumAge'] as num).toInt(),
      protocol: $enumDecode(_$ZKPProtocolEnumMap, json['protocol']),
      verifiedAt: DateTime.parse(json['verifiedAt'] as String),
      verificationTimeMs: (json['verificationTimeMs'] as num).toInt(),
      errorMessage: json['errorMessage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ProofResultToJson(ProofResult instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'minimumAge': instance.minimumAge,
      'protocol': _$ZKPProtocolEnumMap[instance.protocol]!,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
      'verificationTimeMs': instance.verificationTimeMs,
      'errorMessage': instance.errorMessage,
      'metadata': instance.metadata,
    };

const _$ZKPProtocolEnumMap = {
  ZKPProtocol.groth16: 'groth16',
  ZKPProtocol.plonk: 'plonk',
};
