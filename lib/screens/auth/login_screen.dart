import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../main_navigation.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/firebase_auth_service.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
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
                  'Welcome back',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to continue your dream journey',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.shadowGrey,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 40),
                
                // Email field
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
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
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
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
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 12),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _navigateToForgotPassword(),
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                
                const SizedBox(height: 32),
                
                // Sign in button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.cloudWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 32),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => _navigateToSignup(),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms, delay: 800.ms),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    debugPrint('=== STARTING FIREBASE SIGN IN ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    
    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      
      final success = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        if (success) {
          debugPrint('Firebase sign in successful!');
          
          final user = authService.currentUser;
          
          // Reload user to get latest email verification status
          if (user != null) {
            debugPrint('Login screen: Calling refreshUser() on authService instance: ${authService.hashCode}');
            await authService.refreshUser();
            
            final refreshedUser = authService.currentUser;
            
            // Check verification status after refresh
            if (refreshedUser != null && refreshedUser.emailVerified) {
              debugPrint('Email verified! Navigating back to AuthGate.');
              debugPrint('AuthGate will handle navigation based on email verification status.');
              // Navigate back to AuthGate so it can set userId and then show MainNavigation
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthGate()),
                (route) => false,
              );
            } else if (refreshedUser != null && !refreshedUser.emailVerified) {
              debugPrint('Email not verified, skipping Convex sync');
              // Show email verification dialog
              _showEmailVerificationNeededDialog(refreshedUser.email ?? '');
            }
          }
          
          debugPrint('AuthGate will handle navigation based on email verification status.');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid email or password. Please check your credentials and try again.'),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      if (mounted) {
        final authService = Provider.of<FirebaseAuthService>(context, listen: false);
        final errorMessage = authService.getFirebaseErrorMessage(e.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Sign in failed'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
    debugPrint('=== FIREBASE SIGN IN COMPLETE ===');
  }
  
  
  void _navigateToSignup() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupScreen(),
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

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ForgotPasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showEmailVerificationNeededDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Email Verification Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.email_outlined,
                size: 48,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'Please verify your email address before signing in.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to $email. If you haven\'t received it or it has expired, you can request a new one.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            // Bottom row with properly spaced buttons
            Row(
              children: [
                // Cancel button (secondary, left-aligned)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                // Resend button (secondary, right side)
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent! Please check your inbox.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to resend email. Please try again later.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Resend Email'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Primary action button (full width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkEmailVerificationInLogin(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: AppColors.cloudWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'I\'ve Verified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkEmailVerificationInLogin() async {
    try {
      final authService = Provider.of<FirebaseAuthService>(context, listen: false);
      
      // Refresh user to get latest email verification status
      await authService.refreshUser();
      final user = authService.currentUser;
      
      if (mounted) {
        if (user?.emailVerified == true) {
          // Close dialog and navigate directly
          Navigator.of(context).pop();
          debugPrint('Email verified! Navigating directly to MainNavigation.');
          // Force navigation since AuthGate Consumer isn't rebuilding  
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        } else {
          // Email not yet verified
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email not yet verified. Please check your email and try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Email verification check failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification check failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}