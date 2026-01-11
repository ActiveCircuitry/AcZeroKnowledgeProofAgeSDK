# Security Quick Reference

## TL;DR for Developers

### Development (Default - Ready to Use)
```dart
// ✅ Just works - no configuration needed
final generator = AgeProofGenerator();
final proof = await generator.generateAgeProof(
  birthDate: DateTime(1990, 1, 1),
  minimumAge: 18,
);
```

### Production (2 Lines to Secure)
```kotlin
// In your Application.onCreate() - That's it!
ZkpKeyManager.allowMockKeys = false        // Line 1: Disable test keys
ZkpKeyManager.enableCertificatePinning = true  // Line 2: Enable security
```

---

## Security Features (All Optional, Pick What You Need)

| Feature | Dev Default | Prod Recommended | Complexity |
|---------|-------------|------------------|------------|
| **Mock Keys Protection** | ✅ Enabled | ❌ Disabled | 🟢 Easy |
| **HTTPS Enforcement** | ✅ Always On | ✅ Always On | 🟢 Easy |
| **Certificate Pinning** | ❌ Off | ✅ On | 🟡 Medium |
| **Key Integrity Check** | ❌ Optional | ⭐ Recommended | 🟡 Medium |
| **Network Security Config** | ❌ Optional | ⭐ Recommended | 🟢 Easy |

---

## 30-Second Production Setup

### Step 1: Disable Mock Keys (Required)
```kotlin
// Application.kt
class MyApp : Application() {
    override fun onCreate() {
        super.onCreate()
        ZkpKeyManager.allowMockKeys = false  // ⚠️ IMPORTANT
    }
}
```

### Step 2: Enable Certificate Pinning (Recommended)
```kotlin
ZkpKeyManager.enableCertificatePinning = true
```

### Step 3: Done! 🎉
Your app is now production-ready with secure configuration.

---

## Advanced: Build-Variant Auto-Configuration

### One-Time Setup in build.gradle:
```gradle
android {
    buildTypes {
        debug {
            buildConfigField "boolean", "ALLOW_MOCK_KEYS", "true"
        }
        release {
            buildConfigField "boolean", "ALLOW_MOCK_KEYS", "false"
        }
    }
}
```

### Auto-Configure in Application:
```kotlin
ZkpKeyManager.allowMockKeys = BuildConfig.ALLOW_MOCK_KEYS  // Auto!
```

---

## What Happens if You Forget?

### ⚠️ Mock Keys in Production
```
SecurityException: Mock keys are disabled. 
Please configure proper key downloads.
```
**Solution**: Check your key server is accessible or enable `allowMockKeys` for testing

### ⚠️ Key Download Fails
```
Exception: Failed to download proving key: HTTP 404
```
**Solution**: 
- Verify internet connection
- Check server URL configuration
- In development, mock keys will be used automatically (with warning)

---

## Security Checklist (Copy-Paste Ready)

```kotlin
// ✅ Production Pre-Flight Check
fun verifyProductionSecurity() {
    check(!ZkpKeyManager.allowMockKeys) { 
        "❌ FAIL: Mock keys enabled in production!" 
    }
    check(ZkpKeyManager.enableCertificatePinning) { 
        "⚠️ WARNING: Certificate pinning disabled" 
    }
    println("✅ Production security verified")
}
```

---

## Common Patterns

### Pattern 1: Auto-Configure by Build Type
```kotlin
when (BuildConfig.BUILD_TYPE) {
    "debug" -> configureForDev()
    "release" -> configureForProduction()
}

fun configureForDev() {
    ZkpKeyManager.allowMockKeys = true
    ZkpKeyManager.enableCertificatePinning = false
}

fun configureForProduction() {
    ZkpKeyManager.allowMockKeys = false
    ZkpKeyManager.enableCertificatePinning = true
}
```

### Pattern 2: Flavor-Based Configuration
```kotlin
// productionFlavor
ZkpKeyManager.allowMockKeys = false

// stagingFlavor  
ZkpKeyManager.allowMockKeys = true  // Allow fallback
```

### Pattern 3: Remote Config
```kotlin
// Fetch from Firebase Remote Config or similar
val config = remoteConfig.getBoolean("zkp_allow_mock_keys")
ZkpKeyManager.allowMockKeys = config
```

---

## Security Warnings You'll See

### 🟢 Development (Expected)
```
⚠️ SECURITY WARNING: Using mock proving key for TESTING ONLY. 
DO NOT use in production!
```
**Action**: None needed in development

### 🔴 Production (Fix Immediately)
```
⚠️ SECURITY WARNING: Certificate pinning is disabled
⚠️ SECURITY WARNING: Mock keys are allowed
```
**Action**: Enable security features ASAP

---

## Testing Security Configuration

```kotlin
@Test
fun `verify production security config`() {
    // Simulate production build
    ZkpKeyManager.allowMockKeys = false
    ZkpKeyManager.enableCertificatePinning = true
    
    val keyManager = ZkpKeyManager(context)
    val info = keyManager.getKeyInfo()
    val security = info["securityConfig"] as Map<String, Boolean>
    
    assertFalse(security["mockKeysAllowed"]!!)
    assertTrue(security["certificatePinningEnabled"]!!)
}
```

---

## Need Help?

- 📖 **Full Guide**: [SECURITY_CONFIGURATION.md](SECURITY_CONFIGURATION.md)
- 🐛 **Issues**: support@activecircuitry.com
- 🔒 **Security**: security@activecircuitry.com

---

## Remember

### ✅ Development First
- SDK works immediately with sensible defaults
- Mock keys enable fast testing
- Security warnings guide you

### 🔒 Production Ready
- 2 lines of code to secure
- Automatic safety checks
- Clear error messages

**Philosophy**: Easy to develop with, hard to mess up in production.
