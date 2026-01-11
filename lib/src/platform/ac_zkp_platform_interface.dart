/// Platform interface for Active Circuitry ZKP SDK.
///
/// This defines the interface that platform-specific implementations must follow.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:async';
import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/age_proof.dart';
import '../models/zkp_protocol.dart';
import '../models/proof_result.dart';
import 'ac_zkp_method_channel.dart';

/// Platform interface for ZKP operations.
abstract class AcZkpPlatformInterface extends PlatformInterface {
  AcZkpPlatformInterface() : super(token: _token);

  static final Object _token = Object();
  static AcZkpPlatformInterface _instance = MethodChannelAcZkp();

  /// The default instance of [AcZkpPlatformInterface] to use.
  static AcZkpPlatformInterface get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AcZkpPlatformInterface].
  static set instance(AcZkpPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Generates a Zero-Knowledge Proof for age verification.
  Future<AgeProof> generateAgeProof({
    required DateTime birthDate,
    required int minimumAge,
    required ZKPProtocol protocol,
    required bool useHardwareSecurity,
  }) {
    throw UnimplementedError('generateAgeProof() has not been implemented.');
  }

  /// Verifies a Zero-Knowledge Proof.
  Future<ProofResult> verifyAgeProof(AgeProof proof) {
    throw UnimplementedError('verifyAgeProof() has not been implemented.');
  }

  /// Validates proof structure without cryptographic verification.
  Future<bool> validateProofStructure(AgeProof proof) {
    throw UnimplementedError('validateProofStructure() has not been implemented.');
  }

  /// Estimates proof generation time for a protocol.
  Future<int> estimateProofTime(ZKPProtocol protocol) {
    throw UnimplementedError('estimateProofTime() has not been implemented.');
  }

  /// Estimates verification time for a protocol.
  Future<int> estimateVerificationTime(ZKPProtocol protocol) {
    throw UnimplementedError('estimateVerificationTime() has not been implemented.');
  }

  /// Checks if hardware security is available.
  Future<bool> isHardwareSecurityAvailable() {
    throw UnimplementedError('isHardwareSecurityAvailable() has not been implemented.');
  }

  /// Gets proof generation progress stream.
  Stream<double> getProofGenerationProgress() {
    throw UnimplementedError('getProofGenerationProgress() has not been implemented.');
  }

  // Key management methods
  
  /// Initializes cryptographic keys.
  Future<void> initializeKeys() {
    throw UnimplementedError('initializeKeys() has not been implemented.');
  }

  /// Checks if proving key is available.
  Future<bool> hasProvingKey() {
    throw UnimplementedError('hasProvingKey() has not been implemented.');
  }

  /// Checks if verification key is available.
  Future<bool> hasVerificationKey() {
    throw UnimplementedError('hasVerificationKey() has not been implemented.');
  }

  /// Downloads proving key.
  Future<void> downloadProvingKey({
    String? url,
    void Function(double progress)? onProgress,
  }) {
    throw UnimplementedError('downloadProvingKey() has not been implemented.');
  }

  /// Downloads verification key.
  Future<void> downloadVerificationKey({
    String? url,
    void Function(double progress)? onProgress,
  }) {
    throw UnimplementedError('downloadVerificationKey() has not been implemented.');
  }

  /// Generates new keys.
  Future<void> generateKeys() {
    throw UnimplementedError('generateKeys() has not been implemented.');
  }

  /// Deletes all keys.
  Future<void> deleteKeys() {
    throw UnimplementedError('deleteKeys() has not been implemented.');
  }

  /// Gets proving key size in bytes.
  Future<int> getProvingKeySize() {
    throw UnimplementedError('getProvingKeySize() has not been implemented.');
  }

  /// Gets verification key size in bytes.
  Future<int> getVerificationKeySize() {
    throw UnimplementedError('getVerificationKeySize() has not been implemented.');
  }

  /// Checks if hardware-backed storage is available.
  Future<bool> isHardwareBackedStorage() {
    throw UnimplementedError('isHardwareBackedStorage() has not been implemented.');
  }

  /// Exports verification key.
  Future<Uint8List> exportVerificationKey() {
    throw UnimplementedError('exportVerificationKey() has not been implemented.');
  }

  /// Imports verification key.
  Future<void> importVerificationKey(Uint8List keyData) {
    throw UnimplementedError('importVerificationKey() has not been implemented.');
  }

  /// Gets key information.
  Future<Map<String, dynamic>> getKeyInfo() {
    throw UnimplementedError('getKeyInfo() has not been implemented.');
  }
}
