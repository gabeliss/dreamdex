import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../main_navigation.dart';
import 'login_screen.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/convex_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
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
                  'Join Dreamdex',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 8),
                
                Text(
                  'Create your account to start tracking dreams',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.shadowGrey,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
                
                const SizedBox(height: 40),
                
                // Name field
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 20),
                
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
                ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 20),
                
                // Password field
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 20),
                
                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
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
                ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 40),
                
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: AppColors.cloudWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cloudWhite),
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 40),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.shadowGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _navigateToLogin(context),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms, delay: 900.ms),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

bool _codeDialogOpen = false;

Future<void> _handleSignup() async {
  debugPrint('=== FIREBASE SIGNUP CALLED ===');
  if (_isLoading || !_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);

  try {
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final parts = _nameController.text.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    debugPrint('Email: ${_emailController.text.trim()}');
    debugPrint('FirstName: $firstName');
    debugPrint('LastName: $lastName');
    
    final success = await authService.signUpWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: firstName,
      lastName: lastName,
    );

    if (mounted) {
      if (success) {
        debugPrint('Firebase signup successful!');
        
        // Send verification email immediately after signup
        try {
          await FirebaseAuth.instance.currentUser?.sendEmailVerification();
          debugPrint('Email verification sent successfully!');
        } catch (e) {
          debugPrint('Failed to send verification email: $e');
          // Continue anyway - user can request another email later
        }
        
        // Show email verification dialog
        if (!_codeDialogOpen) {
          _codeDialogOpen = true;
          _showEmailVerificationDialog();
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed. Please try again.'),
            backgroundColor: AppColors.errorRed,
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
          content: Text(errorMessage ?? 'Sign up failed'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e'), backgroundColor: AppColors.errorRed),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_unread,
                size: 48,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification link to ${_emailController.text.trim()}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please check your email and click the verification link to complete your registration.',
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
                    _codeDialogOpen = false;
                    setState(() => _isLoading = false);
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
                            content: Text('Verification email sent again!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to resend email. Please try again.'),
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
                onPressed: () => _checkEmailVerification(),
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

Future<void> _checkEmailVerification() async {
  // Firebase doesn't use email verification codes
  // Instead, Firebase sends a verification link to email
  // This method should be replaced with checking if email is verified
  
  setState(() => _isLoading = true);
  try {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      throw Exception('No user signed in');
    }

    debugPrint('=== CHECKING EMAIL VERIFICATION ===');
    
    // Reload user to get latest email verification status
    await user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;
    
    debugPrint('Email verified: ${updatedUser?.emailVerified}');

    if (mounted) {
      // Check if email is verified
      if (updatedUser?.emailVerified == true) {
        // Close verification dialog on success
        Navigator.of(context).pop();
        _codeDialogOpen = false;
        
        debugPrint('Email verified! Syncing user to Convex...');
        
        // Use the name from the controller for consistent handling
        final parts = _nameController.text.trim().split(' ');
        final firstName = parts.isNotEmpty ? parts.first : '';
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
        
        // Sync user to Convex
        final convexService = Provider.of<ConvexService>(context, listen: false);
        
        // Set the userId for dream operations
        convexService.setUserId(updatedUser!.uid);
        
        await convexService.upsertUser(
          authId: updatedUser.uid,
          email: updatedUser.email ?? '',
          firstName: firstName.isNotEmpty ? firstName : null,
          lastName: lastName.isNotEmpty ? lastName : null,
          profileImageUrl: updatedUser.photoURL,
        );
        
        debugPrint('User sync complete! Navigating to home...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else {
        // Email not yet verified
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not yet verified. Please check your email and try again.'), backgroundColor: Colors.orange),
        );
      }
    }
  } catch (e) {
    debugPrint('Verification failed: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
}
