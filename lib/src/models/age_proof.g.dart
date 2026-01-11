// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'age_proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgeProof _$AgeProofFromJson(Map<String, dynamic> json) => AgeProof(
      proofData: _uint8ListFromJson(json['proofData']),
      minimumAge: json['minimumAge'] as int,
      protocol: $enumDecode(_$ZKPProtocolEnumMap, json['protocol']),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      proofId: json['proofId'] as String,
      sdkVersion: json['sdkVersion'] as String,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      publicInputs: json['publicInputs'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AgeProofToJson(AgeProof instance) => <String, dynamic>{
      'proofData': _uint8ListToJson(instance.proofData),
      'minimumAge': instance.minimumAge,
      'protocol': _$ZKPProtocolEnumMap[instance.protocol]!,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'publicInputs': instance.publicInputs,
      'proofId': instance.proofId,
      'sdkVersion': instance.sdkVersion,
    };

const _$ZKPProtocolEnumMap = {
  ZKPProtocol.groth16: 'groth16',
  ZKPProtocol.plonk: 'plonk',
};

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

// Custom converters for Uint8List
Uint8List _uint8ListFromJson(dynamic json) {
  if (json is List) {
    return Uint8List.fromList(List<int>.from(json));
  } else if (json is String) {
    return Uint8List.fromList(base64.decode(json));
  }
  return Uint8List(0);
}

dynamic _uint8ListToJson(Uint8List data) {
  return data.toList();
}
