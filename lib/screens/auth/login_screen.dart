import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:clerk_auth/src/models/client/strategy.dart';
import '../../theme/app_colors.dart';
import '../main_navigation.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/convex_service.dart';

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
    
    debugPrint('=== STARTING SIGN IN ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    
    setState(() => _isLoading = true);
    
    try {
      final auth = ClerkAuth.of(context);
      debugPrint('Auth instance obtained: ${auth != null}');
      debugPrint('Is signed in before attempt: ${auth.isSignedIn}');
      
      // Use the correct Clerk API method
      debugPrint('Calling attemptSignIn...');
      await auth.attemptSignIn(
        identifier: _emailController.text.trim(),
        strategy: Strategy.password,
        password: _passwordController.text,
      );
      
      debugPrint('attemptSignIn completed');
      debugPrint('Is signed in after attempt: ${auth.isSignedIn}');
      debugPrint('Current user: ${auth.user}');
      debugPrint('Client sessions: ${auth.client?.sessions?.length ?? 0}');
      debugPrint('SignIn status: ${auth.client?.signIn?.status}');
      debugPrint('SignIn identifier: ${auth.client?.signIn?.identifier}');

      // Check if sign-in was successful and navigate explicitly
      if (mounted && auth.isSignedIn) {
        debugPrint('Sign in successful! Syncing user to Convex...');
        
        // Sync user to Convex
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
        
        debugPrint('User sync complete! Navigating to home...');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
      } else {
        debugPrint('Sign in did not complete - isSignedIn: ${auth.isSignedIn}, mounted: $mounted');
        
        // Check the sign-in status and show appropriate error
        final signInStatus = auth.client?.signIn?.status;
        if (mounted) {
          String errorMessage = 'Sign in failed';
          
          if (signInStatus == 'needs_first_factor') {
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          } else if (signInStatus != null) {
            errorMessage = 'Sign in failed: $signInStatus';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 4),
            ),
          );
        }
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
    debugPrint('=== SIGN IN COMPLETE ===');
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
}