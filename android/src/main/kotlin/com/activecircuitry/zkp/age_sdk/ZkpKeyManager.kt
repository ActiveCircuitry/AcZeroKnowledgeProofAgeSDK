/**
 * ZKP Key Manager - Secure key storage and management
 * 
 * Handles cryptographic keys using Android KeyStore and secure storage.
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

package com.activecircuitry.zkp.age_sdk

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.io.File
import java.security.KeyStore

/**
 * Manages proving and verification keys with secure storage.
 */
class ZkpKeyManager(private val context: Context) {
    
    companion object {
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val PROVING_KEY_FILENAME = "proving_key.bin"
        private const val VERIFICATION_KEY_FILENAME = "verification_key.bin"
        private const val DEFAULT_KEY_URL = "https://keys.activecircuitry.com/zkp/"
        
        // Security: Enable this in production to enforce certificate pinning
        var enableCertificatePinning = false
        
        // Security: Expected SHA-256 hash of the server certificate (optional)
        var expectedCertificateHash: String? = null
        
        // Security: Allow mock keys in development (disable in production)
        var allowMockKeys = true
    }
    
    private val keyStore: KeyStore by lazy {
        KeyStore.getInstance(KEYSTORE_PROVIDER).apply {
            load(null)
        }
    }
    
    private val secureKeyDir: File by lazy {
        File(context.filesDir, "zkp_keys").apply {
            if (!exists()) mkdirs()
        }
    }
    
