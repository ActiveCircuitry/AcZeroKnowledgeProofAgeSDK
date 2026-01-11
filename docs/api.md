## API Documentation

### Table of Contents
- [Core Classes](#core-classes)
- [Models](#models)
- [Platform Interface](#platform-interface)
- [Exceptions](#exceptions)
- [Usage Examples](#usage-examples)

## Core Classes

### AgeProofGenerator

Generates Zero-Knowledge Proofs for age verification.

```dart
final generator = AgeProofGenerator();
```

#### Methods

**generateAgeProof**
```dart
Future<AgeProof> generateAgeProof({
  required DateTime birthDate,
  required int minimumAge,
  ZKPProtocol protocol = ZKPProtocol.groth16,
  bool useHardwareSecurity = true,
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 1),
})
```

Generates a proof that the user meets the minimum age requirement.

**Parameters:**
- `birthDate`: User's birth date (kept private)
- `minimumAge`: Minimum age to prove (e.g., 18 for 18+)
- `protocol`: ZKP protocol to use (Groth16 or PLONK)
- `useHardwareSecurity`: Use hardware-backed security when available
- `maxRetries`: Number of retry attempts on failure
- `retryDelay`: Delay between retries

**Returns:** `AgeProof` - The generated proof

**Throws:** `ProofGenerationException` if generation fails

---

**generateAgeProofForThreshold**
```dart
Future<AgeProof> generateAgeProofForThreshold({
  required DateTime birthDate,
  required AgeThreshold threshold,
  ZKPProtocol protocol = ZKPProtocol.groth16,
})
```

Convenience method for common age thresholds (13+, 16+, 18+, 21+).

---

### AgeProofVerifier

Verifies Zero-Knowledge Proofs for age verification.

```dart
final verifier = AgeProofVerifier();
```

#### Methods

**verifyAgeProof**
```dart
Future<bool> verifyAgeProof(
  AgeProof proof, {
  int maxRetries = 2,
})
```

Verifies a proof without revealing the actual age.

**Parameters:**
- `proof`: The proof to verify
- `maxRetries`: Number of retry attempts on failure

**Returns:** `bool` - `true` if proof is valid, `false` otherwise

**Throws:** `ProofVerificationException` if verification fails

---

**verifyAgeProofDetailed**
```dart
Future<ProofResult> verifyAgeProofDetailed(AgeProof proof)
```

Returns detailed verification results including timing and metadata.

---

### KeyManager

Manages cryptographic keys for ZKP operations.

```dart
final keyManager = KeyManager();
await keyManager.initialize();
```

#### Methods

**initialize**
```dart
Future<void> initialize()
```

Initializes the key manager. Must be called before any key operations.

---

**downloadProvingKey**
```dart
Future<void> downloadProvingKey({
  String? url,
  void Function(double progress)? onProgress,
  int maxRetries = 3,
  Duration timeout = const Duration(minutes: 5),
})
```

Downloads proving key from a trusted source with retry logic.

---

**hasProvingKey**
```dart
Future<bool> hasProvingKey()
```

Checks if proving key is available locally.

---

## Models

### AgeProof

Represents a Zero-Knowledge Proof for age verification.

```dart
class AgeProof {
  final Uint8List proofData;
  final int minimumAge;
  final ZKPProtocol protocol;
  final DateTime generatedAt;
  final DateTime? expiresAt;
  final String proofId;
  final String sdkVersion;
  
  int get proofSize => proofData.length;
  bool get isExpired { /* ... */ }
  String get description { /* ... */ }
}
```

---

### ZKPProtocol

Supported Zero-Knowledge Proof protocols.

```dart
enum ZKPProtocol {
  groth16,  // Fast verification, small proof size
  plonk,    // Universal setup, flexible circuits
}
```

**Extension methods:**
- `displayName`: Human-readable name
- `description`: Protocol description
- `typicalProofSize`: Expected proof size in bytes
- `typicalVerificationTime`: Expected verification time in ms
- `supportsUniversalSetup`: Whether protocol supports universal setup

---

### AgeThreshold

Common age thresholds for verification.

```dart
enum AgeThreshold {
  age13,  // COPPA compliance
  age16,  // GDPR digital consent
  age18,  // Legal adult
  age21,  // Legal drinking age (USA)
}
```

**Extension methods:**
- `age`: Numeric age value
- `displayName`: Display string (e.g., "18+")
- `useCase`: Common use case description
- `regulation`: Associated regulatory framework

---

### ProofResult

Detailed verification result.

```dart
class ProofResult {
  final bool isValid;
  final int minimumAge;
  final ZKPProtocol protocol;
  final DateTime verifiedAt;
  final int verificationTimeMs;
  final String? errorMessage;
  
  String get statusMessage { /* ... */ }
}
```

---

## Exceptions

### ZkpException

Base exception for all ZKP operations.

```dart
class ZkpException implements Exception {
  final String message;
  final String? code;
  final dynamic cause;
  final StackTrace? stackTrace;
}
```

**Specialized exceptions:**
- `KeyManagementException`: Key operation failures
- `ProofGenerationException`: Proof generation failures
- `ProofVerificationException`: Proof verification failures
- `PlatformException`: Platform-specific errors

---

## Usage Examples

### Basic Age Verification

```dart
// Generate proof
final generator = AgeProofGenerator();
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
);

// Verify proof
final verifier = AgeProofVerifier();
final isValid = await verifier.verifyAgeProof(proof);

if (isValid) {
  print('User is 18 or older');
}
```

### Using Predefined Thresholds

```dart
final proof = await generator.generateAgeProofForThreshold(
  birthDate: DateTime(2005, 6, 15),
  threshold: AgeThreshold.age18,
);
```

### PLONK Protocol

```dart
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1995, 3, 20),
  minimumAge: 21,
  protocol: ZKPProtocol.plonk,
);
```

### Key Management

```dart
final keyManager = KeyManager();
await keyManager.initialize();

// Check if keys exist
if (!await keyManager.hasProvingKey()) {
  // Download keys with progress tracking
  await keyManager.downloadProvingKey(
    onProgress: (progress) {
      print('Download: ${(progress * 100).toInt()}%');
    },
  );
}

// Get key info
final info = await keyManager.getKeyInfo();
print('Proving key size: ${info['provingKeySize']} bytes');
```

### Error Handling

```dart
try {
  final proof = await generator.generateAgeProof(
    birthDate: DateTime(1990, 1, 1),
    minimumAge: 18,
    maxRetries: 3,
  );
} on ProofGenerationException catch (e) {
  print('Generation failed: ${e.message}');
  print('Error code: ${e.code}');
} on ZkpException catch (e) {
  print('ZKP error: ${e.message}');
}
```

### Hardware Security

```dart
// Check if hardware security is available
final isAvailable = await generator.isHardwareSecurityAvailable();

// Generate with hardware security
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
  useHardwareSecurity: isAvailable,
);
```

---

**Copyright © 2026 Active Circuitry Private Ltd.**  
**Author: Zeng Han Jun**
