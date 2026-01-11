/**
 * Active Circuitry Zero Knowledge Age Verification SDK
 * 
 * Main Android plugin class that bridges Flutter and native ZKP implementations.
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

package com.activecircuitry.zkp.age_sdk

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.security.KeyStore
import java.util.*

/**
 * Main plugin class for Active Circuitry ZKP Age SDK.
 */
class AcZeroKnowledgeProofAgeSdkPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private lateinit var zkpCore: ZkpCore
    private lateinit var keyManager: ZkpKeyManager
    
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    companion object {
        const val METHOD_CHANNEL = "ac_zero_knowledge_proof_age_sdk"
        const val EVENT_CHANNEL = "ac_zero_knowledge_proof_age_sdk/progress"
        const val SDK_VERSION = "0.1.0"
        
        init {
            System.loadLibrary("ac_zkp_native")
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, EVENT_CHANNEL)
        
        zkpCore = ZkpCore(context)
        keyManager = ZkpKeyManager(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "generateAgeProof" -> handleGenerateAgeProof(call, result)
            "verifyAgeProof" -> handleVerifyAgeProof(call, result)
            "validateProofStructure" -> handleValidateProofStructure(call, result)
            "estimateProofTime" -> handleEstimateProofTime(call, result)
            "estimateVerificationTime" -> handleEstimateVerificationTime(call, result)
            "isHardwareSecurityAvailable" -> handleIsHardwareSecurityAvailable(result)
            
            // Key management
            "initializeKeys" -> handleInitializeKeys(result)
            "hasProvingKey" -> handleHasProvingKey(result)
            "hasVerificationKey" -> handleHasVerificationKey(result)
            "downloadProvingKey" -> handleDownloadProvingKey(call, result)
            "downloadVerificationKey" -> handleDownloadVerificationKey(call, result)
            "generateKeys" -> handleGenerateKeys(result)
            "deleteKeys" -> handleDeleteKeys(result)
            "getProvingKeySize" -> handleGetProvingKeySize(result)
            "getVerificationKeySize" -> handleGetVerificationKeySize(result)
            "isHardwareBackedStorage" -> handleIsHardwareBackedStorage(result)
            "exportVerificationKey" -> handleExportVerificationKey(result)
            "importVerificationKey" -> handleImportVerificationKey(call, result)
            "getKeyInfo" -> handleGetKeyInfo(result)
            
            else -> result.notImplemented()
        }
    }

    private fun handleGenerateAgeProof(call: MethodCall, result: Result) {
        coroutineScope.launch {
            try {
                val birthDate = call.argument<String>("birthDate")
                val minimumAge = call.argument<Int>("minimumAge")
                val protocol = call.argument<String>("protocol")
                val useHardwareSecurity = call.argument<Boolean>("useHardwareSecurity") ?: true

                if (birthDate == null || minimumAge == null || protocol == null) {
                    result.error("INVALID_ARGS", "Missing required arguments", null)
                    return@launch
                }

                // Delegate to ZkpCore for actual proof generation
                val proof = withContext(Dispatchers.IO) {
                    zkpCore.generateAgeProof(
                        birthDate = birthDate,
                        minimumAge = minimumAge,
                        protocol = protocol,
                        useHardwareSecurity = useHardwareSecurity
                    )
                }

                result.success(proof)
            } catch (e: Exception) {
                result.error("GENERATION_ERROR", "Failed to generate proof: ${e.message}", null)
            }
        }
    }

    private fun handleVerifyAgeProof(call: MethodCall, result: Result) {
        coroutineScope.launch {
            try {
                val proofData = call.argument<ByteArray>("proofData")
                val minimumAge = call.argument<Int>("minimumAge")
                val protocol = call.argument<String>("protocol")

                if (proofData == null || minimumAge == null || protocol == null) {
                    result.error("INVALID_ARGS", "Missing required arguments", null)
                    return@launch
                }

                val verificationResult = withContext(Dispatchers.IO) {
                    zkpCore.verifyAgeProof(proofData, minimumAge, protocol)
                }

                result.success(verificationResult)
            } catch (e: Exception) {
                result.error("VERIFICATION_ERROR", "Failed to verify proof: ${e.message}", null)
            }
        }
    }

    private fun handleValidateProofStructure(call: MethodCall, result: Result) {
        try {
            val proofData = call.argument<ByteArray>("proofData")
            val minimumAge = call.argument<Int>("minimumAge")
            val protocol = call.argument<String>("protocol")

            if (proofData == null || minimumAge == null || protocol == null) {
                result.success(false)
                return
            }

            val isValid = zkpCore.validateProofStructure(proofData, minimumAge, protocol)
            result.success(isValid)
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun handleEstimateProofTime(call: MethodCall, result: Result) {
        val protocol = call.argument<String>("protocol")
        val estimatedTime = when (protocol) {
            "groth16" -> 5000
            "plonk" -> 8000
            else -> 6000
        }
        result.success(estimatedTime)
    }

    private fun handleEstimateVerificationTime(call: MethodCall, result: Result) {
        val protocol = call.argument<String>("protocol")
        val estimatedTime = when (protocol) {
            "groth16" -> 10
            "plonk" -> 50
            else -> 30
        }
        result.success(estimatedTime)
    }

    private fun handleIsHardwareSecurityAvailable(result: Result) {
        val isAvailable = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val keyStore = KeyStore.getInstance("AndroidKeyStore")
                keyStore.load(null)
                true
            } catch (e: Exception) {
                false
            }
        } else {
            false
        }
        result.success(isAvailable)
    }

    // Key management handlers
    
    private fun handleInitializeKeys(result: Result) {
        coroutineScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    keyManager.initialize()
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("KEY_INIT_ERROR", "Failed to initialize keys: ${e.message}", null)
            }
        }
    }

    private fun handleHasProvingKey(result: Result) {
        result.success(keyManager.hasProvingKey())
    }

    private fun handleHasVerificationKey(result: Result) {
        result.success(keyManager.hasVerificationKey())
    }

    private fun handleDownloadProvingKey(call: MethodCall, result: Result) {
        coroutineScope.launch {
            try {
                val url = call.argument<String>("url")
                withContext(Dispatchers.IO) {
                    keyManager.downloadProvingKey(url)
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("DOWNLOAD_ERROR", "Failed to download proving key: ${e.message}", null)
            }
        }
    }

    private fun handleDownloadVerificationKey(call: MethodCall, result: Result) {
        coroutineScope.launch {
            try {
                val url = call.argument<String>("url")
                withContext(Dispatchers.IO) {
                    keyManager.downloadVerificationKey(url)
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("DOWNLOAD_ERROR", "Failed to download verification key: ${e.message}", null)
            }
        }
    }

    private fun handleGenerateKeys(result: Result) {
        coroutineScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    keyManager.generateKeys()
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("KEYGEN_ERROR", "Failed to generate keys: ${e.message}", null)
            }
        }
    }

    private fun handleDeleteKeys(result: Result) {
        try {
            keyManager.deleteKeys()
            result.success(null)
        } catch (e: Exception) {
            result.error("DELETE_ERROR", "Failed to delete keys: ${e.message}", null)
        }
    }

    private fun handleGetProvingKeySize(result: Result) {
        result.success(keyManager.getProvingKeySize())
    }

    private fun handleGetVerificationKeySize(result: Result) {
        result.success(keyManager.getVerificationKeySize())
    }

    private fun handleIsHardwareBackedStorage(result: Result) {
        result.success(keyManager.isHardwareBackedStorage())
    }

    private fun handleExportVerificationKey(result: Result) {
        try {
            val keyData = keyManager.exportVerificationKey()
            result.success(keyData)
        } catch (e: Exception) {
            result.error("EXPORT_ERROR", "Failed to export verification key: ${e.message}", null)
        }
    }

    private fun handleImportVerificationKey(call: MethodCall, result: Result) {
        try {
            val keyData = call.argument<ByteArray>("keyData")
            if (keyData == null) {
                result.error("INVALID_ARGS", "Key data is required", null)
                return
            }
            keyManager.importVerificationKey(keyData)
            result.success(null)
        } catch (e: Exception) {
            result.error("IMPORT_ERROR", "Failed to import verification key: ${e.message}", null)
        }
    }

    private fun handleGetKeyInfo(result: Result) {
        try {
            val info = keyManager.getKeyInfo()
            result.success(info)
        } catch (e: Exception) {
            result.error("INFO_ERROR", "Failed to get key info: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        coroutineScope.cancel()
    }
}
