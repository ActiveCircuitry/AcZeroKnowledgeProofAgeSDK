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
        throw UnsupportedOperationException(
            "Key downloads are disabled until a provider trust and signed artifact policy is configured."
        )
    }
    
    /**
     * Downloads verification key from server.
     */
    fun downloadVerificationKey(url: String?) {
        throw UnsupportedOperationException(
            "Key downloads are disabled until a provider trust and signed artifact policy is configured."
        )
    }
    
    /**
     * Generates new proving and verification keys.
     * 
     * WARNING: This is computationally expensive and should only be done
     * during trusted setup ceremonies.
     */
    fun generateKeys() {
        throw UnsupportedOperationException(
            "Trusted setup and key generation must not run in the mobile application."
        )
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
        return false
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
        throw UnsupportedOperationException(
            "Key import is disabled until provider trust and artifact validation are configured."
        )
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
            "keyStorageLocation" to secureKeyDir.absolutePath
        )
    }
}
