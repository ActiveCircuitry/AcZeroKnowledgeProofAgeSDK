/// Method channel implementation for Active Circuitry ZKP SDK.
///
/// Handles communication between Dart and native Android code.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/age_proof.dart';
import '../models/zkp_protocol.dart';
import '../models/proof_result.dart';
import 'ac_zkp_platform_interface.dart';

/// Method channel implementation of [AcZkpPlatformInterface].
class MethodChannelAcZkp extends AcZkpPlatformInterface {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ac_zero_knowledge_proof_age_sdk');

  /// Event channel for proof generation progress.
  @visibleForTesting
  final eventChannel = const EventChannel('ac_zero_knowledge_proof_age_sdk/progress');

  @override
  Future<AgeProof> generateAgeProof({
    required DateTime birthDate,
    required int minimumAge,
    required ZKPProtocol protocol,
    required bool useHardwareSecurity,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'generateAgeProof',
        {
          'birthDate': birthDate.toIso8601String(),
          'minimumAge': minimumAge,
          'protocol': protocol.name,
          'useHardwareSecurity': useHardwareSecurity,
        },
      );

      if (result == null) {
        throw PlatformException(code: 'NULL_RESULT', message: 'Platform returned null result');
      }

      return AgeProof.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to generate age proof: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<ProofResult> verifyAgeProof(AgeProof proof) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'verifyAgeProof',
        {
          'proofData': proof.proofData,
          'minimumAge': proof.minimumAge,
          'protocol': proof.protocol.name,
          'proofId': proof.proofId,
        },
      );

      if (result == null) {
        throw PlatformException(code: 'NULL_RESULT', message: 'Platform returned null result');
      }

      return ProofResult.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw PlatformException(
        code: e.code,
        message: 'Failed to verify age proof: ${e.message}',
        details: e.details,
      );
    }
  }

  @override
  Future<bool> validateProofStructure(AgeProof proof) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(
        'validateProofStructure',
        {
          'proofData': proof.proofData,
          'minimumAge': proof.minimumAge,
          'protocol': proof.protocol.name,
        },
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> estimateProofTime(ZKPProtocol protocol) async {
    try {
      final result = await methodChannel.invokeMethod<int>(
        'estimateProofTime',
        {'protocol': protocol.name},
      );
      return result ?? protocol.typicalGenerationTime;
    } catch (e) {
      return protocol.typicalGenerationTime;
    }
  }

  @override
  Future<int> estimateVerificationTime(ZKPProtocol protocol) async {
    try {
      final result = await methodChannel.invokeMethod<int>(
        'estimateVerificationTime',
        {'protocol': protocol.name},
      );
      return result ?? protocol.typicalVerificationTime;
    } catch (e) {
      return protocol.typicalVerificationTime;
    }
  }

  @override
  Future<bool> isHardwareSecurityAvailable() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isHardwareSecurityAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<double> getProofGenerationProgress() {
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is double) return event;
      if (event is int) return event.toDouble();
      return 0.0;
    });
  }

  // Key management implementations

  @override
  Future<void> initializeKeys() async {
    await methodChannel.invokeMethod('initializeKeys');
  }

  @override
  Future<bool> hasProvingKey() async {
    final result = await methodChannel.invokeMethod<bool>('hasProvingKey');
    return result ?? false;
  }

  @override
  Future<bool> hasVerificationKey() async {
    final result = await methodChannel.invokeMethod<bool>('hasVerificationKey');
    return result ?? false;
  }

  @override
  Future<void> downloadProvingKey({
    String? url,
    void Function(double progress)? onProgress,
  }) async {
    await methodChannel.invokeMethod('downloadProvingKey', {'url': url});
  }

  @override
  Future<void> downloadVerificationKey({
    String? url,
    void Function(double progress)? onProgress,
  }) async {
    await methodChannel.invokeMethod('downloadVerificationKey', {'url': url});
  }

  @override
  Future<void> generateKeys() async {
    await methodChannel.invokeMethod('generateKeys');
  }

  @override
  Future<void> deleteKeys() async {
    await methodChannel.invokeMethod('deleteKeys');
  }

  @override
  Future<int> getProvingKeySize() async {
    final result = await methodChannel.invokeMethod<int>('getProvingKeySize');
    return result ?? 0;
  }

  @override
  Future<int> getVerificationKeySize() async {
    final result = await methodChannel.invokeMethod<int>('getVerificationKeySize');
    return result ?? 0;
  }

  @override
  Future<bool> isHardwareBackedStorage() async {
    final result = await methodChannel.invokeMethod<bool>('isHardwareBackedStorage');
    return result ?? false;
  }

  @override
  Future<Uint8List> exportVerificationKey() async {
    final result = await methodChannel.invokeMethod<Uint8List>('exportVerificationKey');
    return result ?? Uint8List(0);
  }

  @override
  Future<void> importVerificationKey(Uint8List keyData) async {
    await methodChannel.invokeMethod('importVerificationKey', {'keyData': keyData});
  }

  @override
  Future<Map<String, dynamic>> getKeyInfo() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>('getKeyInfo');
    return result != null ? Map<String, dynamic>.from(result) : {};
  }
}
