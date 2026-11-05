import 'package:flutter_test/flutter_test.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

void main() {
  final now = DateTime.utc(2026, 11, 5);

  AgeCredentialPolicy policy({
    int minimumAge = 18,
    String audience = 'com.example.app',
    Duration maxOfflineAge = const Duration(days: 30),
    bool requireDeviceBinding = false,
  }) {
    return AgeCredentialPolicy(
      minimumAge: minimumAge,
      audience: audience,
      trustedIssuers: const {'issuer.example'},
      maxOfflineAge: maxOfflineAge,
      requireDeviceBinding: requireDeviceBinding,
    );
  }

  VerifiedAgeCredentialClaims claims({
    String issuer = 'issuer.example',
    String audience = 'com.example.app',
    int minimumAge = 18,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? statusCheckedAt,
    bool deviceBound = false,
  }) {
    return VerifiedAgeCredentialClaims(
      issuer: issuer,
      audience: audience,
      minimumAge: minimumAge,
      issuedAt: issuedAt ?? now.subtract(const Duration(days: 10)),
      expiresAt: expiresAt ?? now.add(const Duration(days: 20)),
      statusCheckedAt:
          statusCheckedAt ?? now.subtract(const Duration(days: 10)),
      deviceBound: deviceBound,
    );
  }

  group('AgeCredentialPolicy', () {
    test('accepts fresh authenticated claims matching policy', () {
      final result = policy().evaluate(claims(), now: now);

      expect(result.isAccepted, isTrue);
      expect(result.rejection, isNull);
    });

    test('rejects untrusted issuer and wrong audience', () {
      expect(
        policy().evaluate(claims(issuer: 'other.example'), now: now).rejection,
        AgeCredentialRejection.untrustedIssuer,
      );
      expect(
        policy().evaluate(claims(audience: 'another.app'), now: now).rejection,
        AgeCredentialRejection.wrongAudience,
      );
    });

    test('rejects insufficient age, expired, and stale credentials', () {
      expect(
        policy().evaluate(claims(minimumAge: 16), now: now).rejection,
        AgeCredentialRejection.insufficientAge,
      );
      expect(
        policy()
            .evaluate(
              claims(expiresAt: now.subtract(const Duration(seconds: 1))),
              now: now,
            )
            .rejection,
        AgeCredentialRejection.expired,
      );
      expect(
        policy()
            .evaluate(
              claims(
                issuedAt: now.subtract(const Duration(days: 40)),
                statusCheckedAt: now.subtract(const Duration(days: 31)),
              ),
              now: now,
            )
            .rejection,
        AgeCredentialRejection.statusStale,
      );
    });

    test('rejects invalid time bounds and missing required device binding', () {
      expect(
        policy()
            .evaluate(
              claims(issuedAt: now.add(const Duration(minutes: 1))),
              now: now,
            )
            .rejection,
        AgeCredentialRejection.invalidTime,
      );
      expect(
        policy(requireDeviceBinding: true)
            .evaluate(claims(), now: now)
            .rejection,
        AgeCredentialRejection.deviceBindingRequired,
      );
    });

    test('caps offline policy at 30 days', () {
      expect(
        () => policy(maxOfflineAge: const Duration(days: 31)),
        throwsArgumentError,
      );
    });
  });

  test('credential string representation redacts its payload', () {
    const credential = AgeCredential(
      providerId: 'provider.example',
      format: 'provider-v1',
      serializedCredential: 'sensitive-token',
    );

    expect(credential.toString(), isNot(contains('sensitive-token')));
  });

  test('request rejects invalid age, audience, and offline window', () {
    expect(
      () => AgeCredentialRequest(minimumAge: -1, audience: 'app'),
      throwsArgumentError,
    );
    expect(
      () => AgeCredentialRequest(minimumAge: 18, audience: '  '),
      throwsArgumentError,
    );
    expect(
      () => AgeCredentialRequest(
        minimumAge: 18,
        audience: 'app',
        maxOfflineAge: const Duration(days: 31),
      ),
      throwsArgumentError,
    );
  });
}
