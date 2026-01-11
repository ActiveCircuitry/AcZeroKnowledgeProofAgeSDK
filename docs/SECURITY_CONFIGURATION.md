# Security Configuration Guide

## Overview

This guide explains how to configure security features in the Active Circuitry ZKP Age SDK for both development and production environments.

## Quick Start

### Development Mode (Default)
The SDK is configured for easy development by default:
```dart
// No additional configuration needed
final generator = AgeProofGenerator();
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
);
```

### Production Mode
For production, configure security features:

#### Kotlin/Android Configuration
```kotlin
import com.activecircuitry.zkp.age_sdk.ZkpKeyManager

// In your Application or Activity initialization
ZkpKeyManager.allowMockKeys = false  // Disable mock keys
ZkpKeyManager.enableCertificatePinning = true  // Enable cert pinning
ZkpKeyManager.expectedCertificateHash = "your_cert_hash_here"  // Optional
```

#### Flutter/Dart Configuration
```dart
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

// Configure before using the SDK
await configureSecurityForProduction();
```

## Security Features

### 1. Mock Key Protection

**Purpose**: Prevent accidental use of test keys in production

**Development** (default):
```kotlin
ZkpKeyManager.allowMockKeys = true  // Mock keys allowed for testing
```

**Production**:
```kotlin
ZkpKeyManager.allowMockKeys = false  // Mock keys disabled
```

**Behavior**:
- When disabled, SDK will throw `SecurityException` if key download fails
- When enabled, SDK falls back to mock keys with security warnings in logs

**Example Error**:
```
SecurityException: Mock keys are disabled. Please configure proper 
key downloads or enable allowMockKeys for testing.
```

### 2. Certificate Pinning

**Purpose**: Prevent man-in-the-middle attacks on key downloads

**Development**:
```kotlin
ZkpKeyManager.enableCertificatePinning = false  // Disabled for flexibility
```

**Production**:
```kotlin
ZkpKeyManager.enableCertificatePinning = true
ZkpKeyManager.expectedCertificateHash = "abc123..."  // Your certificate hash
```

**Getting Your Certificate Hash**:
```bash
# For your server's certificate
openssl s_client -connect keys.activecircuitry.com:443 < /dev/null 2>/dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64
```

### 3. Key Integrity Verification

**Purpose**: Verify downloaded keys haven't been tampered with

**Usage**:
```kotlin
val keyManager = ZkpKeyManager(context)
val keyData = keyManager.loadProvingKey()
val expectedHash = "your_key_sha256_hash"

if (keyManager.verifyKeyIntegrity(keyData, expectedHash)) {
    println("✅ Key integrity verified")
} else {
    println("❌ Key integrity check failed!")
}
```

**Generating Key Hash**:
```bash
# For a key file
sha256sum proving_key.bin
# or
shasum -a 256 proving_key.bin
```

### 4. Network Security Configuration

**Setup** (Android):

1. Enable in `AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

2. Update certificate pins in `res/xml/network_security_config.xml`:
```xml
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">keys.activecircuitry.com</domain>
    <pin-set expiration="2027-01-01">
        <!-- Replace with your actual certificate pins -->
        <pin digest="SHA-256">YOUR_PRIMARY_CERT_HASH_HERE=</pin>
        <pin digest="SHA-256">YOUR_BACKUP_CERT_HASH_HERE=</pin>
    </pin-set>
