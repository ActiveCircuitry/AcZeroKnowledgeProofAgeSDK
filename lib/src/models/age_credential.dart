/// Opaque credential data returned by an age-assurance provider.
///
/// The payload format is provider-specific. Applications must not construct
/// trusted claims from this data without verifying the provider's signature.
class AgeCredential {
  /// Creates an opaque provider credential.
  ///
  /// [serializedCredential] must contain only the provider credential required
  /// for age verification, not raw identity documents or a birth date.
  const AgeCredential({
    required this.providerId,
    required this.format,
    required this.serializedCredential,
  });

  /// Stable identifier for the provider adapter that understands this format.
  final String providerId;

  /// Provider-defined format/version identifier.
  final String format;

  /// Opaque provider-signed credential representation.
  final String serializedCredential;

  @override
  String toString() =>
      'AgeCredential(providerId: $providerId, format: $format, payload: <redacted>)';
}

/// Request to acquire a provider-issued age credential.
class AgeCredentialRequest {
  /// Creates a request without collecting a birth date or identity document.
  AgeCredentialRequest({
    required this.minimumAge,
    required this.audience,
    this.maxOfflineAge = const Duration(days: 30),
  }) {
    if (minimumAge < 0 || minimumAge > 150) {
      throw ArgumentError.value(minimumAge, 'minimumAge', 'Must be 0-150.');
    }
    if (audience.trim().isEmpty) {
      throw ArgumentError.value(audience, 'audience', 'Must not be empty.');
    }
    if (maxOfflineAge <= Duration.zero ||
        maxOfflineAge > const Duration(days: 30)) {
      throw ArgumentError.value(
        maxOfflineAge,
        'maxOfflineAge',
        'Must be positive and no longer than 30 days.',
      );
    }
  }

  /// The minimum age claim the provider should issue.
  final int minimumAge;

  /// The application or relying-party identifier for which the claim is issued.
  final String audience;

  /// Maximum age of the provider's signed status information when used offline.
  final Duration maxOfflineAge;
}

/// Claims authenticated by a provider-specific credential verifier.
///
/// Implementations must only produce these claims after verifying the
/// credential signature and the provider's required trust chain.
class VerifiedAgeCredentialClaims {
  /// Creates claims that have already been authenticated by a verifier.
  const VerifiedAgeCredentialClaims({
    required this.issuer,
    required this.audience,
    required this.minimumAge,
    required this.issuedAt,
    required this.expiresAt,
    required this.statusCheckedAt,
    this.deviceBound = false,
  });

  /// Credential issuer.
  final String issuer;

  /// Application or relying-party identifier.
  final String audience;

  /// Age threshold asserted by the issuer.
  final int minimumAge;

  /// Issuance time.
  final DateTime issuedAt;

  /// Provider-signed credential expiry.
  final DateTime expiresAt;

  /// Provider-signed time at which status was last checked.
  final DateTime statusCheckedAt;

  /// Whether the provider cryptographically bound the claim to this device.
  final bool deviceBound;
}

/// Rejection reasons returned by the common age-credential policy.
enum AgeCredentialRejection {
  /// The issuer is not in the application's trust policy.
  untrustedIssuer,

  /// The credential is for a different application.
  wrongAudience,

  /// The issuer's age claim is below the requested threshold.
  insufficientAge,

  /// The credential is not yet valid or has inconsistent timestamps.
  invalidTime,

  /// The credential has expired.
  expired,

  /// Provider status was checked too long ago for offline use.
  statusStale,

  /// A device-bound credential is required but was not provided.
  deviceBindingRequired,
}

/// Result of applying the common policy to authenticated credential claims.
class AgeCredentialDecision {
  /// Creates an accepted or rejected decision.
  const AgeCredentialDecision._(this.rejection);

  /// A null rejection means the credential satisfies the policy.
  final AgeCredentialRejection? rejection;

  /// Whether the credential satisfies the policy.
  bool get isAccepted => rejection == null;

  /// Creates an accepted decision.
  static const accepted = AgeCredentialDecision._(null);

  /// Creates a rejected decision.
  static AgeCredentialDecision rejected(AgeCredentialRejection reason) =>
      AgeCredentialDecision._(reason);
}

/// Local acceptance policy for provider-authenticated age claims.
class AgeCredentialPolicy {
  /// Creates a policy with an offline freshness limit capped at 30 days.
  AgeCredentialPolicy({
    required this.minimumAge,
    required this.audience,
    required Set<String> trustedIssuers,
    this.maxOfflineAge = const Duration(days: 30),
    this.requireDeviceBinding = false,
  }) : trustedIssuers = Set.unmodifiable(trustedIssuers) {
    if (minimumAge < 0 || minimumAge > 150) {
      throw ArgumentError.value(minimumAge, 'minimumAge', 'Must be 0-150.');
    }
    if (audience.trim().isEmpty) {
      throw ArgumentError.value(audience, 'audience', 'Must not be empty.');
    }
    if (this.trustedIssuers.isEmpty ||
        this.trustedIssuers.any((issuer) => issuer.trim().isEmpty)) {
      throw ArgumentError.value(
        trustedIssuers,
        'trustedIssuers',
        'Must contain at least one non-empty issuer.',
      );
    }
    if (maxOfflineAge <= Duration.zero ||
        maxOfflineAge > const Duration(days: 30)) {
      throw ArgumentError.value(
        maxOfflineAge,
        'maxOfflineAge',
        'Must be positive and no longer than 30 days.',
      );
    }
  }

  /// Minimum age required by the relying application.
  final int minimumAge;

  /// Expected relying-party/application identifier.
  final String audience;

  /// Issuers whose signatures the provider-specific verifier trusts.
  final Set<String> trustedIssuers;

  /// Maximum age of the authenticated status check for offline acceptance.
  final Duration maxOfflineAge;

  /// Whether a provider-signed device binding is required.
  final bool requireDeviceBinding;

  /// Evaluates claims only after a provider-specific verifier authenticates them.
  ///
  /// The supplied [now] uses the device clock and cannot by itself prevent
  /// clock rollback on a modified device.
  AgeCredentialDecision evaluate(
    VerifiedAgeCredentialClaims claims, {
    required DateTime now,
  }) {
    if (!trustedIssuers.contains(claims.issuer)) {
      return AgeCredentialDecision.rejected(
        AgeCredentialRejection.untrustedIssuer,
      );
    }
    if (claims.audience != audience) {
      return AgeCredentialDecision.rejected(
        AgeCredentialRejection.wrongAudience,
      );
    }
    if (claims.minimumAge < minimumAge) {
      return AgeCredentialDecision.rejected(
        AgeCredentialRejection.insufficientAge,
      );
    }
    if (claims.issuedAt.isAfter(now) ||
        claims.statusCheckedAt.isAfter(now) ||
        claims.statusCheckedAt.isBefore(claims.issuedAt) ||
        !claims.expiresAt.isAfter(claims.issuedAt)) {
      return AgeCredentialDecision.rejected(AgeCredentialRejection.invalidTime);
    }
    if (!now.isBefore(claims.expiresAt)) {
      return AgeCredentialDecision.rejected(AgeCredentialRejection.expired);
    }
    if (now.difference(claims.statusCheckedAt) > maxOfflineAge) {
      return AgeCredentialDecision.rejected(AgeCredentialRejection.statusStale);
    }
    if (requireDeviceBinding && !claims.deviceBound) {
      return AgeCredentialDecision.rejected(
        AgeCredentialRejection.deviceBindingRequired,
      );
    }
    return AgeCredentialDecision.accepted;
  }
}
