# Production Readiness Status

**Status:** Experimental prototype — not production-ready

The former Android/C++ backend generated simulated proof data, not Groth16 or
PLONK proofs. Proof and key-management platform operations have been disabled,
and the Android build no longer compiles or loads that native backend.

The repository now includes provider-neutral age-credential models, provider
and verifier interfaces, a secure-store interface, and local policy evaluation.
It does not include:

- A selected or integrated government/commercial identity provider
- A concrete credential-signature verifier or trusted issuer configuration
- An encrypted credential-store implementation
- A secure offline time or revocation mechanism
- A production cryptographic proof system

The current 30-day status freshness limit is a product policy, not a guarantee
against clock rollback or a modified client. A provider and applicable market
requirements must be confirmed before production use.

## Required production gates

1. Select a provider that supports the target markets and an
   offline-verifiable, age-minimized credential.
2. Verify signed issuer claims, audience, threshold, expiry, status, and device
   binding according to the provider's documented format.
3. Implement encrypted credential storage and authenticated trust-key updates.
4. Add provider sandbox and signed-fixture tests, including negative and stale
   credential cases.
5. Complete privacy, legal, threat-model, and independent security reviews.
