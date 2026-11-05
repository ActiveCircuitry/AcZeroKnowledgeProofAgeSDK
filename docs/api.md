# API Documentation

## Status

The legacy proof-generation, proof-verification, and key-management platform
methods are disabled and return `CRYPTO_BACKEND_UNAVAILABLE`. They must not be
used to make age, access-control, or compliance decisions.

The provider-neutral contracts below are integration points only. This package
does not yet include a provider adapter, credential signature verifier, or
encrypted credential-store implementation.

## Credential API

Import the public API:

```dart
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
```

### `AgeCredential`

An opaque serialized credential returned by an approved provider:

```dart
const credential = AgeCredential(
  providerId: 'provider-id',
  format: 'provider-format-version',
  serializedCredential: providerSignedPayload,
);
```

The serialized payload is sensitive and its `toString()` output is redacted.
Do not log it or include raw identity documents or a birth date.

### `AgeCredentialRequest`

Requests an age claim without passing a birth date:

```dart
final request = AgeCredentialRequest(
  minimumAge: 18,
  audience: 'com.example.app',
  maxOfflineAge: Duration(days: 30),
);
```

### Provider integration contracts

`AgeCredentialProvider` defines `acquireCredential` and
`refreshCredential` for a provider adapter. The provider may use its own SDK,
browser flow, or identity app; the SDK intentionally does not prescribe that
flow or the credential wire format.

`AgeCredentialVerifier.verifySignature` must authenticate the provider
signature and trust chain before returning `VerifiedAgeCredentialClaims`.
Invalid signatures, unsupported formats, and untrusted issuers must throw
rather than return successful claims.

`AgeCredentialStore` defines `read`, `write`, and `delete`. Any production
implementation must encrypt credentials at rest and protect its encryption
key using an appropriate platform mechanism.

### `AgeCredentialPolicy`

Evaluates already-authenticated claims against application policy:

```dart
final policy = AgeCredentialPolicy(
  minimumAge: 18,
  audience: 'com.example.app',
  trustedIssuers: {'approved-issuer-id'},
  maxOfflineAge: const Duration(days: 30),
  requireDeviceBinding: true,
);

final decision = policy.evaluate(
  authenticatedClaims,
  now: DateTime.now(),
);

if (decision.isAccepted) {
  // Apply local app policy.
}
```

The policy checks issuer, audience, age threshold, timestamps, status
freshness, and optional device binding. The offline window cannot exceed 30
days. `evaluate` does **not** verify the credential signature; obtain the claims
from a trusted `AgeCredentialVerifier` first. The clock comes from the device,
so offline expiry cannot fully resist a modified client or clock rollback.

## Legacy API

`AgeProofGenerator`, `AgeProofVerifier`, and `KeyManager` remain temporarily for
source compatibility. Their Android platform operations are disabled until a
real provider and trusted verification implementation are integrated. The old
simulation is not a fallback and must not be re-enabled.
