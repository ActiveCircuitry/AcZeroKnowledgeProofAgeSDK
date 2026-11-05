# Security Configuration

## Current status

The legacy native proof and key-management operations are disabled. The former
C++ implementation generated simulated proof bytes, while key downloads could
fall back to mock files. Neither behavior is an acceptable security control.
The Android build no longer compiles or loads that native library.

No government or commercial provider is integrated yet. The provider-neutral
credential types are contracts only; they do not verify signatures or provide
secure storage by themselves. Do not use this package to make production age,
access-control, or compliance decisions.

## Planned provider integration requirements

Before enabling credential verification, an implementation must:

- Obtain an age claim from a trusted provider rather than accept a user-entered
  birth date as verified.
- Verify the provider's signature, trust chain, audience, age threshold,
  expiry, status freshness, and device binding when available.
- Enforce an offline status window of no more than 30 days and fail closed
  when the credential or status is stale.
- Encrypt stored credentials and keep raw identity documents, document
  numbers, and birth dates out of SDK persistence and logs.
- Use an authenticated provider key-rotation process. HTTPS or a checksum
  alone does not establish that a key or credential is trusted.
- Document that local-only checks can be bypassed on a modified device and
  that device-clock manipulation limits offline expiry guarantees.

Trusted issuer keys and public proof parameters, if a ZK system is later
required, must be versioned and authenticated. Trusted setup must never run in
the mobile application.
