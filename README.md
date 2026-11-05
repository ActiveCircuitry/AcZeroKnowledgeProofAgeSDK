# Active Circuitry Zero Knowledge Age Verification SDK

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://www.android.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)

An experimental Android Flutter SDK prototype for integrating provider-issued
age credentials.

> **Security notice:** No age-credential provider, signature verifier, or
> encrypted credential store is integrated yet. Legacy proof and key-management
> operations fail closed. Do not use this package for production age decisions.

## Overview

The SDK defines provider-neutral interfaces and policy types for integrating
age-only claims. A user-entered birth date is not treated as verified evidence.

### Key Features

- **Provider-neutral contracts** for credential acquisition, verification, and storage
- **Offline policy evaluation** with a maximum 30-day status freshness window
- **Fail-closed legacy API** while provider integration is pending

## Architecture

```
Flutter app
    |
    +-- AgeCredentialProvider (integration contract; no implementation)
    +-- AgeCredentialVerifier (provider signature verification contract)
    +-- AgeCredentialStore (secure storage contract; no implementation)
    +-- AgeCredentialPolicy (issuer, audience, age, expiry, freshness)
```

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ac_zero_knowledge_proof_age_sdk: ^0.1.0
```

## Current SDK Status

The legacy proof-generation, proof-verification, and key-management platform
operations now fail with `CRYPTO_BACKEND_UNAVAILABLE`. The simulated C++ proof
implementation is no longer built or loaded. Provider-neutral age-credential
interfaces and offline policy types are available, but no provider adapter,
signature verifier, or secure credential store is included yet.

Do not treat this version as a working age-verification product. A provider and
its signed credential format must be selected and integrated before credentials
can be acquired or verified.

## Security Configuration

There is no production security configuration or provider integration yet.
The previous mock-key and certificate-pinning configuration examples were
removed because they did not provide the protections they claimed. See the
[Security Configuration Guide](docs/SECURITY_CONFIGURATION.md) for current
limitations and planned integration requirements.

## Requirements

- Flutter 3.0 or higher
- Android SDK 24+ (Android 7.0+)
- Dart 3.0+

### Android Requirements

- Minimum SDK: 24 (Android 7.0)
- Target SDK: 34 (Android 14)
- No NDK is required by the currently enabled credential interfaces

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
