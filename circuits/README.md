# Circom Circuits for Active Circuitry ZKP Age SDK

This directory contains the Zero-Knowledge Proof circuits for age verification.

## Overview

The circuits are written in [Circom](https://docs.circom.io/), a domain-specific language for defining arithmetic circuits used in ZKP systems.

## Circuit: `age_verification.circom`

### Purpose
Proves that a user's age meets or exceeds a minimum threshold without revealing the actual birth date.

### Inputs

**Private (Hidden from verifier):**
- `birthDateTimestamp`: User's birth date as Unix timestamp

**Public (Visible to verifier):**
- `currentTimestamp`: Current date as Unix timestamp
- `minimumAge`: Required minimum age in years

### Output
- `isValid`: 1 if age ≥ minimum, 0 otherwise

### Constraints
1. Birth date must be in the past
2. Minimum age must be reasonable (0-150 years)
3. Age calculation uses approximate year length (365.25 days)

## Building the Circuit

### Prerequisites

```bash
# Install Circom compiler
npm install -g circom

# Install snarkjs for Groth16/PLONK
npm install -g snarkjs
```

### Compilation Steps

```bash
# Compile circuit
circom age_verification.circom --r1cs --wasm --sym

# Generate witness
node age_verification_js/generate_witness.js \
  age_verification_js/age_verification.wasm \
  input.json \
  witness.wtns

# Groth16: Powers of Tau ceremony (one-time)
snarkjs powersoftau new bn128 12 pot12_0000.ptau
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau \
  --name="First contribution" -v

# Groth16: Setup
snarkjs groth16 setup age_verification.r1cs pot12_0001.ptau \
  age_verification_0000.zkey

# Groth16: Export verification key
snarkjs zkey export verificationkey age_verification_0000.zkey \
  verification_key.json

# Groth16: Generate proof
snarkjs groth16 prove age_verification_0000.zkey witness.wtns \
  proof.json public.json

# Groth16: Verify proof
snarkjs groth16 verify verification_key.json public.json proof.json
```

## PLONK Setup (Alternative to Groth16)

```bash
# PLONK: Setup (universal, reusable)
snarkjs plonk setup age_verification.r1cs pot12_final.ptau \
  age_verification_final.zkey

# PLONK: Export verification key
snarkjs zkey export verificationkey age_verification_final.zkey \
  verification_key_plonk.json

# PLONK: Generate proof
snarkjs plonk prove age_verification_final.zkey witness.wtns \
  proof_plonk.json public_plonk.json

# PLONK: Verify proof
snarkjs plonk verify verification_key_plonk.json \
  public_plonk.json proof_plonk.json
```

## Example Input

```json
{
  "birthDateTimestamp": "631152000",
  "currentTimestamp": "1736640000",
  "minimumAge": "18"
}
```

## Integration with SDK

The compiled circuit outputs (.zkey, .wasm files) are integrated into the SDK:

1. **Proving keys** (`.zkey`) → Stored in Android secure storage
2. **WASM witness generator** → Embedded in C++ native layer
3. **Verification keys** → Distributed via key management service

## Security Considerations

1. **Trusted Setup**: Groth16 requires circuit-specific trusted setup
2. **Key Distribution**: Proving keys must be downloaded securely (HTTPS + checksum)
3. **Input Validation**: Always validate timestamp ranges
4. **Side Channels**: Timing attacks mitigated by constant-time operations

## Performance

| Protocol | Circuit Constraints | Proof Generation | Verification | Proof Size |
|----------|---------------------|------------------|--------------|------------|
| Groth16  | ~2,000             | 3-5 seconds      | 5-10ms       | 192 bytes  |
| PLONK    | ~2,000             | 5-8 seconds      | 30-50ms      | 480 bytes  |

## References

- [Circom Documentation](https://docs.circom.io/)
- [snarkjs Library](https://github.com/iden3/snarkjs)
- [Groth16 Paper](https://eprint.iacr.org/2016/260.pdf)
- [PLONK Paper](https://eprint.iacr.org/2019/953.pdf)

---

**Copyright © 2026 Active Circuitry Private Ltd.**  
**Author: Zeng Han Jun**
