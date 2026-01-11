/// Zero-Knowledge Proof protocol types.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

/// Supported Zero-Knowledge Proof protocols.
enum ZKPProtocol {
  /// Groth16 protocol.
  ///
  /// Advantages:
  /// - Fast verification (~10ms on mobile)
  /// - Small proof size (~200 bytes)
  /// - Well-tested and widely used
  ///
  /// Disadvantages:
  /// - Requires trusted setup per circuit
  /// - Less flexible for circuit changes
  ///
  /// Best for: Production apps with fixed age thresholds
  groth16,

  /// PLONK protocol.
  ///
  /// Advantages:
  /// - Universal trusted setup (one-time setup for all circuits)
  /// - More flexible for circuit updates
  /// - Better for evolving requirements
  ///
  /// Disadvantages:
  /// - Slightly slower verification (~50ms on mobile)
  /// - Larger proof size (~500 bytes)
  ///
  /// Best for: Apps with changing verification requirements
  plonk,
}

/// Extension methods for ZKPProtocol.
extension ZKPProtocolExtension on ZKPProtocol {
  /// Gets the display name of this protocol.
  String get displayName {
    switch (this) {
      case ZKPProtocol.groth16:
        return 'Groth16';
      case ZKPProtocol.plonk:
        return 'PLONK';
    }
  }

  /// Gets a description of this protocol.
  String get description {
    switch (this) {
      case ZKPProtocol.groth16:
        return 'Fast verification with small proof size';
      case ZKPProtocol.plonk:
        return 'Universal setup with flexible circuits';
    }
  }

  /// Gets the typical proof size in bytes.
  int get typicalProofSize {
    switch (this) {
      case ZKPProtocol.groth16:
        return 200;
      case ZKPProtocol.plonk:
        return 500;
    }
  }

  /// Gets the typical verification time in milliseconds.
  int get typicalVerificationTime {
    switch (this) {
      case ZKPProtocol.groth16:
        return 10;
      case ZKPProtocol.plonk:
        return 50;
    }
  }

  /// Gets the typical proof generation time in milliseconds.
  int get typicalGenerationTime {
    switch (this) {
      case ZKPProtocol.groth16:
        return 5000; // ~5 seconds
      case ZKPProtocol.plonk:
        return 8000; // ~8 seconds
    }
  }

  /// Whether this protocol requires a trusted setup.
  bool get requiresTrustedSetup => true; // Both require some form of setup

  /// Whether this protocol supports universal setup.
  bool get supportsUniversalSetup {
    switch (this) {
      case ZKPProtocol.groth16:
        return false; // Circuit-specific setup
      case ZKPProtocol.plonk:
        return true; // Universal setup
    }
  }
}
