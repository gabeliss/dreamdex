import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'convex_service.dart';

class ImageGenerationException implements Exception {
  final String message;
  final String code;
  
  const ImageGenerationException(this.message, this.code);
  
  @override
  String toString() => message;
}

class AIService extends ChangeNotifier {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  String? _apiKey;
  bool _isGeneratingImage = false;
  bool _isAnalyzing = false;
  final ConvexService _convexService;

  bool get isGeneratingImage => _isGeneratingImage;
  bool get isAnalyzing => _isAnalyzing;

  AIService(this._convexService) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      _apiKey = dotenv.env['GOOGLE_AI_STUDIO_API_KEY'];
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        debugPrint('✅ Google AI Studio API key loaded successfully');
      } else {
        debugPrint('❌ Google AI Studio API key not found in environment');
      }
    } catch (e) {
      debugPrint('Error loading API key: $e');
    }
  }

  Future<String?> generateDreamImageData(String dreamDescription) async {
    if (_apiKey == null) {
      throw const ImageGenerationException('AI API key not configured. Please contact support.', 'API_KEY_MISSING');
    }

    _isGeneratingImage = true;
    notifyListeners();

    try {
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
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          
          // Check for specific failure reasons
          if (candidate['finishReason'] != null) {
            switch (candidate['finishReason']) {
              case 'PROHIBITED_CONTENT':
                throw const ImageGenerationException(
                  'Image generation was blocked because the request contained restricted content. Please adjust your prompt and try again.',
                  'PROHIBITED_CONTENT'
                );
              case 'SAFETY':
                throw const ImageGenerationException(
                  'The image generation was blocked for safety reasons. Please try rephrasing your dream description.',
                  'SAFETY'
                );
              case 'RECITATION':
                throw const ImageGenerationException(
                  'The content appears to reference copyrighted material. Please describe your dream in your own words.',
                  'RECITATION'
                );
              case 'OTHER':
                throw const ImageGenerationException(
                  'The image generation encountered an issue. Please try again with a different description.',
                  'OTHER'
                );
            }
          }
          
          if (candidate['content'] != null && 
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            
            for (var part in candidate['content']['parts']) {
              if (part['inlineData'] != null && part['inlineData']['data'] != null) {
                final imageData = part['inlineData']['data'];
                
                _isGeneratingImage = false;
                notifyListeners();
                return imageData; // Return the base64 data
              }
            }
          }
        }
        
        throw const ImageGenerationException(
          'The image generation completed but no image was produced. Please try again.',
          'NO_IMAGE_DATA'
        );
      } else if (response.statusCode == 429) {
        throw const ImageGenerationException(
          'Too many image generation requests. Please wait a moment and try again.',
          'RATE_LIMIT'
        );
      } else if (response.statusCode >= 500) {
        throw const ImageGenerationException(
          'The image generation service is temporarily unavailable. Please try again later.',
          'SERVER_ERROR'
        );
      } else {
        throw ImageGenerationException(
          'Image generation failed (${response.statusCode}). Please try again.',
          'HTTP_ERROR'
        );
      }
    } catch (e) {
      _isGeneratingImage = false;
      notifyListeners();
      
      if (e is ImageGenerationException) {
        rethrow;
      }
      
      debugPrint('Error generating dream image: $e');
      throw const ImageGenerationException(
        'An unexpected error occurred while generating the image. Please check your internet connection and try again.',
        'UNKNOWN_ERROR'
      );
    }

    _isGeneratingImage = false;
    notifyListeners();
    return null;
  }

  Future<String?> generateDreamImage(String dreamDescription, String dreamId, String userId) async {
    if (_apiKey == null) {
      throw const ImageGenerationException('AI API key not configured. Please contact support.', 'API_KEY_MISSING');
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
          
          // Check for specific failure reasons
          if (candidate['finishReason'] != null) {
            switch (candidate['finishReason']) {
              case 'PROHIBITED_CONTENT':
                throw const ImageGenerationException(
                  'Your dream description contains content that cannot be visualized. Try describing your dream with different words or focus on other aspects of the dream.',
                  'PROHIBITED_CONTENT'
                );
              case 'SAFETY':
                throw const ImageGenerationException(
                  'The image generation was blocked for safety reasons. Please try rephrasing your dream description.',
                  'SAFETY'
                );
              case 'RECITATION':
                throw const ImageGenerationException(
                  'The content appears to reference copyrighted material. Please describe your dream in your own words.',
                  'RECITATION'
                );
              case 'OTHER':
                throw const ImageGenerationException(
                  'The image generation encountered an issue. Please try again with a different description.',
                  'OTHER'
                );
            }
          }
          
          if (candidate['content'] != null && 
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            
            // Look for image data in the parts
            for (var part in candidate['content']['parts']) {
              if (part['inlineData'] != null && part['inlineData']['data'] != null) {
                final imageData = part['inlineData']['data'];
                
                // Store image in Convex storage
                await _storeImageInConvex(imageData, dreamId, userId);
                
                _isGeneratingImage = false;
                notifyListeners();
                return 'success'; // Return success indicator instead of path
              }
            }
          }
        }
        
        throw const ImageGenerationException(
          'The image generation completed but no image was produced. Please try again.',
          'NO_IMAGE_DATA'
        );
      } else if (response.statusCode == 429) {
        throw const ImageGenerationException(
          'Too many image generation requests. Please wait a moment and try again.',
          'RATE_LIMIT'
        );
      } else if (response.statusCode >= 500) {
        throw const ImageGenerationException(
          'The image generation service is temporarily unavailable. Please try again later.',
          'SERVER_ERROR'
        );
      } else {
        throw ImageGenerationException(
          'Image generation failed (${response.statusCode}). Please try again.',
          'HTTP_ERROR'
        );
      }
    } catch (e) {
      _isGeneratingImage = false;
      notifyListeners();
      
      if (e is ImageGenerationException) {
        rethrow;
      }
      
      debugPrint('Error generating dream image: $e');
      throw const ImageGenerationException(
        'An unexpected error occurred while generating the image. Please check your internet connection and try again.',
        'UNKNOWN_ERROR'
      );
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

  Future<void> _storeImageInConvex(String base64Image, String dreamId, String userId) async {
    try {
      // Call Convex action to store the image
      await _convexService.uploadImage(
        base64Image: base64Image,
        dreamId: dreamId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error storing image in Convex: $e');
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
    return """Analyze this dream as a professional dream analyst and provide a comprehensive psychological interpretation in JSON format:

Dream: "$dreamContent"

Please analyze and return ONLY a valid JSON object with this exact structure:
{
  "summary": "A brief 2-3 sentence summary of the dream narrative",
  "themes": ["theme1", "theme2", "theme3"],
  "characters": ["character1", "character2"],
  "locations": ["location1", "location2"],
  "emotions": ["joy", "fear", "love", "anxiety", "peace"],
  "lucidityScore": 0.5,
  "emotionalIntensity": 0.7,
  "interpretation": "A detailed psychological interpretation of what this dream might represent in the dreamer's waking life, including potential subconscious messages, unresolved issues, or life transitions it may reflect. Consider common dream psychology theories.",
  "personalReflection": "Thoughtful questions and prompts to help the dreamer reflect on how this dream might connect to their current life situation, relationships, goals, or inner emotional state.",
  "symbolism": [
    {"symbol": "flying", "meaning": "desire for freedom or escape from limitations"},
    {"symbol": "water", "meaning": "emotions, subconscious mind, or life transitions"}
  ],
  "possibleMeanings": [
    "The dream may reflect feelings of being overwhelmed in your current situation",
    "It could represent a desire for more control or freedom in your life",
    "This might symbolize upcoming changes or transitions you're anticipating"
  ]
}

Analysis Guidelines:
- summary: Concise overview of the main dream narrative
- themes: Major concepts, symbols, or recurring elements (max 5)
- characters: People, animals, or entities present (max 5)  
- locations: Settings, places, or environments (max 5)
- emotions: Primary emotional tones (use: joy, fear, sadness, anger, love, anxiety, peace, confusion, excitement, nostalgia)
- lucidityScore: How aware/in-control the dreamer seemed (0.0-1.0)
- emotionalIntensity: Overall emotional impact (0.0-1.0)
- interpretation: 2-3 paragraphs of professional dream analysis connecting symbols to psychology
- personalReflection: Helpful questions to guide self-reflection (2-3 sentences)
- symbolism: Key symbols and their psychological meanings (max 5)
- possibleMeanings: 2-4 potential interpretations of the dream's significance

Focus on being insightful, compassionate, and psychologically informed. Draw from Jungian, Freudian, and modern dream analysis approaches. Make connections to common life themes like relationships, career, personal growth, fears, and aspirations.

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
      'interpretation': 'Unable to provide interpretation at this time.',
      'personalReflection': 'Please reflect on what this dream might mean to you personally.',
      'symbolism': <Map<String, dynamic>>[],
      'possibleMeanings': <String>[],
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