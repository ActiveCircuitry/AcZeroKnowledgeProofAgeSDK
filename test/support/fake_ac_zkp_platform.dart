import 'dart:typed_data';

import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

class FakeAcZkpPlatform extends AcZkpPlatformInterface {
  bool provingKeyAvailable = false;
  bool verificationKeyAvailable = false;
  Uint8List verificationKey = Uint8List(0);
  Object? generationFailure;
  Object? verificationFailure;
  Object? keyInitializationFailure;

  @override
  Future<AgeProof> generateAgeProof({
    required DateTime birthDate,
    required int minimumAge,
    required ZKPProtocol protocol,
    required bool useHardwareSecurity,
  }) async {
    if (generationFailure != null) throw generationFailure!;
    return AgeProof(
      proofData: Uint8List.fromList([1, 2, 3]),
      minimumAge: minimumAge,
      protocol: protocol,
      generatedAt: DateTime.now(),
      proofId: 'test-proof',
      sdkVersion: 'test',
    );
  }

  @override
  Future<ProofResult> verifyAgeProof(AgeProof proof) async {
    if (verificationFailure != null) throw verificationFailure!;
    return ProofResult.success(
      minimumAge: proof.minimumAge,
      protocol: proof.protocol,
      verificationTimeMs: 1,
    );
  }

  @override
  Future<bool> validateProofStructure(AgeProof proof) async {
    return proof.proofData.isNotEmpty;
  }

  @override
  Future<int> estimateProofTime(ZKPProtocol protocol) async {
    return protocol.typicalGenerationTime;
  }

  @override
  Future<int> estimateVerificationTime(ZKPProtocol protocol) async {
    return protocol.typicalVerificationTime;
  }

  @override
  Future<bool> isHardwareSecurityAvailable() async => true;

  @override
  Future<void> initializeKeys() async {
    if (keyInitializationFailure != null) throw keyInitializationFailure!;
  }

  @override
  Future<bool> hasProvingKey() async => provingKeyAvailable;

  @override
  Future<bool> hasVerificationKey() async => verificationKeyAvailable;

  @override
  Future<void> generateKeys() async {
    provingKeyAvailable = true;
    verificationKeyAvailable = true;
    verificationKey = Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<int> getProvingKeySize() async => provingKeyAvailable ? 3 : 0;

  @override
  Future<int> getVerificationKeySize() async =>
      verificationKeyAvailable ? verificationKey.length : 0;

  @override
  Future<bool> isHardwareBackedStorage() async => true;

  @override
  Future<Uint8List> exportVerificationKey() async => verificationKey;

  @override
  Future<void> importVerificationKey(Uint8List keyData) async {
    verificationKey = keyData;
    verificationKeyAvailable = keyData.isNotEmpty;
  }

  @override
  Future<Map<String, dynamic>> getKeyInfo() async => {
        'hasProvingKey': provingKeyAvailable,
        'hasVerificationKey': verificationKeyAvailable,
      };
}

void installFakeAcZkpPlatform() {
  AcZkpPlatformInterface.instance = FakeAcZkpPlatform();
}
