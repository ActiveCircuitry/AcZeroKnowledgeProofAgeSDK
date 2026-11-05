/// Key management for ZKP operations.
///
/// Handles secure storage and retrieval of cryptographic keys used in
/// proof generation and verification. Integrates with Android KeyStore
/// and Trusted Execution Environment (TEE) when available.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart' as services;
import 'exceptions/zkp_exception.dart';
import 'platform/ac_zkp_platform_interface.dart';

/// Manages cryptographic keys for ZKP operations.
///
/// Example:
/// ```dart
/// final keyManager = KeyManager();
/// await keyManager.initialize();
/// final hasKeys = await keyManager.hasProvingKey();
/// ```
class KeyManager {
  final AcZkpPlatformInterface _platform = AcZkpPlatformInterface.instance;
  bool _initialized = false;

  /// Initializes the key manager.
  ///
  /// Must be called before any key operations.
  /// Downloads or generates necessary proving and verification keys.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _platform.initializeKeys();
      _initialized = true;
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to initialize key manager: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Checks if proving keys are available.
  Future<bool> hasProvingKey() async {
    _ensureInitialized();
    try {
      return await _platform.hasProvingKey();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return false;
    }
  }

  /// Checks if verification keys are available.
  Future<bool> hasVerificationKey() async {
    _ensureInitialized();
    try {
      return await _platform.hasVerificationKey();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return false;
    }
  }

  /// Downloads proving keys from a trusted source.
  ///
  /// [url]: Optional custom URL for key download
  /// [onProgress]: Callback for download progress (0.0 to 1.0)
  /// [maxRetries]: Number of retry attempts on failure
  /// [timeout]: Timeout duration for download
  Future<void> downloadProvingKey({
    String? url,
    void Function(double progress)? onProgress,
    int maxRetries = 3,
    Duration timeout = const Duration(minutes: 5),
  }) async {
    _ensureInitialized();

    int attemptCount = 0;
    Exception? lastException;

    while (attemptCount < maxRetries) {
      try {
        attemptCount++;

        // Attempt download with timeout
        await _platform
            .downloadProvingKey(
              url: url,
              onProgress: onProgress,
            )
            .timeout(
              timeout,
              onTimeout: () => throw KeyManagementException(
                'Download timed out after ${timeout.inMinutes} minutes',
                code: 'DOWNLOAD_TIMEOUT',
              ),
            );

        return; // Success
      } on KeyManagementException catch (e) {
        lastException = e;
        if (attemptCount >= maxRetries) {
          throw KeyManagementException(
            'Failed to download proving key after $maxRetries attempts: ${e.message}',
            code: 'DOWNLOAD_MAX_RETRIES',
            cause: e,
          );
        }
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: 2 * attemptCount));
      } catch (e) {
        _throwIfBackendUnavailable(e);
        lastException = Exception(e.toString());
        if (attemptCount >= maxRetries) break;
        await Future.delayed(Duration(seconds: 2 * attemptCount));
      }
    }

    throw KeyManagementException(
      'Failed to download proving key after $maxRetries attempts',
      code: 'DOWNLOAD_FAILED',
      cause: lastException,
    );
  }

  /// Downloads verification keys from a trusted source.
  ///
  /// [url]: Optional custom URL for key download
  /// [onProgress]: Callback for download progress (0.0 to 1.0)
  Future<void> downloadVerificationKey({
    String? url,
    void Function(double progress)? onProgress,
  }) async {
    _ensureInitialized();
    try {
      await _platform.downloadVerificationKey(
        url: url,
        onProgress: onProgress,
      );
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to download verification key: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Generates new proving and verification keys.
  ///
  /// WARNING: This is a computationally expensive operation and should
  /// typically only be done during trusted setup ceremonies.
  /// For most use cases, use [downloadProvingKey] instead.
  Future<void> generateKeys() async {
    _ensureInitialized();
    try {
      await _platform.generateKeys();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to generate keys: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Deletes all stored keys.
  ///
  /// Use with caution - this will require re-downloading or regenerating keys.
  Future<void> deleteKeys() async {
    _ensureInitialized();
    try {
      await _platform.deleteKeys();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to delete keys: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Gets the size of the proving key in bytes.
  Future<int> getProvingKeySize() async {
    _ensureInitialized();
    try {
      return await _platform.getProvingKeySize();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return 0;
    }
  }

  /// Gets the size of the verification key in bytes.
  Future<int> getVerificationKeySize() async {
    _ensureInitialized();
    try {
      return await _platform.getVerificationKeySize();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return 0;
    }
  }

  /// Checks if hardware-backed key storage is available (Android KeyStore).
  Future<bool> isHardwareBackedStorage() async {
    _ensureInitialized();
    try {
      return await _platform.isHardwareBackedStorage();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return false;
    }
  }

  /// Exports the verification key for use on a server or other device.
  ///
  /// The verification key is public and safe to share.
  Future<Uint8List> exportVerificationKey() async {
    _ensureInitialized();
    try {
      return await _platform.exportVerificationKey();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to export verification key: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Imports a verification key from bytes.
  ///
  /// Useful for using verification keys from other sources.
  Future<void> importVerificationKey(Uint8List keyData) async {
    _ensureInitialized();
    try {
      await _platform.importVerificationKey(keyData);
    } catch (e) {
      _throwIfBackendUnavailable(e);
      throw ZkpException(
        'Failed to import verification key: $e',
        code: e is services.PlatformException ? e.code : null,
        cause: e,
      );
    }
  }

  /// Gets information about the current key configuration.
  Future<Map<String, dynamic>> getKeyInfo() async {
    _ensureInitialized();
    try {
      return await _platform.getKeyInfo();
    } catch (e) {
      _throwIfBackendUnavailable(e);
      return {};
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw ZkpException(
          'KeyManager not initialized. Call initialize() first.');
    }
  }

  void _throwIfBackendUnavailable(Object error) {
    if (error is services.PlatformException &&
        error.code == 'CRYPTO_BACKEND_UNAVAILABLE') {
      throw KeyManagementException(
        'Cryptographic backend is unavailable: ${error.message}',
        code: error.code,
        cause: error,
      );
    }
  }
}
