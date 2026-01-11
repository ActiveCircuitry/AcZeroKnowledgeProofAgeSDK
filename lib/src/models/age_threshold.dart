/// Predefined age thresholds for common use cases.
///
/// Copyright (c) 2026 Active Circuitry Private Ltd.
/// Author: Zeng Han Jun

/// Common age thresholds used in age verification.
enum AgeThreshold {
  /// 13 years old - COPPA compliance (Children's Online Privacy Protection Act)
  age13,

  /// 16 years old - EU GDPR digital consent age in some countries
  age16,

  /// 18 years old - Legal adult age in most countries
  age18,

  /// 21 years old - Legal drinking age in USA and some other countries
  age21,
}

/// Extension methods for AgeThreshold.
extension AgeThresholdExtension on AgeThreshold {
  /// Gets the numeric age value.
  int get age {
    switch (this) {
      case AgeThreshold.age13:
        return 13;
      case AgeThreshold.age16:
        return 16;
      case AgeThreshold.age18:
        return 18;
      case AgeThreshold.age21:
        return 21;
    }
  }

  /// Gets the display name of this threshold.
  String get displayName {
    return '$age+';
  }

  /// Gets a description of this threshold's common use case.
  String get useCase {
    switch (this) {
      case AgeThreshold.age13:
        return 'COPPA compliance - Social media, online services';
      case AgeThreshold.age16:
        return 'GDPR digital consent - EU data processing';
      case AgeThreshold.age18:
        return 'Legal adult - Dating apps, gambling, mature content';
      case AgeThreshold.age21:
        return 'Legal drinking age - Alcohol sales, bars, clubs';
    }
  }

  /// Gets the regulatory framework associated with this threshold.
  String get regulation {
    switch (this) {
      case AgeThreshold.age13:
        return 'COPPA (USA)';
      case AgeThreshold.age16:
        return 'GDPR (EU)';
      case AgeThreshold.age18:
        return 'Various (Global)';
      case AgeThreshold.age21:
        return 'MLDA (USA)';
    }
  }

  /// Creates an AgeThreshold from a numeric age.
  static AgeThreshold? fromAge(int age) {
    switch (age) {
      case 13:
        return AgeThreshold.age13;
      case 16:
        return AgeThreshold.age16;
      case 18:
        return AgeThreshold.age18;
      case 21:
        return AgeThreshold.age21;
      default:
        return null;
    }
  }

  /// Gets all available thresholds as a list.
  static List<AgeThreshold> get all => AgeThreshold.values;

  /// Gets all thresholds with their ages as a map.
  static Map<int, AgeThreshold> get ageMap => {
        for (var threshold in AgeThreshold.values) threshold.age: threshold,
      };
}
