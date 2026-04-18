import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/gemini_service.dart';
import 'services/treatment_service.dart';

class PlantScannerScreen extends StatefulWidget {
  const PlantScannerScreen({super.key});

  @override
  State<PlantScannerScreen> createState() => _PlantScannerScreenState();
}

class _PlantScannerScreenState extends State<PlantScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  final GeminiService _gemini = GeminiService();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _result = null;
      });
      _classifyImage();
    }
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;
    setState(() => _isLoading = true);

    try {
      final result = await _gemini.identifyDisease(_image!);
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Failed to connect to the server. Please check your internet connection.';
      final eStr = e.toString();
      if ((eStr.contains('XMLHttpRequest error') || eStr.contains('Failed to fetch')) && kIsWeb) {
        errorMessage = 'CORS error: API requests are blocked on the Web browser. Please run on Android/iOS.';
      } else {
        errorMessage = eStr.replaceAll(RegExp(r'api-key=[a-zA-Z0-9_-]+'), 'api-key=HIDDEN');
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Expert Plant Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.green.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    image: _image != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_image!.path) as ImageProvider
                                : FileImage(File(_image!.path)),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 80, color: Colors.white70),
                            SizedBox(height: 16),
                            Text(
                              'Select a plant photo to scan',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Connecting to Pl@ntNet Experts...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                )
              else if (_result != null)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildResultCard(),
                  ),
                )
              else
                const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Image from Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final String label = _result!['label'];
    final double confidence = _result!['confidence'];
    final String eppo = _result!['eppo_code'] ?? '';
    final String treatment = TreatmentService.getTreatment(label);
    final bool isHealthy = label.toLowerCase().contains('healthy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.medical_services_outlined,
                color: isHealthy ? Colors.green : Colors.redAccent,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conf: ${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
              if (eppo.isNotEmpty)
                Text(
                  'Code: $eppo',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
            ],
          ),
          const Divider(height: 32),
          const Text(
            'Expert Analysis:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 8),
          Text(
            'Google Gemini AI has analyzed this sample. The result suggests the presence of "$label".',
            style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const Text(
            'Treatment Suggestions:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              treatment,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
