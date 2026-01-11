# Security Policy

## Reporting Security Vulnerabilities

**Please do not report security vulnerabilities through public GitHub issues.**

### Responsible Disclosure

Active Circuitry Private Ltd. takes the security of our software seriously. If you believe you have found a security vulnerability in the AC ZKP Age SDK, please report it to us responsibly.

**Email:** activecircuitry@gmail.com

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### Response Timeline

- **Initial Response:** Within 48 hours
- **Status Update:** Within 7 days
- **Fix Timeline:** Depends on severity (Critical: 7-14 days, High: 14-30 days)

## Security Best Practices

### For SDK Users

1. **Key Management**
   - Never commit cryptographic keys to version control
   - Use hardware-backed storage when available
   - Rotate keys periodically
   - Download keys only from trusted sources (HTTPS)

2. **Proof Validation**
   - Always verify proof expiration
   - Validate proof structure before cryptographic verification
   - Use appropriate age thresholds for your use case
   - Implement rate limiting on verification endpoints

3. **Data Handling**
   - Never log or transmit birth dates
   - Handle proofs as sensitive data
   - Implement secure deletion of proofs after use
   - Use HTTPS for all network communications

4. **Input Validation**
   - Validate all user inputs before proof generation
   - Sanitize date inputs
   - Implement proper error handling

### For SDK Developers

1. **Code Security**
   - Follow secure coding guidelines
   - Regular security audits
   - Dependency vulnerability scanning
   - Code review for all changes

2. **Cryptographic Security**
   - Use well-tested cryptographic libraries
   - Implement constant-time operations where possible
   - Protect against timing attacks
   - Regular security updates

3. **Platform Security**
   - Use Android KeyStore for key storage
   - Implement TEE support where available
   - Secure IPC between native and Dart layers
   - Obfuscate sensitive code paths

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1   | :x:                |

## Known Security Considerations

### Cryptographic Assumptions

1. **Trusted Setup:** Groth16 requires a trusted setup ceremony
2. **Circuit Security:** Circuits must be formally verified
3. **Key Security:** Proving keys must be kept secure

### Platform Limitations

1. **Android < 6.0:** No hardware-backed KeyStore
2. **Rooted Devices:** Reduced security guarantees
3. **Emulators:** Development only, not for production

### Network Security

1. **Key Distribution:** Keys should be distributed over HTTPS
2. **Proof Transmission:** Proofs should be transmitted securely
3. **Certificate Pinning:** Recommended for production apps

## Security Updates

Security updates will be released as patch versions. Subscribe to:
- GitHub Security Advisories
- Release notifications
- Email: security-updates@activecircuitry.com

## Compliance

This SDK aims to comply with:
- GDPR (Privacy by Design)
- COPPA (Children's Online Privacy Protection Act)
- CCPA (California Consumer Privacy Act)

## Audit History

| Date       | Type           | Auditor | Status |
|------------|----------------|---------|--------|
| 2026-01-11 | Internal       | AC Team | ✅     |
| Pending    | External       | TBD     | 🔜     |


---

**Copyright © 2026 Active Circuitry Private Ltd.**  
**Author: Zeng Han Jun**

Last Updated: January 11, 2026
