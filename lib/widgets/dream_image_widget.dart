import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class DreamImageWidget extends StatelessWidget {
  final String? imagePath;
  final double height;
  final BorderRadius? borderRadius;

  const DreamImageWidget({
    super.key,
    this.imagePath,
    this.height = 200,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main image - handle both URLs and file paths
            imagePath!.startsWith('http')
                ? Image.network(
                    imagePath!,
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorWidget();
                    },
                  )
                : Image.file(
                    File(imagePath!),
                    height: height,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorWidget();
                    },
                  ),
            // Gradient overlay
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // AI indicator badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: AppColors.cloudWhite,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AI Generated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.cloudWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.fogGrey,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mistGrey,
          style: BorderStyle.solid,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.ultraLightPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 32,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No dream image',
            style: TextStyle(
              color: AppColors.shadowGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Generate an AI image to visualize this dream',
            style: TextStyle(
              color: AppColors.shadowGrey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.errorRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.errorRed,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Image not available',
            style: TextStyle(
              color: AppColors.errorRed,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The dream image could not be loaded',
            style: TextStyle(
              color: AppColors.errorRed.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}