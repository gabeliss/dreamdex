import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/src/models/client/strategy.dart';
import 'package:clerk_auth/src/models/enums.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../main_navigation.dart';
import '../../services/convex_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
          ),
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
                    _isCodeSent ? 'Enter Reset Code' : 'Forgot Password?',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    _isCodeSent 
                        ? 'We\'ve sent a reset code to your email. Enter it below along with your new password.'
                        : 'Enter your email address and we\'ll send you a code to reset your password.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.shadowGrey,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
                  
                  const SizedBox(height: 40),
                  
                  if (!_isCodeSent) ...[
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _sendResetCode(),
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                  ] else ...[
                    // Code field
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Reset Code',
                        hintText: 'Enter the 6-digit code',
                        prefixIcon: Icon(Icons.security_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the reset code';
                        }
                        if (value.length != 6) {
                          return 'Reset code must be 6 digits';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 20),
                    
                    // New password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'Enter your new password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 20),
                    
                    // Confirm password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your new password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _resetPassword(),
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading 
                          ? null 
                          : _isCodeSent ? _resetPassword : _sendResetCode,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.cloudWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isCodeSent ? 'Reset Password' : 'Send Reset Code'),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2),
                  
                  if (_isCodeSent) ...[
                    const SizedBox(height: 20),
                    
                    // Back to email input
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isCodeSent = false;
                            _codeController.clear();
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        child: Text(
                          'Try different email',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    debugPrint('=== STARTING PASSWORD RESET FLOW ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    
    setState(() => _isLoading = true);
    
    try {
      final auth = ClerkAuth.of(context);
      debugPrint('Auth instance obtained: ${auth != null}');
      debugPrint('Current client before reset: ${auth.client}');
      debugPrint('Current signIn before reset: ${auth.client?.signIn}');
      
      // Initiate password reset
      debugPrint('Calling initiatePasswordReset...');
      await auth.initiatePasswordReset(
        identifier: _emailController.text.trim(),
        strategy: Strategy.resetPasswordEmailCode,
      );
      
      debugPrint('initiatePasswordReset completed');
      debugPrint('SignIn object after initiate: ${auth.client?.signIn}');
      debugPrint('SignIn status: ${auth.client?.signIn?.status}');
      debugPrint('SignIn identifier: ${auth.client?.signIn?.identifier}');
      debugPrint('First factor verification: ${auth.client?.signIn?.firstFactorVerification}');
      
      if (mounted) {
        setState(() {
          _isCodeSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset code sent to ${_emailController.text.trim()}'),
            backgroundColor: AppColors.primaryPurple,
          ),
        );
      }
    } catch (e) {
      debugPrint('Password reset initiation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send reset code: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
    debugPrint('=== PASSWORD RESET INITIATION COMPLETE ===');
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    debugPrint('=== STARTING PASSWORD RESET ATTEMPT ===');
    debugPrint('Code: ${_codeController.text.trim()}');
    debugPrint('New password length: ${_passwordController.text.length}');
    
    setState(() => _isLoading = true);
    
    try {
      final auth = ClerkAuth.of(context);
      debugPrint('Auth instance obtained: ${auth != null}');
      debugPrint('Current signIn before reset: ${auth.client?.signIn}');
      debugPrint('SignIn status before reset: ${auth.client?.signIn?.status}');
      debugPrint('Is signed in before reset: ${auth.isSignedIn}');
      
      // Debug the strategy and parameters
      final strategy = Strategy.resetPasswordEmailCode;
      final code = _codeController.text.trim();
      final password = _passwordController.text;
      
      debugPrint('Strategy: $strategy');
      debugPrint('Strategy name: ${strategy.name}');
      debugPrint('Strategy.isPasswordResetter: ${strategy.isPasswordResetter}');
      debugPrint('Code provided: ${code.isNotEmpty} (length: ${code.length})');
      debugPrint('Password provided: ${password.isNotEmpty} (length: ${password.length})');
      debugPrint('SignIn object exists: ${auth.client?.signIn != null}');
      debugPrint('SignIn status: ${auth.client?.signIn?.status}');
      
      // Attempt sign in with reset password strategy (code + password required together)
      debugPrint('Calling attemptSignIn with reset strategy, code, and password...');
      await auth.attemptSignIn(
        strategy: strategy,
        code: code,
        password: password,
      );
      
      debugPrint('attemptSignIn completed');
      debugPrint('SignIn status after reset: ${auth.client?.signIn?.status}');
      debugPrint('Is signed in after reset: ${auth.isSignedIn}');
      debugPrint('Current user after reset: ${auth.user}');
      debugPrint('Current user ID: ${auth.user?.id}');
      debugPrint('SignIn object after reset: ${auth.client?.signIn}');
      debugPrint('First factor verification after reset: ${auth.client?.signIn?.firstFactorVerification}');
      debugPrint('Verification status: ${auth.client?.signIn?.firstFactorVerification?.status}');
      debugPrint('Verification attempts: ${auth.client?.signIn?.firstFactorVerification?.attempts}');
      
      // Check if the password reset was successful
      if (mounted) {
        if (auth.isSignedIn) {
          // Password reset was successful and user is now signed in
          debugPrint('Password reset successful - user is now signed in');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successful! You are now signed in.'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Sync user to Convex and navigate to main app
          final convexService = Provider.of<ConvexService>(context, listen: false);
          final user = auth.client?.user;
          
          if (user != null) {
            // Set the userId for dream operations
            convexService.setUserId(user.id);
            
            await convexService.upsertUser(
              clerkId: user.id,
              email: user.email ?? '',
              firstName: user.firstName,
              lastName: user.lastName,
              profileImageUrl: user.profileImageUrl,
            );
          }
          
          // Navigate to main app since user is signed in
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        } else {
          // Password reset was successful but user is not signed in
          debugPrint('Password reset successful but user not signed in');
          final signInStatus = auth.client?.signIn?.status;
          if (signInStatus?.name == 'complete') {
            debugPrint('SignIn status is complete, password should be updated');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successful! Please sign in with your new password.'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            debugPrint('SignIn status: $signInStatus - may need additional steps');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password reset in progress. Status: $signInStatus'),
                backgroundColor: AppColors.primaryPurple,
              ),
            );
          }
          
          // Navigate back to login screen
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint('Password reset error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
    debugPrint('=== PASSWORD RESET ATTEMPT COMPLETE ===');
  }
}