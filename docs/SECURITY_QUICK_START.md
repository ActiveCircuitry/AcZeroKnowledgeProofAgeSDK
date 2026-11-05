# Security Quick Start

## Current status

This package is an experimental integration foundation, not a production age
verification solution. It has no provider adapter, credential signature
verifier, trusted issuer keys, or encrypted credential store.

The legacy Android proof and key-management operations return
`CRYPTO_BACKEND_UNAVAILABLE`. Do not work around this error or re-enable the
simulated backend.

## Before production use

1. Select an approved provider for each target market.
2. Implement signature and trust-chain verification using the provider's
   documented credential format.
3. Implement encrypted storage with protected encryption keys.
4. Validate expiry and status freshness against the provider's policy. The SDK
   policy caps offline status freshness at 30 days, but device-clock checks
   cannot prevent clock rollback on a modified client.
5. Add negative tests, provider sandbox tests, and an independent security and
   privacy review.

See [SECURITY_CONFIGURATION.md](SECURITY_CONFIGURATION.md) for security
requirements and [api.md](api.md) for the current API contracts.
