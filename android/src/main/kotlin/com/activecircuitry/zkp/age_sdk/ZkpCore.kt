/**
 * Legacy proof API retained for source compatibility while a real provider
 * credential verifier is selected and integrated.
 */
@Suppress("UNUSED_PARAMETER")
class ZkpCore(context: android.content.Context) {
    fun generateAgeProof(
        birthDate: String,
        minimumAge: Int,
        protocol: String,
        useHardwareSecurity: Boolean,
    ): Map<String, Any> = unavailable()

    fun verifyAgeProof(
        proofData: ByteArray,
        minimumAge: Int,
        protocol: String,
    ): Map<String, Any> = unavailable()

    fun validateProofStructure(
        proofData: ByteArray,
        minimumAge: Int,
        protocol: String,
    ): Boolean = unavailable()

    private fun unavailable(): Nothing {
        throw UnsupportedOperationException(
            "The simulated proof backend is disabled. Configure a trusted age credential verifier."
        )
    }
}
