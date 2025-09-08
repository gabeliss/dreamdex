import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // 🔑 Added scroll wrapper
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40), // replaces Spacer for scroll safety

                // Logo and title
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppColors.dreamGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bedtime,
                    size: 60,
                    color: AppColors.cloudWhite,
                  ),
                ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  'Dreamdex',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        background: Paint()
                          ..shader = AppColors.dreamGradient.createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                      ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3),

                const SizedBox(height: 16),

                Text(
                  'Track, analyze, and visualize\nyour dreams with AI',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.shadowGrey,
                      ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

                const SizedBox(height: 60),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _navigateToClerkAuth(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: AppColors.cloudWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),

                // Features preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.ultraLightPurple,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightPurple),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mic,
                              color: AppColors.primaryPurple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Voice-to-text dream recording',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.psychology,
                              color: AppColors.primaryPurple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI-powered dream analysis',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.primaryPurple, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI-generated dream imagery',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToClerkAuth(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
