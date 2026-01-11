/**
 * Key Management Screen
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/material.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';

class KeyManagementScreen extends StatefulWidget {
  const KeyManagementScreen({super.key});

  @override
  State<KeyManagementScreen> createState() => _KeyManagementScreenState();
}

class _KeyManagementScreenState extends State<KeyManagementScreen> {
  final KeyManager _keyManager = KeyManager();
  bool _isLoading = true;
  bool _hasProvingKey = false;
  bool _hasVerificationKey = false;
  bool _isHardwareBacked = false;
  int _provingKeySize = 0;
  int _verificationKeySize = 0;

  @override
  void initState() {
    super.initState();
    _loadKeyInfo();
  }

  Future<void> _loadKeyInfo() async {
    setState(() => _isLoading = true);

    try {
      await _keyManager.initialize();
      
      final hasProving = await _keyManager.hasProvingKey();
      final hasVerification = await _keyManager.hasVerificationKey();
      final isHardware = await _keyManager.isHardwareBackedStorage();
      final provingSize = await _keyManager.getProvingKeySize();
      final verificationSize = await _keyManager.getVerificationKeySize();

      setState(() {
        _hasProvingKey = hasProving;
        _hasVerificationKey = hasVerification;
        _isHardwareBacked = isHardware;
        _provingKeySize = provingSize;
        _verificationKeySize = verificationSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading key info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKeyInfo,
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
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildKeyCard(
                    title: 'Proving Key',
                    hasKey: _hasProvingKey,
                    keySize: _provingKeySize,
                    onDownload: _downloadProvingKey,
                  ),
                  const SizedBox(height: 16),
                  _buildKeyCard(
                    title: 'Verification Key',
                    hasKey: _hasVerificationKey,
                    keySize: _verificationKeySize,
                    onDownload: _downloadVerificationKey,
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: _isHardwareBacked ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _isHardwareBacked ? Icons.security : Icons.sd_storage,
              size: 48,
              color: _isHardwareBacked
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
            ),
            const SizedBox(height: 12),
            Text(
              _isHardwareBacked
                  ? 'Hardware-Backed Storage'
                  : 'File-Based Storage',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isHardwareBacked
                  ? 'Keys are protected by Android KeyStore'
                  : 'Keys are stored in app private storage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyCard({
    required String title,
    required bool hasKey,
    required int keySize,
    required VoidCallback onDownload,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasKey ? Icons.key : Icons.key_off,
                  color: hasKey ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildKeyDetail('Status', hasKey ? 'Available' : 'Not Available'),
            if (hasKey)
              _buildKeyDetail(
                'Size',
                '${(keySize / 1024).toStringAsFixed(2)} KB',
              ),
            const SizedBox(height: 12),
            if (!hasKey)
              OutlinedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyDetail(String label, String value) {
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

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _generateKeys,
          icon: const Icon(Icons.vpn_key),
          label: const Text('Generate New Keys'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _hasProvingKey || _hasVerificationKey ? _deleteKeys : null,
          icon: const Icon(Icons.delete),
          label: const Text('Delete All Keys'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
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
                  'About Cryptographic Keys',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Proving keys are used to generate proofs and must be kept secure. '
              'Verification keys are public and can be shared to verify proofs.',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadProvingKey() async {
    _showLoadingDialog('Downloading proving key...');
    
    try {
      await _keyManager.downloadProvingKey();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proving key downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadKeyInfo();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _downloadVerificationKey() async {
    _showLoadingDialog('Downloading verification key...');
    
    try {
      await _keyManager.downloadVerificationKey();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification key downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadKeyInfo();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _generateKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Keys'),
        content: const Text(
          'This will generate new cryptographic keys. '
          'This process is computationally expensive and may take several minutes. '
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _showLoadingDialog('Generating keys... This may take a few minutes.');
    
    try {
      await _keyManager.generateKeys();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keys generated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadKeyInfo();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteKeys() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Keys'),
        content: const Text(
          'Are you sure you want to delete all keys? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _keyManager.deleteKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keys deleted successfully'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadKeyInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
