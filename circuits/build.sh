#!/bin/bash
# Build script for Circom circuits
# Copyright (c) 2026 Active Circuitry Private Ltd.

set -e

echo "🔧 Building Age Verification Circuit..."

CIRCUIT_NAME="age_verification"
BUILD_DIR="build"
PTAU_FILE="powersoftau_bn128_12.ptau"

# Create build directory
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Compile circuit
echo "📝 Compiling circuit..."
circom ../${CIRCUIT_NAME}.circom --r1cs --wasm --sym -o .

# Check if Powers of Tau file exists
if [ ! -f "$PTAU_FILE" ]; then
    echo "⚡ Generating Powers of Tau (this takes time)..."
    snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
    snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau \
        --name="AC ZKP Contribution" -v -e="$(openssl rand -hex 32)"
    snarkjs powersoftau prepare phase2 pot12_0001.ptau $PTAU_FILE -v
    rm pot12_0000.ptau pot12_0001.ptau
fi

# Groth16 Setup
echo "🔐 Setting up Groth16..."
snarkjs groth16 setup ${CIRCUIT_NAME}.r1cs $PTAU_FILE \
    ${CIRCUIT_NAME}_groth16.zkey

# Export Groth16 verification key
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_groth16.zkey \
    verification_key_groth16.json

# PLONK Setup
echo "🔐 Setting up PLONK..."
snarkjs plonk setup ${CIRCUIT_NAME}.r1cs $PTAU_FILE \
    ${CIRCUIT_NAME}_plonk.zkey

# Export PLONK verification key
snarkjs zkey export verificationkey ${CIRCUIT_NAME}_plonk.zkey \
    verification_key_plonk.json

echo "✅ Circuit build complete!"
echo ""
echo "Generated files:"
echo "  - ${CIRCUIT_NAME}.r1cs (Rank-1 Constraint System)"
echo "  - ${CIRCUIT_NAME}.wasm (Witness generator)"
echo "  - ${CIRCUIT_NAME}_groth16.zkey (Groth16 proving key)"
echo "  - verification_key_groth16.json (Groth16 verification key)"
echo "  - ${CIRCUIT_NAME}_plonk.zkey (PLONK proving key)"
echo "  - verification_key_plonk.json (PLONK verification key)"
