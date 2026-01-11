/**
 * Verify Proof Screen
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/material.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

class VerifyProofScreen extends StatefulWidget {
  const VerifyProofScreen({super.key});

  @override
  State<VerifyProofScreen> createState() => _VerifyProofScreenState();
}

class _VerifyProofScreenState extends State<VerifyProofScreen> {
  bool _isVerifying = false;
  ProofResult? _verificationResult;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Age Proof'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildScanOptions(),
            if (_isVerifying) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_verificationResult != null) ...[
              const SizedBox(height: 24),
              _buildVerificationResult(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              _buildErrorCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'How Verification Works',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Scan a QR code or import a proof to verify age without '
              'revealing the person\'s birth date or identity.',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptions() {
    return Column(
      children: [
        _buildOptionCard(
          icon: Icons.qr_code_scanner,
          title: 'Scan QR Code',
          description: 'Scan a QR code containing an age proof',
          color: Colors.blue,
          onTap: _scanQRCode,
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.nfc,
          title: 'NFC Transfer',
          description: 'Receive proof via NFC from another device',
          color: Colors.green,
          onTap: _receiveNFC,
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.file_upload,
          title: 'Import File',
          description: 'Import proof from a file',
          color: Colors.orange,
          onTap: _importFile,
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          icon: Icons.science,
          title: 'Test with Sample',
          description: 'Verify a sample proof for testing',
          color: Colors.purple,
          onTap: _testSample,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationResult() {
    final isValid = _verificationResult!.isValid;
    final color = isValid ? Colors.green : Colors.red;

    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.cancel,
              color: color.shade700,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isValid ? 'Proof Valid' : 'Proof Invalid',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _verificationResult!.statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[800]),
            ),
            const Divider(height: 32),
            _buildResultDetail(
              'Minimum Age',
              '${_verificationResult!.minimumAge}+',
            ),
            _buildResultDetail(
              'Protocol',
              _verificationResult!.protocol.displayName,
            ),
            _buildResultDetail(
              'Verification Time',
              '${_verificationResult!.verificationTimeMs}ms',
            ),
            if (!isValid && _verificationResult!.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${_verificationResult!.errorMessage}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Text(_errorMessage!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQRCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code scanning coming soon!')),
    );
  }

  void _receiveNFC() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('NFC functionality coming soon!')),
    );
  }

  void _importFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File import coming soon!')),
    );
  }

  Future<void> _testSample() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _verificationResult = null;
    });

    try {
      // Create a sample proof for testing
      final generator = AgeProofGenerator();
      final proof = await generator.generateAgeProof(
        birthDate: DateTime(1990, 1, 1),
        minimumAge: 18,
        protocol: ZKPProtocol.groth16,
      );

      // Verify the proof
      final verifier = AgeProofVerifier();
      final result = await verifier.verifyAgeProofDetailed(proof);

      setState(() {
        _verificationResult = result;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isVerifying = false;
      });
    }
  }
}
