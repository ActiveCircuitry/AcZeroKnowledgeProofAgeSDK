# Active Circuitry Zero Knowledge Age Verification SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://www.android.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)

A high-performance Zero-Knowledge Proof (ZKP) library for Flutter applications, enabling privacy-preserving age verification without revealing sensitive user data.

## Overview

The **Active Circuitry Zero Knowledge Age Verification SDK** allows Android applications to verify user ages using cryptographic proofs, ensuring compliance with age-restricted content regulations while maintaining user privacy.

### Key Features

- 🔐 **Privacy-First**: Verify age without exposing birth dates or identity documents
- ⚡ **High Performance**: Optimized C++ core with Groth16 and PLONK support
- 📱 **Android Native**: Deep integration with Android security features (TEE, KeyStore)
- 🛡️ **Secure**: Hardware-backed key storage and trusted execution environment support
- 🚀 **Easy Integration**: Simple Flutter API for seamless app integration
- 📊 **Multiple Proofs**: Support for various age thresholds (13+, 16+, 18+, 21+)

## Supported ZKP Protocols

- **Groth16**: Fast verification, small proof size (~200 bytes)
- **PLONK**: Universal trusted setup, flexible circuits

## Use Cases

- Age-gated content (social media, dating apps, streaming)
- E-commerce age verification (alcohol, tobacco, restricted items)
- Gaming and gambling compliance
- Educational content filtering
- Government and healthcare applications

## Architecture

```
┌─────────────────────────────────────┐
│        Flutter Application          │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│      Dart API Layer (Public)        │
│  - AgeProofGenerator                │
│  - AgeProofVerifier                 │
│  - KeyManager                       │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│    Platform Channel (Method CH)     │
└────────┬────────────────────┬───────┘
         │                    │
┌────────▼────────┐  ┌────────▼────────┐
│  Android Native │  │   C++ Core      │
│  (Java/Kotlin)  │  │   (FFI/JNI)     │
│  - KeyStore     │  │   - Groth16     │
│  - TEE Support  │  │   - PLONK       │
└─────────────────┘  │   - Crypto      │
                     └─────────────────┘
```

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ac_zero_knowledge_proof_age_sdk: ^0.1.0
```

## Quick Start

```dart
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

// Generate a proof that user is 18+
final generator = AgeProofGenerator();
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
  protocol: ZKPProtocol.groth16,
);

// Verify the proof
final verifier = AgeProofVerifier();
final isValid = await verifier.verifyAgeProof(proof);

if (isValid) {
  print('User is verified to be 18 or older');
}
```

## Security Configuration

### Development Mode (Default)
The SDK works out-of-the-box for development:
```dart
// No configuration needed - mock keys enabled for easy testing
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
);
```

### Production Mode
Configure security features for production:

```kotlin
// In your Android Application class
import com.activecircuitry.zkp.age_sdk.ZkpKeyManager

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Disable mock keys in production
        ZkpKeyManager.allowMockKeys = false
        
        // Enable certificate pinning (recommended)
        ZkpKeyManager.enableCertificatePinning = true
    }
}
```

**📖 See [Security Configuration Guide](docs/SECURITY_CONFIGURATION.md) for complete setup instructions.**

## Requirements

- Flutter 3.0 or higher
- Android SDK 24+ (Android 7.0+)
- Dart 3.0+

### Android Requirements

- Minimum SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- NDK: r25c or higher (for C++ components)

## Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/active-circuitry/ac-zkp-age-sdk.git
cd AcZeroKnowledgeProofAgeSDK

# Get dependencies
flutter pub get

# Build native libraries
cd android && ./gradlew assembleRelease

# Run example app
cd example
flutter run
```

### Project Structure

```
AcZeroKnowledgeProofAgeSDK/
├── lib/                    # Dart/Flutter code
├── android/                # Android native code (Java/Kotlin)
├── cpp/                    # C++ ZKP core
├── example/                # Example Flutter app
├── test/                   # Unit tests
└── docs/                   # Documentation
```

## Documentation

- [API Documentation](docs/api.md)
- [Security Configuration Guide](docs/SECURITY_CONFIGURATION.md) ⭐ **Important for Production**
- [Production Deployment Summary](docs/PRODUCTION_SUMMARY.md)
- [Integration Guide](docs/integration.md)

## License

MIT License

Copyright (c) 2026 Active Circuitry Private Ltd.

## Author

**Zeng Han Jun**  
Active Circuitry Private Ltd.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## Support

- 📧 Email: activecircuitry@gmail.com
- 🐛 Issues: [GitHub Issues](https://github.com/active-circuitry/ac-zkp-age-sdk/issues)

## Acknowledgments

Built with cryptographic libraries:
- libsnark
- circom
- bellman

## Security

For security concerns, please email: activecircuitry@gmail.com

**Do not open public issues for security vulnerabilities.**
