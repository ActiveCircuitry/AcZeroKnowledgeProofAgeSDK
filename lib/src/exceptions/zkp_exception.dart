/// Exception thrown by ZKP operations.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

/// Exception thrown when ZKP operations fail.
class ZkpException implements Exception {
  /// The error message.
  final String message;

  /// Optional error code for categorizing errors.
  final String? code;

  /// Optional underlying exception that caused this error.
  final dynamic cause;

  /// Optional stack trace of the underlying error.
  final StackTrace? stackTrace;

  const ZkpException(
    this.message, {
    this.code,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ZkpException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    if (cause != null) {
      buffer.write('\nCaused by: $cause');
    }
    return buffer.toString();
  }
}

/// Exception thrown when key operations fail.
class KeyManagementException extends ZkpException {
  const KeyManagementException(
    String message, {
    String? code,
    dynamic cause,
    StackTrace? stackTrace,
  }) : super(message, code: code, cause: cause, stackTrace: stackTrace);
}

/// Exception thrown when proof generation fails.
class ProofGenerationException extends ZkpException {
  const ProofGenerationException(
    String message, {
    String? code,
    dynamic cause,
    StackTrace? stackTrace,
  }) : super(message, code: code, cause: cause, stackTrace: stackTrace);
}

/// Exception thrown when proof verification fails.
class ProofVerificationException extends ZkpException {
  const ProofVerificationException(
    String message, {
    String? code,
    dynamic cause,
    StackTrace? stackTrace,
  }) : super(message, code: code, cause: cause, stackTrace: stackTrace);
}

/// Exception thrown when platform-specific operations fail.
class PlatformException extends ZkpException {
  const PlatformException(
    String message, {
    String? code,
    dynamic cause,
    StackTrace? stackTrace,
  }) : super(message, code: code, cause: cause, stackTrace: stackTrace);
}
