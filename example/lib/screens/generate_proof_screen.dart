/**
 * Generate Proof Screen
 * 
 * Copyright (c) 2026 Active Circuitry Private Ltd.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ac_zero_knowledge_proof_age_sdk/ac_zero_knowledge_proof_age_sdk.dart';
import 'package:intl/intl.dart';

class GenerateProofScreen extends StatefulWidget {
  const GenerateProofScreen({super.key});

  @override
  State<GenerateProofScreen> createState() => _GenerateProofScreenState();
}

class _GenerateProofScreenState extends State<GenerateProofScreen> {
  DateTime? _selectedBirthDate;
  AgeThreshold _selectedThreshold = AgeThreshold.age18;
  ZKPProtocol _selectedProtocol = ZKPProtocol.groth16;
  bool _useHardwareSecurity = true;
  bool _isGenerating = false;
  AgeProof? _generatedProof;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Age Proof'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBirthDateSelector(),
            const SizedBox(height: 16),
            _buildThresholdSelector(),
            const SizedBox(height: 16),
            _buildProtocolSelector(),
            const SizedBox(height: 16),
            _buildSecurityToggle(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            if (_isGenerating) ...[
              const SizedBox(height: 24),
              _buildProgressIndicator(),
            ],
            if (_generatedProof != null) ...[
              const SizedBox(height: 24),
              _buildProofResult(),
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

  Widget _buildBirthDateSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Birth Date'),
        subtitle: Text(
          _selectedBirthDate == null
              ? 'Tap to select'
              : DateFormat.yMMMd().format(_selectedBirthDate!),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectBirthDate,
      ),
    );
  }

  Widget _buildThresholdSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Age Threshold',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: AgeThreshold.values.map((threshold) {
                final isSelected = _selectedThreshold == threshold;
                return ChoiceChip(
                  label: Text(threshold.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedThreshold = threshold);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedThreshold.useCase,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ZKP Protocol',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<ZKPProtocol>(
              title: Text(ZKPProtocol.groth16.displayName),
              subtitle: Text(ZKPProtocol.groth16.description),
              value: ZKPProtocol.groth16,
              groupValue: _selectedProtocol,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProtocol = value);
                }
              },
            ),
            RadioListTile<ZKPProtocol>(
              title: Text(ZKPProtocol.plonk.displayName),
              subtitle: Text(ZKPProtocol.plonk.description),
              value: ZKPProtocol.plonk,
              groupValue: _selectedProtocol,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedProtocol = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Hardware Security'),
        subtitle: const Text('Use Android KeyStore and TEE'),
        value: _useHardwareSecurity,
        onChanged: (value) {
          setState(() => _useHardwareSecurity = value);
        },
        secondary: const Icon(Icons.security),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _isGenerating || _selectedBirthDate == null
          ? null
          : _generateProof,
      icon: const Icon(Icons.fingerprint),
      label: const Text('Generate Proof'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Generating proof...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take 5-10 seconds',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_progress > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toInt()}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProofResult() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Proof Generated!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildProofDetail('Minimum Age', '${_generatedProof!.minimumAge}+'),
            _buildProofDetail('Protocol', _generatedProof!.protocol.displayName),
            _buildProofDetail('Proof Size', '${_generatedProof!.proofSize} bytes'),
            _buildProofDetail(
              'Generated',
              DateFormat.yMd().add_jm().format(_generatedProof!.generatedAt),
            ),
            _buildProofDetail('Proof ID', _generatedProof!.proofId),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _shareProof,
              icon: const Icon(Icons.share),
              label: const Text('Share Proof'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
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

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 25);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
        _errorMessage = null;
      });
    }
  }

  Future<void> _generateProof() async {
    if (_selectedBirthDate == null) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedProof = null;
      _progress = 0.0;
    });

    try {
      final generator = AgeProofGenerator();

      // Listen to progress
      generator.getProofGenerationProgress().listen((progress) {
        setState(() => _progress = progress);
      });

      final proof = await generator.generateAgeProof(
        birthDate: _selectedBirthDate!,
        minimumAge: _selectedThreshold.age,
        protocol: _selectedProtocol,
        useHardwareSecurity: _useHardwareSecurity,
      );

      setState(() {
        _generatedProof = proof;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proof generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  void _shareProof() {
    if (_generatedProof == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Proof',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              subtitle: const Text('Copy proof data as JSON'),
              onTap: () {
                _copyProofToClipboard();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Show QR Code'),
              subtitle: const Text('Display proof as QR code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Export Proof'),
              subtitle: const Text('Share via system share sheet'),
              onTap: () {
                Navigator.pop(context);
                _exportProof();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _copyProofToClipboard() async {
    if (_generatedProof == null) return;
    
    final proofJson = '''
{
  "proofId": "${_generatedProof!.proofId}",
  "minimumAge": ${_generatedProof!.minimumAge},
  "protocol": "${_generatedProof!.protocol.name}",
  "generatedAt": "${_generatedProof!.generatedAt.toIso8601String()}",
  "proofData": "${_generatedProof!.proofData.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}"
}''';
    
    await Clipboard.setData(ClipboardData(text: proofJson));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proof copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _showQRCode() {
    if (_generatedProof == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2, size: 180, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QR Code generation requires qr_flutter package',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _exportProof() {
    if (_generatedProof == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Proof export ready - System share not implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
