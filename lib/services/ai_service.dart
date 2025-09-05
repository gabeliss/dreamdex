import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AIService extends ChangeNotifier {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  String? _apiKey;
  bool _isGeneratingImage = false;
  bool _isAnalyzing = false;

  bool get isGeneratingImage => _isGeneratingImage;
  bool get isAnalyzing => _isAnalyzing;

  AIService() {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final envContent = await rootBundle.loadString('.env');
      final lines = envContent.split('\n');
      for (final line in lines) {
        if (line.startsWith('GOOGLE_AI_STUDIO_API_KEY=')) {
          _apiKey = line.split('=')[1].trim();
          break;
        }
      }
    } catch (e) {
      debugPrint('Error loading API key: $e');
    }
  }

  Future<String?> generateDreamImage(String dreamDescription) async {
    if (_apiKey == null) {
      debugPrint('API key not found');
      return null;
    }

    _isGeneratingImage = true;
    notifyListeners();

    try {
      // Create a more artistic prompt for dream imagery
      final prompt = _createImagePrompt(dreamDescription);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-2.5-flash-image-preview:generateContent'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey!,
        },
        body: jsonEncode({
          'contents': [{
            'parts': [
              {'text': prompt}
            ]
          }]
        }),
      );

      debugPrint('Image generation response: ${response.statusCode}');
      debugPrint('Image generation response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if we have candidates with images
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null && 
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            
            // Look for image data in the parts
            for (var part in candidate['content']['parts']) {
              if (part['inlineData'] != null && part['inlineData']['data'] != null) {
                final imageData = part['inlineData']['data'];
                
                // Save image locally
                final localPath = await _saveImageLocally(imageData);
                
                _isGeneratingImage = false;
                notifyListeners();
                return localPath;
              }
            }
          }
        }
        
        debugPrint('No image data found in response');
      } else {
        debugPrint('Image generation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error generating dream image: $e');
    }

    _isGeneratingImage = false;
    notifyListeners();
    return null;
  }

  String _createImagePrompt(String dreamDescription) {
    return """Create an artistic visual representation of this dream: "$dreamDescription"

Instructions:
- Interpret the dream content literally but with a dreamlike, surreal quality
- Match the mood and atmosphere described in the dream (dark/light, peaceful/chaotic, etc.)
- Use colors and lighting that reflect the dream's emotional tone
- Include the specific elements, characters, and settings mentioned
- Add a subtle dream-like quality: soft edges, floating elements, impossible perspectives, or shifting realities
- Style should feel like a vivid dream memory - clear enough to recognize but with that otherworldly dream logic

Avoid making every image look the same - let the dream content drive the visual style, colors, and composition.""";
  }

  Future<String> _saveImageLocally(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/dream_images';
      
      // Create directory if it doesn't exist
      await Directory(imagePath).create(recursive: true);
      
      final fileName = 'dream_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('$imagePath/$fileName');
      
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> analyzeDream(String dreamContent) async {
    if (_apiKey == null) {
      debugPrint('API key not found');
      return null;
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      final prompt = _createAnalysisPrompt(dreamContent);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 1,
            'topP': 1,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return _parseAnalysisResponse(content);
        }
      } else {
        debugPrint('Dream analysis failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error analyzing dream: $e');
    }

    _isAnalyzing = false;
    notifyListeners();
    return null;
  }

  String _createAnalysisPrompt(String dreamContent) {
    return """Analyze this dream and provide a structured response in JSON format:

Dream: "$dreamContent"

Please analyze and return ONLY a valid JSON object with this exact structure:
{
  "summary": "A brief 2-3 sentence summary of the dream",
  "themes": ["theme1", "theme2", "theme3"],
  "characters": ["character1", "character2"],
  "locations": ["location1", "location2"],
  "emotions": ["joy", "fear", "love", "anxiety", "peace"],
  "lucidityScore": 0.5,
  "emotionalIntensity": 0.7
}

Guidelines:
- summary: Concise overview of the main dream narrative
- themes: Major concepts, symbols, or recurring elements (max 5)
- characters: People, animals, or entities present (max 5)
- locations: Settings, places, or environments (max 5)
- emotions: Primary emotional tones (use: joy, fear, sadness, anger, love, anxiety, peace, confusion, excitement, nostalgia)
- lucidityScore: How aware/in-control the dreamer seemed (0.0-1.0)
- emotionalIntensity: Overall emotional impact (0.0-1.0)

Return only the JSON object, no additional text or formatting.""";
  }

  Map<String, dynamic>? _parseAnalysisResponse(String response) {
    try {
      // Clean the response to extract JSON
      String cleanResponse = response.trim();
      
      // Find JSON object boundaries
      int startIndex = cleanResponse.indexOf('{');
      int endIndex = cleanResponse.lastIndexOf('}');
      
      if (startIndex != -1 && endIndex != -1) {
        cleanResponse = cleanResponse.substring(startIndex, endIndex + 1);
        return jsonDecode(cleanResponse);
      }
    } catch (e) {
      debugPrint('Error parsing analysis response: $e');
      debugPrint('Response was: $response');
    }
    
    // Return default structure if parsing fails
    return {
      'summary': 'Analysis could not be completed at this time.',
      'themes': <String>[],
      'characters': <String>[],
      'locations': <String>[],
      'emotions': <String>[],
      'lucidityScore': 0.0,
      'emotionalIntensity': 0.0,
    };
  }

  // Alternative image generation using Gemini (if Imagen is not available)
  Future<String?> generateDreamImageWithGemini(String dreamDescription) async {
    if (_apiKey == null) {
      debugPrint('API key not found');
      return null;
    }

    _isGeneratingImage = true;
    notifyListeners();

    try {
      final prompt = """Based on this dream description, create a detailed text description for an AI image generator that would create a beautiful, artistic, dreamy image:

Dream: "$dreamDescription"

Provide a detailed visual description that includes:
- Art style (dreamy, surreal, impressionistic, etc.)
- Colors and lighting
- Composition and mood
- Specific visual elements from the dream
- Artistic quality descriptors

Format as a single paragraph prompt for an image generator.""";

      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final imagePrompt = data['candidates'][0]['content']['parts'][0]['text'];
          debugPrint('Generated image prompt: $imagePrompt');
          
          // For now, return the prompt as we would need additional image generation API
          // In a real implementation, you would pass this prompt to an image generation service
          return imagePrompt;
        }
      }
    } catch (e) {
      debugPrint('Error generating image prompt: $e');
    }

    _isGeneratingImage = false;
    notifyListeners();
    return null;
  }

  bool get isApiKeyConfigured => _apiKey != null && _apiKey!.isNotEmpty;
}