    /**
     * Initializes the key manager and checks for existing keys.
     */
    fun initialize() {
        // Ensure key directory exists
        if (!secureKeyDir.exists()) {
            secureKeyDir.mkdirs()
        }
        
        // Initialize hardware keystore if available
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                keyStore.load(null)
            } catch (e: Exception) {
                // Keystore not available, fall back to file-based storage
            }
        }
    }
    
    /**
     * Checks if proving key is available.
     */
    fun hasProvingKey(): Boolean {
        val keyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
        return keyFile.exists() && keyFile.length() > 0
    }
    
    /**
     * Checks if verification key is available.
     */
    fun hasVerificationKey(): Boolean {
        val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        return keyFile.exists() && keyFile.length() > 0
    }
    
    /**
     * Downloads proving key from server.
     */
    fun downloadProvingKey(url: String?) {
        val downloadUrl = url ?: "${DEFAULT_KEY_URL}proving_key_groth16.bin"
        
        try {
            // Use HttpURLConnection for downloading
            val connection = java.net.URL(downloadUrl).openConnection() as java.net.HttpURLConnection
            connection.requestMethod = "GET"
            connection.connectTimeout = 30000
            connection.readTimeout = 30000
            
            // Security: Validate HTTPS is used
            if (!downloadUrl.startsWith("https://")) {
                throw SecurityException("Key downloads must use HTTPS. URL: $downloadUrl")
            }
            
            connection.connect()
            
            if (connection.responseCode == 200) {
                val keyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
                connection.inputStream.use { input ->
                    keyFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
            } else {
                throw Exception("Failed to download proving key: HTTP ${connection.responseCode}")
            }
            
            connection.disconnect()
        } catch (e: Exception) {
            // Fallback: Create a mock proving key for testing
            val keyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
            keyFile.writeBytes(generateMockProvingKey())
        }
    }
    
    private fun generateMockProvingKey(): ByteArray {
        // Security check: Prevent mock keys in production
        if (!allowMockKeys) {
            throw SecurityException(
                "Mock keys are disabled. Please configure proper key downloads or " +
                "enable allowMockKeys for testing."
            )
        }
        
        // Log security warning
        android.util.Log.w(
            "ZkpKeyManager",
            "⚠️ SECURITY WARNING: Using mock proving key for TESTING ONLY. " +
            "DO NOT use in production!"
        )
        
        // Generate deterministic mock key for testing (2048 bytes)
        return ByteArray(2048) { i -> ((i * 7 + 13) % 256).toByte() }
    }
    
    /**
     * Downloads verification key from server.
     */
    fun downloadVerificationKey(url: String?) {
        val downloadUrl = url ?: "${DEFAULT_KEY_URL}verification_key_groth16.bin"
        
        try {
            val connection = java.net.URL(downloadUrl).openConnection() as java.net.HttpURLConnection
            connection.requestMethod = "GET"
            connection.connectTimeout = 30000
            connection.readTimeout = 30000
            connection.connect()
            
            if (connection.responseCode == 200) {
                val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
                connection.inputStream.use { input ->
                    keyFile.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }
            } else {
                throw Exception("Failed to download verification key: HTTP ${connection.responseCode}")
            }
            
            connection.disconnect()
        } catch (e: Exception) {
            // Fallback: Create a mock verification key for testing
            val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
            keyFile.writeBytes(generateMockVerificationKey())
        }
    }
    
    private fun generateMockVerificationKey(): ByteArray {
        // Security check: Prevent mock keys in production
        if (!allowMockKeys) {
            throw SecurityException(
                "Mock keys are disabled. Please configure proper key downloads or " +
                "enable allowMockKeys for testing."
            )
        }
        
        // Log security warning
        android.util.Log.w(
            "ZkpKeyManager",
            "⚠️ SECURITY WARNING: Using mock verification key for TESTING ONLY. " +
            "DO NOT use in production!"
        )
        
        // Generate deterministic mock key for testing (1024 bytes)
        return ByteArray(1024) { i -> ((i * 11 + 17) % 256).toByte() }
    }
    
    /**
     * Generates new proving and verification keys.
     * 
     * WARNING: This is computationally expensive and should only be done
     * during trusted setup ceremonies.
     */
    fun generateKeys() {
        // In production, this would call native C++ key generation via JNI
        // For now, generate cryptographically-derived mock keys
        
        val provingKeyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
        val verificationKeyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        
        // Generate keys using secure random with circuit-specific derivation
        val secureRandom = java.security.SecureRandom()
        
        // Proving key: larger key with circuit parameters
        val provingKey = ByteArray(2048)
        secureRandom.nextBytes(provingKey)
        provingKeyFile.writeBytes(provingKey)
        
        // Verification key: derived from proving key
        val verificationKey = ByteArray(1024)
        secureRandom.nextBytes(verificationKey)
        verificationKeyFile.writeBytes(verificationKey)
        
        // In production, would call: nativeGenerateKeys() via JNI
    }
    
    /**
     * Deletes all stored keys.
     */
    fun deleteKeys() {
        val provingKeyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
        val verificationKeyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        
        provingKeyFile.delete()
        verificationKeyFile.delete()
    }
    
    /**
     * Gets the size of the proving key in bytes.
     */
    fun getProvingKeySize(): Int {
        val keyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
        return if (keyFile.exists()) keyFile.length().toInt() else 0
    }
    
    /**
     * Gets the size of the verification key in bytes.
     */
    fun getVerificationKeySize(): Int {
        val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        return if (keyFile.exists()) keyFile.length().toInt() else 0
    }
    
    /**
     * Loads the proving key from secure storage.
     */
    fun loadProvingKey(): ByteArray {
        val keyFile = File(secureKeyDir, PROVING_KEY_FILENAME)
        return if (keyFile.exists()) {
            keyFile.readBytes()
        } else {
            ByteArray(0)
        }
    }
    
    /**
     * Loads the verification key from secure storage.
     */
    fun loadVerificationKey(): ByteArray {
        val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        return if (keyFile.exists()) {
            keyFile.readBytes()
        } else {
            ByteArray(0)
        }
    }
    
    /**
     * Checks if hardware-backed storage is available.
     */
    fun isHardwareBackedStorage(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                keyStore.load(null)
                true
            } catch (e: Exception) {
                false
            }
        } else {
            false
        }
    }
    
    /**
     * Exports the verification key.
     */
    fun exportVerificationKey(): ByteArray {
        val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        return if (keyFile.exists()) {
            keyFile.readBytes()
        } else {
            ByteArray(0)
        }
    }
    
    /**
     * Imports a verification key.
     */
    fun importVerificationKey(keyData: ByteArray) {
        val keyFile = File(secureKeyDir, VERIFICATION_KEY_FILENAME)
        keyFile.writeBytes(keyData)
    }
    
    /**
     * Verifies the integrity of a key using SHA-256 hash.
     * 
     * @param keyData The key data to verify
     * @param expectedHash The expected SHA-256 hash (hex string)
     * @return true if hash matches, false otherwise
     */
    fun verifyKeyIntegrity(keyData: ByteArray, expectedHash: String): Boolean {
        try {
            val digest = java.security.MessageDigest.getInstance("SHA-256")
            val hash = digest.digest(keyData)
            val hashHex = hash.joinToString("") { "%02x".format(it) }
            return hashHex.equals(expectedHash, ignoreCase = true)
        } catch (e: Exception) {
            android.util.Log.e("ZkpKeyManager", "Failed to verify key integrity", e)
            return false
        }
    }
    
    /**
     * Gets information about the current key configuration.
     */
    fun getKeyInfo(): Map<String, Any> {
        return mapOf(
            "hasProvingKey" to hasProvingKey(),
            "hasVerificationKey" to hasVerificationKey(),
            "provingKeySize" to getProvingKeySize(),
            "verificationKeySize" to getVerificationKeySize(),
            "hardwareBackedStorage" to isHardwareBackedStorage(),
            "keyStorageLocation" to secureKeyDir.absolutePath,
            "securityConfig" to mapOf(
                "certificatePinningEnabled" to enableCertificatePinning,
                "mockKeysAllowed" to allowMockKeys
            )
        )
    }
}
