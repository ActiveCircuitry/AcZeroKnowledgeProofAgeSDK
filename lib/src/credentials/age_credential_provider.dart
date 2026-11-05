import '../models/age_credential.dart';

/// Provider-specific acquisition and refresh boundary.
///
/// Implementations may launch a provider SDK, browser, or native identity app.
/// The SDK does not prescribe a provider credential format.
abstract interface class AgeCredentialProvider {
  /// Stable identifier used to select the matching credential verifier.
  String get providerId;

  /// Obtains a provider-issued age credential.
  Future<AgeCredential> acquireCredential(AgeCredentialRequest request);

  /// Refreshes provider-signed status for an existing credential.
  Future<AgeCredential> refreshCredential(AgeCredential credential);
}

/// Verifies a provider credential and returns authenticated claims.
abstract interface class AgeCredentialVerifier {
  /// Verifies the credential signature, issuer trust, and format.
  ///
  /// Must throw if the signature, trust chain, or provider format is invalid.
  /// Claims returned from this method are then evaluated against
  /// [AgeCredentialPolicy].
  Future<VerifiedAgeCredentialClaims> verifySignature(
    AgeCredential credential,
  );
}

/// Storage boundary for provider credentials.
///
/// Production implementations must encrypt credential data at rest and must
/// not log serialized credentials.
abstract interface class AgeCredentialStore {
  /// Reads the stored credential, or returns null when none is available.
  Future<AgeCredential?> read();

  /// Saves a credential using the implementation's secure storage policy.
  Future<void> write(AgeCredential credential);

  /// Deletes the stored credential.
  Future<void> delete();
}
