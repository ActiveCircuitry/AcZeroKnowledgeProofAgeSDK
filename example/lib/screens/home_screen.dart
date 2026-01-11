/**
 * Home Screen - Main navigation hub
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/material.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHardwareSecurityAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkHardwareSecurity();
  }

  Future<void> _checkHardwareSecurity() async {
    try {
      final generator = AgeProofGenerator();
      final available = await generator.isHardwareSecurityAvailable();
      setState(() {
        _isHardwareSecurityAvailable = available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AC ZKP Age Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSecurityStatus(),
                  const SizedBox(height: 32),
                  _buildFeatureCards(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.verified_user,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Zero-Knowledge Age Verification',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Verify age without revealing personal information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Card(
      color: _isHardwareSecurityAvailable
          ? Colors.green.shade50
          : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _isHardwareSecurityAvailable
                  ? Icons.security
                  : Icons.warning_amber,
              color: _isHardwareSecurityAvailable
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isHardwareSecurityAvailable
                        ? 'Hardware Security Available'
                        : 'Software-Only Mode',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _isHardwareSecurityAvailable
                        ? 'Using Android KeyStore & TEE'
                        : 'Hardware security not available on this device',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.shield_outlined,
          title: 'Generate Age Proof',
          description: 'Create a zero-knowledge proof for age verification',
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/generate'),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.verified_outlined,
          title: 'Verify Proof',
          description: 'Verify an age proof without revealing birth date',
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/verify'),
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.key_outlined,
          title: 'Key Management',
          description: 'Manage cryptographic keys and settings',
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/keys'),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
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
                  'About Zero-Knowledge Proofs',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Zero-Knowledge Proofs allow you to prove you meet an age requirement '
              'without revealing your actual age or birth date. This protects your '
              'privacy while ensuring compliance with age restrictions.',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}
