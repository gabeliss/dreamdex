import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/firebase_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Title and subtitle
                  Text(
                    _isEmailSent ? 'Check your email' : 'Forgot Password?',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isEmailSent 
                      ? 'We sent a password reset link to ${_emailController.text.trim()}'
                      : 'Enter your email address and we\'ll send you a link to reset your password',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.shadowGrey,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 40),
                  
                  if (!_isEmailSent) ...[
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _sendPasswordResetEmail(),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 32),
                    
                    // Send reset email button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendPasswordResetEmail,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.cloudWhite,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Reset Link'),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
                  ] else ...[
                    // Success message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Password reset email sent successfully!',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      "If you don't see the email in your inbox, please check your spam folder.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.shadowGrey,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                    
                    const SizedBox(height: 32),
                    
                    // Resend button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _sendPasswordResetEmail,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Resend Email'),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 16),
                    
                    // Back to login button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Sign In'),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    debugPrint('=== FORGOT PASSWORD RESET ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    debugPrint('Form validation passed, setting loading state');
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      debugPrint('Got auth service, calling sendPasswordResetEmail');
      
      final success = await authService.sendPasswordResetEmail(_emailController.text.trim());
      debugPrint('sendPasswordResetEmail returned: $success');
      
      if (mounted) {
        if (success) {
          debugPrint('Password reset email sent successfully');
          setState(() => _isEmailSent = true);
        } else {
          debugPrint('Password reset email failed (returned false)');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send reset email. Please check your email address and try again.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: \${e.code} - \${e.message}');
      if (mounted) {
        final authService = Provider.of<FirebaseAuthService>(context, listen: false);
        final errorMessage = authService.getFirebaseErrorMessage(e.code) ?? 'Failed to send reset email';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error sending password reset email: \$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        debugPrint('Setting loading state to false');
        setState(() => _isLoading = false);
      }
    }
  }
}