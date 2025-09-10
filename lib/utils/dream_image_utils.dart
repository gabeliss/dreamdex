import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ai_service.dart';
import '../services/convex_service.dart';

class DreamImageUtils {
  /// Generates dream image data and optionally uploads to Convex
  /// Returns the generated image data if successful, null otherwise
  static Future<String?> generateDreamImage({
    required BuildContext context,
    required AIService aiService,
    required String dreamContent,
    ConvexService? convexService,
    String? dreamId,
    String? userId,
  }) async {
    if (dreamContent.trim().isEmpty) return null;

    try {
      final imageData = await aiService.generateDreamImageData(dreamContent.trim());
      
      if (imageData != null) {
        // Upload to Convex if parameters provided
        if (convexService != null && dreamId != null && userId != null) {
          await convexService.uploadImage(
            base64Image: imageData,
            dreamId: dreamId,
            userId: userId,
          );
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dream image generated successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
        return imageData;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate dream image. Please try again.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      _handleImageGenerationError(context, e);
      return null;
    }
  }

  /// Handles image generation errors with specific user-friendly messages
  static void _handleImageGenerationError(BuildContext context, dynamic error) {
    if (!context.mounted) return;
    
    String errorMessage;
    Color backgroundColor = AppColors.errorRed;
    
    final errorString = error.toString();
    
    // Check for specific content policy violations - use warning color instead of error
    if (errorString.contains('cannot be visualized') ||
        errorString.contains('blocked for safety') ||
        errorString.contains('copyrighted material') ||
        errorString.contains('different words') ||
        errorString.contains('rephrasing')) {
      backgroundColor = AppColors.sunsetOrange;
      // Extract the clean message without "ImageGenerationException: " prefix
      errorMessage = errorString.replaceFirst('ImageGenerationException: ', '');
    } 
    // Check for rate limiting or service issues - use neutral color
    else if (errorString.contains('wait a moment') ||
             errorString.contains('temporarily unavailable') ||
             errorString.contains('try again later')) {
      backgroundColor = Colors.blueGrey;
      errorMessage = errorString.replaceFirst('ImageGenerationException: ', '');
    }
    // All other errors
    else {
      errorMessage = errorString.replaceFirst('ImageGenerationException: ', '');
      if (errorMessage.startsWith('Error generating image: ')) {
        // Don't double-prefix if it's already there
        errorMessage = errorMessage;
      } else {
        errorMessage = 'Error generating image: $errorMessage';
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5), // Longer duration for detailed messages
      ),
    );
  }
}