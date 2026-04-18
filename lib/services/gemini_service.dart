import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  Future<Map<String, dynamic>?> identifyDisease(XFile imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API Key not found in .env');
    }

    // Use gemini-2.5-flash which is the current default
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json', // Force JSON output
      ),
    );

    final bytes = await imageFile.readAsBytes();
    final prompt = TextPart('''
      Analyze this plant image. Identify any disease or pest present. 
      If it looks healthy, label it as "Healthy Plant".
      Return ONLY a JSON object with this exact structure:
      {
        "label": "Name of disease or 'Healthy Plant'",
        "confidence": 0.95,
        "eppo_code": "unknown"
      }
    ''');
    
    final imagePart = DataPart('image/jpeg', bytes);

    try {
      final response = await model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      if (response.text != null) {
        return json.decode(response.text!);
      }
    } catch (e) {
      throw Exception('Failed to analyze image with Gemini: $e');
    }
    return null;
  }
}