</domain-config>
```

## Configuration Profiles

### Development Profile
```kotlin
// In your debug build variant or development initialization
fun configureForDevelopment() {
    ZkpKeyManager.allowMockKeys = true
    ZkpKeyManager.enableCertificatePinning = false
    ZkpKeyManager.expectedCertificateHash = null
}
```

### Staging Profile
```kotlin
// In your staging build variant
fun configureForStaging() {
    ZkpKeyManager.allowMockKeys = true  // Allow fallback
    ZkpKeyManager.enableCertificatePinning = true
    ZkpKeyManager.expectedCertificateHash = "staging_cert_hash"
}
```

### Production Profile
```kotlin
// In your release build variant
fun configureForProduction() {
    ZkpKeyManager.allowMockKeys = false  // Strict mode
    ZkpKeyManager.enableCertificatePinning = true
    ZkpKeyManager.expectedCertificateHash = "production_cert_hash"
}
```

## Build Variant Configuration

### Using BuildConfig for Automatic Configuration

**build.gradle (app level)**:
```gradle
android {
    buildTypes {
        debug {
            buildConfigField "boolean", "ALLOW_MOCK_KEYS", "true"
            buildConfigField "boolean", "ENABLE_CERT_PINNING", "false"
        }
        release {
            buildConfigField "boolean", "ALLOW_MOCK_KEYS", "false"
            buildConfigField "boolean", "ENABLE_CERT_PINNING", "true"
            buildConfigField "String", "CERT_HASH", "\"your_production_cert_hash\""
        }
    }
}
```

**Application Initialization**:
```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Automatically configure based on build type
        ZkpKeyManager.allowMockKeys = BuildConfig.ALLOW_MOCK_KEYS
        ZkpKeyManager.enableCertificatePinning = BuildConfig.ENABLE_CERT_PINNING
        
        if (BuildConfig.BUILD_TYPE == "release") {
            ZkpKeyManager.expectedCertificateHash = BuildConfig.CERT_HASH
        }
    }
}
```

## Security Warnings

The SDK will log security warnings when potentially unsafe configurations are used:

```
⚠️ SECURITY WARNING: Using mock proving key for TESTING ONLY. DO NOT use in production!
⚠️ SECURITY WARNING: Certificate pinning is disabled
⚠️ SECURITY WARNING: Key integrity verification skipped
```

**In production**, ensure these warnings do not appear in your logs.

## Checking Security Configuration

```kotlin
val keyManager = ZkpKeyManager(context)
val info = keyManager.getKeyInfo()

val securityConfig = info["securityConfig"] as Map<String, Boolean>
println("Certificate Pinning: ${securityConfig["certificatePinningEnabled"]}")
println("Mock Keys Allowed: ${securityConfig["mockKeysAllowed"]}")

// Verify secure configuration for production
if (BuildConfig.BUILD_TYPE == "release") {
    require(!securityConfig["mockKeysAllowed"]!!) { 
        "Mock keys must be disabled in production" 
    }
    require(securityConfig["certificatePinningEnabled"]!!) { 
        "Certificate pinning must be enabled in production" 
    }
}
```

## Security Checklist

Before releasing to production:

- [ ] `ZkpKeyManager.allowMockKeys = false`
- [ ] `ZkpKeyManager.enableCertificatePinning = true`
- [ ] Certificate hash configured
- [ ] Network security config enabled in manifest
- [ ] Certificate pins updated in network_security_config.xml
- [ ] No security warnings in production logs
- [ ] Key integrity verification implemented (optional but recommended)
- [ ] Build variant configuration tested

## Example: Complete Production Setup

```kotlin
// Application.kt
class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        
        when (BuildConfig.BUILD_TYPE) {
            "debug" -> configureForDevelopment()
            "release" -> configureForProduction()
        }
    }
    
    private fun configureForDevelopment() {
        ZkpKeyManager.allowMockKeys = true
        ZkpKeyManager.enableCertificatePinning = false
        Log.d("Security", "Configured for DEVELOPMENT")
    }
    
    private fun configureForProduction() {
        ZkpKeyManager.allowMockKeys = false
        ZkpKeyManager.enableCertificatePinning = true
        ZkpKeyManager.expectedCertificateHash = getString(R.string.production_cert_hash)
        Log.i("Security", "Configured for PRODUCTION")
        
        // Verify configuration
        verifyProductionSecurity()
    }
    
    private fun verifyProductionSecurity() {
        val keyManager = ZkpKeyManager(this)
        val info = keyManager.getKeyInfo()
        val securityConfig = info["securityConfig"] as Map<String, Boolean>
        
        check(!securityConfig["mockKeysAllowed"]!!) {
            "FATAL: Mock keys are enabled in production build!"
        }
        check(securityConfig["certificatePinningEnabled"]!!) {
            "FATAL: Certificate pinning is disabled in production build!"
        }
        
        Log.i("Security", "✅ Production security configuration verified")
    }
}
```

## Troubleshooting

### "Mock keys are disabled" Error in Development
**Solution**: Enable mock keys for testing:
```kotlin
ZkpKeyManager.allowMockKeys = true
```

### Certificate Pinning Failures
**Solution**: 
1. Verify certificate hash is correct
2. Check if certificate has been renewed
3. Ensure network_security_config.xml is properly configured

### Key Download Failures in Production
**Solution**:
1. Check internet connectivity
2. Verify server URL is correct
3. Ensure HTTPS is being used
4. Check server certificate validity

## Support

For security-related questions or to report vulnerabilities:
- Email: security@activecircuitry.com
- Documentation: https://github.com/active-circuitry/ac-zkp-age-sdk/docs

## License
Copyright © 2026 Active Circuitry Private Ltd.
