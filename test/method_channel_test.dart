/**
 * Method channel tests
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/src/platform/ac_zkp_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelAcZkp', () {
    const channel = MethodChannel('ac_zero_knowledge_proof_age_sdk');
    final platform = MethodChannelAcZkp();
    final List<MethodCall> log = [];

    setUp(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        
        switch (methodCall.method) {
          case 'isHardwareSecurityAvailable':
            return true;
          case 'hasProvingKey':
            return false;
          case 'hasVerificationKey':
            return false;
          case 'isHardwareBackedStorage':
            return true;
          case 'estimateProofTime':
            return 5000;
          case 'estimateVerificationTime':
            return 10;
          case 'getKeyInfo':
            return {'hasProvingKey': false, 'hasVerificationKey': false};
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('isHardwareSecurityAvailable calls correct method', () async {
      final result = await platform.isHardwareSecurityAvailable();
      
      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.last.method, equals('isHardwareSecurityAvailable'));
    });

    test('hasProvingKey calls correct method', () async {
      final result = await platform.hasProvingKey();
      
      expect(result, isFalse);
      expect(log, hasLength(1));
      expect(log.last.method, equals('hasProvingKey'));
    });

    test('hasVerificationKey calls correct method', () async {
      final result = await platform.hasVerificationKey();
      
      expect(result, isFalse);
      expect(log, hasLength(1));
      expect(log.last.method, equals('hasVerificationKey'));
    });

    test('isHardwareBackedStorage calls correct method', () async {
      final result = await platform.isHardwareBackedStorage();
      
      expect(result, isTrue);
      expect(log, hasLength(1));
      expect(log.last.method, equals('isHardwareBackedStorage'));
    });

    test('estimateProofTime passes protocol parameter', () async {
      final result = await platform.estimateProofTime(
        ZKPProtocol.groth16,
      );
      
      expect(result, equals(5000));
      expect(log, hasLength(1));
      expect(log.last.method, equals('estimateProofTime'));
      expect(log.last.arguments['protocol'], equals('groth16'));
    });

    test('getKeyInfo returns map', () async {
      final result = await platform.getKeyInfo();
      
      expect(result, isA<Map<String, dynamic>>());
      expect(log, hasLength(1));
      expect(log.last.method, equals('getKeyInfo'));
    });
  });
}
