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

## Documentation

- Update README.md for user-facing changes
- Add inline documentation for public APIs
- Update API documentation in docs/

## Security

- Do not commit sensitive data
- Follow security best practices
- Report security vulnerabilities privately to security@activecircuitry.com

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Contact: support@activecircuitry.com
