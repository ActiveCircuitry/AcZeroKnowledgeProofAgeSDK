/**
 * ZKP Core - Native C++ interface for Zero-Knowledge Proof operations
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

package com.activecircuitry.zkp.age_sdk

import android.content.Context
import com.google.gson.Gson
import java.util.*

/**
 * Core ZKP operations interfacing with C++ native implementation.
 */
class ZkpCore(private val context: Context) {
    
    private val gson = Gson()
    
    // Native method declarations
    private external fun nativeGenerateGroth16Proof(
        birthDateMillis: Long,
        minimumAge: Int,
        provingKeyData: ByteArray
    ): ByteArray
    
    private external fun nativeGeneratePlonkProof(
        birthDateMillis: Long,
        minimumAge: Int,
        provingKeyData: ByteArray
    ): ByteArray
    
    private external fun nativeVerifyGroth16Proof(
        proofData: ByteArray,
        minimumAge: Int,
        verificationKeyData: ByteArray
    ): Boolean
    
    private external fun nativeVerifyPlonkProof(
        proofData: ByteArray,
        minimumAge: Int,
        verificationKeyData: ByteArray
    ): Boolean
    
    /**
     * Generates an age proof using the specified protocol.
     */
    fun generateAgeProof(
        birthDate: String,
        minimumAge: Int,
        protocol: String,
        useHardwareSecurity: Boolean
    ): Map<String, Any> {
        val startTime = System.currentTimeMillis()
        
        // Parse birth date
        val birthDateMillis = parseIso8601(birthDate)
        
        // Load proving key from secure storage
        val keyManager = ZkpKeyManager(context)
        val provingKeyData = keyManager.loadProvingKey()
        if (provingKeyData.isEmpty()) {
            throw IllegalStateException("Proving key not found. Please initialize keys first.")
        }
        
        // Generate proof using native implementation
        val proofData = when (protocol.lowercase()) {
            "groth16" -> nativeGenerateGroth16Proof(birthDateMillis, minimumAge, provingKeyData)
            "plonk" -> nativeGeneratePlonkProof(birthDateMillis, minimumAge, provingKeyData)
            else -> throw IllegalArgumentException("Unsupported protocol: $protocol")
        }
        
        val endTime = System.currentTimeMillis()
        val generationTime = (endTime - startTime).toInt()
        
        // Build proof result
        return mapOf(
            "proofData" to proofData,
            "minimumAge" to minimumAge,
            "protocol" to protocol,
            "generatedAt" to Date().toInstant().toString(),
            "proofId" to UUID.randomUUID().toString(),
            "sdkVersion" to AcZeroKnowledgeProofAgeSdkPlugin.SDK_VERSION,
            "metadata" to mapOf(
                "generationTimeMs" to generationTime,
                "hardwareSecurityUsed" to useHardwareSecurity
            )
        )
    }
    
    /**
     * Verifies an age proof using the specified protocol.
     */
    fun verifyAgeProof(
        proofData: ByteArray,
        minimumAge: Int,
        protocol: String
    ): Map<String, Any> {
        val startTime = System.currentTimeMillis()
        
        // Load verification key from storage
        val keyManager = ZkpKeyManager(context)
        val verificationKeyData = keyManager.loadVerificationKey()
        if (verificationKeyData.isEmpty()) {
            throw IllegalStateException("Verification key not found. Please initialize keys first.")
        }
        
        // Verify proof using native implementation
        val isValid = when (protocol.lowercase()) {
            "groth16" -> nativeVerifyGroth16Proof(proofData, minimumAge, verificationKeyData)
            "plonk" -> nativeVerifyPlonkProof(proofData, minimumAge, verificationKeyData)
            else -> throw IllegalArgumentException("Unsupported protocol: $protocol")
        }
        
        val endTime = System.currentTimeMillis()
        val verificationTime = (endTime - startTime).toInt()
        
        return mapOf(
            "isValid" to isValid,
            "minimumAge" to minimumAge,
            "protocol" to protocol,
            "verifiedAt" to Date().toInstant().toString(),
            "verificationTimeMs" to verificationTime
        )
    }
    
    /**
     * Validates the structure of a proof without full cryptographic verification.
     */
    fun validateProofStructure(
        proofData: ByteArray,
        minimumAge: Int,
        protocol: String
    ): Boolean {
        // Basic validation checks
        if (proofData.isEmpty()) return false
        if (minimumAge < 0 || minimumAge > 150) return false
        
        // Protocol-specific size checks
        val expectedSize = when (protocol.lowercase()) {
            "groth16" -> 200 // ~200 bytes for Groth16
            "plonk" -> 500   // ~500 bytes for PLONK
            else -> return false
        }
        
        // Allow some variance in proof size
        return proofData.size in (expectedSize - 100)..(expectedSize + 100)
    }
    
    private fun parseIso8601(dateString: String): Long {
        // Parse ISO 8601 date string to milliseconds
        return try {
            val instant = java.time.Instant.parse(dateString)
            instant.toEpochMilli()
        } catch (e: Exception) {
            throw IllegalArgumentException("Invalid date format: $dateString")
        }
    }
}
