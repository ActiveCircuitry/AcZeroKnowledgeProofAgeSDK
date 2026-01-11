/**
 * About Screen
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'What are Zero-Knowledge Proofs?',
              content:
                  'Zero-Knowledge Proofs (ZKPs) are cryptographic methods that allow one party '
                  'to prove to another that a statement is true without revealing any information '
                  'beyond the validity of the statement itself.',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'How It Works',
              content:
                  '1. Generate a proof using your birth date\n'
                  '2. The proof mathematically demonstrates you meet an age threshold\n'
                  '3. Verifiers can confirm your age without seeing your birth date\n'
                  '4. Your privacy is protected while proving age compliance',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Protocols Supported',
              content:
                  'Groth16: Fast verification, small proof size (~200 bytes)\n\n'
                  'PLONK: Universal setup, flexible circuits (~500 bytes)',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Security Features',
              content:
                  '• Hardware-backed key storage (Android KeyStore)\n'
                  '• Trusted Execution Environment (TEE) support\n'
                  '• Cryptographically secure proof generation\n'
                  '• No personal data transmission',
            ),
            const SizedBox(height: 24),
            _buildCompanyInfo(),
            const SizedBox(height: 16),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.verified_user,
              size: 72,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            const Text(
              'Active Circuitry\nZero Knowledge Age Verification SDK',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Privacy-Preserving Age Verification',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developed By',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Active Circuitry Private Ltd.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Author: Zeng Han Jun',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildContactChip(Icons.email, 'support@activecircuitry.com'),
                const SizedBox(width: 8),
                _buildContactChip(Icons.language, 'activecircuitry.com'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildVersionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVersionRow('SDK Version', '0.1.0'),
            const Divider(height: 16),
            _buildVersionRow('Example App Version', '1.0.0+1'),
            const Divider(height: 16),
            _buildVersionRow('License', 'MIT'),
            const SizedBox(height: 12),
            Text(
              'Copyright © 2026 Active Circuitry Private Ltd.\nAll rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
