# Contributing to Active Circuitry Zero Knowledge Age Verification SDK

Thank you for your interest in contributing to the AC ZKP Age SDK!

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Bugs

- Use the GitHub issue tracker
- Check if the bug has already been reported
- Include detailed steps to reproduce
- Include system information (OS, Flutter version, device)

### Suggesting Enhancements

- Use the GitHub issue tracker with "enhancement" label
- Provide clear use case and rationale
- Consider backward compatibility

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Write or update tests
5. Ensure all tests pass
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Coding Standards

- Follow Dart style guide for Dart/Flutter code
- Follow Google C++ style guide for C++ code
- Follow Kotlin coding conventions for Android code
- Add comments for complex logic
- Write unit tests for new features

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests

## Development Setup

```bash
# Clone repository
git clone https://github.com/active-circuitry/ac-zkp-age-sdk.git

# Get dependencies
flutter pub get

# Build native libraries
cd android && ./gradlew build

# Run tests
flutter test
```

## Testing

- Write unit tests for all new features
- Ensure existing tests pass
- Add integration tests where appropriate
- Test on multiple Android versions
- Add negative tests for invalid, expired, tampered, and unsupported inputs
- Do not use real identity documents or personal data in fixtures

## Documentation

- Update README.md for user-facing changes
- Add inline documentation for public APIs
- Update API documentation in docs/

## Security

- Do not commit sensitive data
- Follow security best practices
- A user-entered date of birth is not a verified age claim. Age claims must come from an approved, trusted issuer.
- Do not collect, persist, or log raw identity documents, document numbers, or dates of birth in the SDK unless an approved provider flow explicitly requires temporary handling.
- Validate issuer signatures, accepted algorithms, issuer and audience, age threshold, expiration, and device binding when provided. Reject invalid or unsupported credentials; never fall back to accepting them.
- Offline credentials must fail closed after the configured 30-day status-refresh window or their earlier issuer-provided expiration. Document that local checks cannot fully prevent device-clock manipulation or a modified client from bypassing the gate.
- Simulated proofs and mock keys may only be used in clearly isolated tests or development builds. They must never be treated as valid production credentials.
- If a ZK proof system is used, perform trusted setup outside the mobile app and authenticate/version its circuit and public parameters. Do not generate or silently substitute production keys at runtime.
- Add tests for valid credentials and for invalid signatures, unknown issuers, wrong audiences, insufficient age claims, expiration, stale or revoked status, and device-binding failures where applicable.
- Report security vulnerabilities privately to security@activecircuitry.com

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Contact: activecircuitry@gmail.com
