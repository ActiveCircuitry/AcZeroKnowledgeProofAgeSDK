/**
 * Active Circuitry ZKP Core - C++ Header
 * 
 * Core Zero-Knowledge Proof operations for age verification.
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 * Author: Zeng Han Jun
 */

#ifndef AC_ZKP_CORE_H
#define AC_ZKP_CORE_H

#include <cstdint>
#include <vector>
#include <string>
#include <memory>

namespace ac_zkp {

/**
 * ZKP Protocol types
 */
enum class Protocol {
    GROTH16,
    PLONK
};

/**
 * Proof generation result
 */
struct ProofResult {
    std::vector<uint8_t> proof_data;
    bool success;
    std::string error_message;
    int64_t generation_time_ms;
};

/**
 * Verification result
 */
struct VerificationResult {
    bool is_valid;
    int64_t verification_time_ms;
    std::string error_message;
};

/**
 * Core ZKP operations class
 */
class ZkpCore {
public:
    ZkpCore();
    ~ZkpCore();

    /**
     * Generates a Groth16 proof for age verification
     * 
     * @param birth_date_millis Birth date in milliseconds since epoch
     * @param minimum_age Minimum age to prove
     * @param proving_key Proving key data
     * @return ProofResult containing proof data or error
     */
    ProofResult generateGroth16Proof(
        int64_t birth_date_millis,
        int32_t minimum_age,
        const std::vector<uint8_t>& proving_key
    );

    /**
     * Generates a PLONK proof for age verification
     * 
     * @param birth_date_millis Birth date in milliseconds since epoch
     * @param minimum_age Minimum age to prove
     * @param proving_key Proving key data
     * @return ProofResult containing proof data or error
     */
    ProofResult generatePlonkProof(
        int64_t birth_date_millis,
        int32_t minimum_age,
        const std::vector<uint8_t>& proving_key
    );

    /**
     * Verifies a Groth16 proof
     * 
     * @param proof_data The proof to verify
     * @param minimum_age Minimum age claimed
     * @param verification_key Verification key data
     * @return VerificationResult indicating validity
     */
    VerificationResult verifyGroth16Proof(
        const std::vector<uint8_t>& proof_data,
        int32_t minimum_age,
        const std::vector<uint8_t>& verification_key
    );

    /**
     * Verifies a PLONK proof
     * 
     * @param proof_data The proof to verify
     * @param minimum_age Minimum age claimed
     * @param verification_key Verification key data
     * @return VerificationResult indicating validity
     */
    VerificationResult verifyPlonkProof(
        const std::vector<uint8_t>& proof_data,
        int32_t minimum_age,
        const std::vector<uint8_t>& verification_key
    );

private:
    class Impl;
    std::unique_ptr<Impl> impl_;
};

} // namespace ac_zkp

#endif // AC_ZKP_CORE_H
