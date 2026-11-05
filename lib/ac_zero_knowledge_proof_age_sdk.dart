/// Active Circuitry Zero Knowledge Age Verification SDK
///
/// A privacy-preserving age verification library using Zero-Knowledge Proofs.
/// This SDK enables Android applications to verify user ages without exposing
/// sensitive personal information like birth dates or identity documents.
///
/// ## Features
/// - Groth16 and PLONK ZKP protocols
/// - Hardware-backed security (Android KeyStore, TEE)
/// - Multiple age threshold support (13+, 16+, 18+, 21+)
/// - Async proof generation and verification
/// - Small proof size (~200 bytes for Groth16)
///
/// ## Example Usage
/// ```dart
/// import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
///
/// // Generate age proof
/// final generator = AgeProofGenerator();
/// final proof = await generator.generateAgeProof(
///   birthDate: DateTime(1990, 1, 1),
///   minimumAge: 18,
///   protocol: ZKPProtocol.groth16,
/// );
///
/// // Verify proof
/// final verifier = AgeProofVerifier();
/// final isValid = await verifier.verifyAgeProof(proof);
/// ```
///
/// Author: Zeng Han Jun
/// Copyright (c) 2026 Active Circuitry Private Ltd.
library ac_zero_knowledge_proof_age_sdk;

export 'src/age_proof_generator.dart';
export 'src/age_proof_verifier.dart';
export 'src/key_manager.dart';
export 'src/models/age_proof.dart';
export 'src/models/zkp_protocol.dart';
export 'src/models/age_threshold.dart';
export 'src/models/proof_result.dart';
export 'src/models/age_credential.dart';
export 'src/credentials/age_credential_provider.dart';
export 'src/exceptions/zkp_exception.dart';
export 'src/platform/ac_zkp_platform_interface.dart';
