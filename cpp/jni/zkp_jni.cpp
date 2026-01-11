/**
 * Active Circuitry ZKP - JNI Bridge
 * 
 * Java Native Interface bridge between Android/Java and C++ ZKP core.
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

#include <jni.h>
#include <string>
#include <vector>
#include "ac_zkp_core.h"
#include <android/log.h>

#define LOG_TAG "AcZkpNative"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

using namespace ac_zkp;

// Helper function to convert jbyteArray to std::vector<uint8_t>
std::vector<uint8_t> jbyteArrayToVector(JNIEnv* env, jbyteArray array) {
    jsize length = env->GetArrayLength(array);
    std::vector<uint8_t> vector(length);
    env->GetByteArrayRegion(array, 0, length, reinterpret_cast<jbyte*>(vector.data()));
    return vector;
}

// Helper function to convert std::vector<uint8_t> to jbyteArray
jbyteArray vectorToJbyteArray(JNIEnv* env, const std::vector<uint8_t>& vector) {
    jbyteArray array = env->NewByteArray(vector.size());
    env->SetByteArrayRegion(array, 0, vector.size(), reinterpret_cast<const jbyte*>(vector.data()));
    return array;
}

extern "C" {

JNIEXPORT jbyteArray JNICALL
Java_com_activecircuitry_zkp_age_1sdk_ZkpCore_nativeGenerateGroth16Proof(
    JNIEnv* env,
    jobject /* this */,
    jlong birthDateMillis,
    jint minimumAge,
    jbyteArray provingKeyData
) {
    LOGD("Generating Groth16 proof: age=%d", minimumAge);
    
    try {
        std::vector<uint8_t> proving_key = jbyteArrayToVector(env, provingKeyData);
        
        ZkpCore core;
        ProofResult result = core.generateGroth16Proof(
            birthDateMillis,
            minimumAge,
            proving_key
        );
        
        if (!result.success) {
            LOGE("Proof generation failed: %s", result.error_message.c_str());
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, result.error_message.c_str());
            return nullptr;
        }
        
        LOGD("Proof generated successfully: %zu bytes in %lld ms",
             result.proof_data.size(), result.generation_time_ms);
        
        return vectorToJbyteArray(env, result.proof_data);
    } catch (const std::exception& e) {
        LOGE("Exception in proof generation: %s", e.what());
        jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
        env->ThrowNew(exceptionClass, e.what());
        return nullptr;
    }
}

JNIEXPORT jbyteArray JNICALL
Java_com_activecircuitry_zkp_age_1sdk_ZkpCore_nativeGeneratePlonkProof(
    JNIEnv* env,
    jobject /* this */,
    jlong birthDateMillis,
    jint minimumAge,
    jbyteArray provingKeyData
) {
    LOGD("Generating PLONK proof: age=%d", minimumAge);
    
    try {
        std::vector<uint8_t> proving_key = jbyteArrayToVector(env, provingKeyData);
        
        ZkpCore core;
        ProofResult result = core.generatePlonkProof(
            birthDateMillis,
            minimumAge,
            proving_key
        );
        
        if (!result.success) {
            LOGE("Proof generation failed: %s", result.error_message.c_str());
            jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
            env->ThrowNew(exceptionClass, result.error_message.c_str());
            return nullptr;
        }
        
        LOGD("Proof generated successfully: %zu bytes in %lld ms",
             result.proof_data.size(), result.generation_time_ms);
        
        return vectorToJbyteArray(env, result.proof_data);
    } catch (const std::exception& e) {
        LOGE("Exception in proof generation: %s", e.what());
        jclass exceptionClass = env->FindClass("java/lang/RuntimeException");
        env->ThrowNew(exceptionClass, e.what());
        return nullptr;
    }
}

JNIEXPORT jboolean JNICALL
Java_com_activecircuitry_zkp_age_1sdk_ZkpCore_nativeVerifyGroth16Proof(
    JNIEnv* env,
    jobject /* this */,
    jbyteArray proofData,
    jint minimumAge,
    jbyteArray verificationKeyData
) {
    LOGD("Verifying Groth16 proof: age=%d", minimumAge);
    
    try {
        std::vector<uint8_t> proof = jbyteArrayToVector(env, proofData);
        std::vector<uint8_t> verification_key = jbyteArrayToVector(env, verificationKeyData);
        
        ZkpCore core;
        VerificationResult result = core.verifyGroth16Proof(
            proof,
            minimumAge,
            verification_key
        );
        
        LOGD("Verification result: %s (took %lld ms)",
             result.is_valid ? "VALID" : "INVALID",
             result.verification_time_ms);
        
        return result.is_valid ? JNI_TRUE : JNI_FALSE;
    } catch (const std::exception& e) {
        LOGE("Exception in proof verification: %s", e.what());
        return JNI_FALSE;
    }
}

JNIEXPORT jboolean JNICALL
Java_com_activecircuitry_zkp_age_1sdk_ZkpCore_nativeVerifyPlonkProof(
    JNIEnv* env,
    jobject /* this */,
    jbyteArray proofData,
    jint minimumAge,
    jbyteArray verificationKeyData
) {
    LOGD("Verifying PLONK proof: age=%d", minimumAge);
    
    try {
        std::vector<uint8_t> proof = jbyteArrayToVector(env, proofData);
        std::vector<uint8_t> verification_key = jbyteArrayToVector(env, verificationKeyData);
        
        ZkpCore core;
        VerificationResult result = core.verifyPlonkProof(
            proof,
            minimumAge,
            verification_key
        );
        
        LOGD("Verification result: %s (took %lld ms)",
             result.is_valid ? "VALID" : "INVALID",
             result.verification_time_ms);
        
        return result.is_valid ? JNI_TRUE : JNI_FALSE;
    } catch (const std::exception& e) {
        LOGE("Exception in proof verification: %s", e.what());
        return JNI_FALSE;
    }
}

} // extern "C"
