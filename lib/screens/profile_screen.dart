import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/app_colors.dart';
import '../services/subscription_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/convex_service.dart';
import '../widgets/paywall_dialog.dart';
import 'auth/login_screen.dart';
import 'auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProfileCard(context),
              const SizedBox(height: 30),
              _buildSettingsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.nightGrey,
          ),
        ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
        const SizedBox(height: 8),
        Text(
          'Manage your account',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.shadowGrey,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final user = authService.currentUser;
    
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.dreamGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.cloudWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? user?.email?.split('@')[0] ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.cloudWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'No email',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.cloudWhite.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: subscriptionService.isPremium 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: subscriptionService.isPremium 
                    ? Colors.green
                    : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              subscriptionService.isPremium ? 'Premium User' : 'Free User',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subscriptionService.isPremium 
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
      },
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }


  Widget _buildSettingsSection(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final settingsItems = [
      {
        'title': subscriptionService.isPremium ? 'Manage Subscription' : 'Upgrade to Premium',
        'subtitle': subscriptionService.isPremium 
            ? 'View and manage your subscription' 
            : 'Unlock all features',
        'icon': subscriptionService.isPremium ? Icons.subscriptions : Icons.star,
        'onTap': () => subscriptionService.isPremium 
            ? _handleManageSubscription() 
            : _handleUpgradeToPremium(context),
        'isPremium': !subscriptionService.isPremium,
      },
      {
        'title': 'Restore Purchases',
        'subtitle': 'Restore previous purchases',
        'icon': Icons.restore,
        'onTap': () => _handleRestorePurchases(context, subscriptionService),
      },
      {
        'title': 'Support',
        'subtitle': 'Get help and contact us',
        'icon': Icons.support_agent,
        'onTap': () => _handleContactSupport(),
      },
      {
        'title': 'Privacy Policy',
        'subtitle': 'View privacy policy',
        'icon': Icons.privacy_tip,
        'onTap': () => _openUrl('https://your-privacy-policy-url.com'),
      },
      {
        'title': 'Terms of Service',
        'subtitle': 'View terms of service',
        'icon': Icons.article,
        'onTap': () => _openUrl('https://your-terms-url.com'),
      },
      {
        'title': 'Sign Out',
        'subtitle': 'Sign out of your account',
        'icon': Icons.logout,
        'onTap': () => _handleSignOut(context),
        'isDestructive': true,
      },
    ];

        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.nightGrey,
          ),
        ),
        const SizedBox(height: 16),
        ...settingsItems.map((item) {
          final isDestructive = item['isDestructive'] == true;
          final isPremium = item['isPremium'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive 
                      ? Colors.red.withOpacity(0.1) 
                      : isPremium 
                          ? Colors.amber.withOpacity(0.1)
                          : AppColors.ultraLightPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: isDestructive 
                      ? Colors.red 
                      : isPremium 
                          ? Colors.amber[700]
                          : AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDestructive 
                      ? Colors.red 
                      : isPremium 
                          ? Colors.amber[700]
                          : null,
                ),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: TextStyle(
                  color: isDestructive ? Colors.red.withOpacity(0.7) : null,
                ),
              ),
              trailing: isPremium 
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_ios, 
                      size: 16,
                      color: isDestructive ? Colors.red : null,
                    ),
              onTap: item['onTap'] as VoidCallback,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
        // Danger Zone section
        const SizedBox(height: 32),
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 20,
              ),
            ),
            title: const Text(
              'Delete Account',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            subtitle: const Text(
              'Permanently delete your account',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios, 
              size: 16,
              color: Colors.red,
            ),
            onTap: () => _handleDeleteAccount(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        ],
      );
      },
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  void _handleManageSubscription() async {
    const url = 'https://apps.apple.com/account/subscriptions'; // iOS
    // For Android, you'd use: 'https://play.google.com/store/account/subscriptions'
    await _openUrl(url);
  }

  void _handleUpgradeToPremium(BuildContext context) async {
    await showPaywall(context, PremiumFeature.aiAnalysis);
  }

  void _handleRestorePurchases(BuildContext context, SubscriptionService subscriptionService) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Restoring purchases...'),
          ],
        ),
      ),
    );

    try {
      final success = await subscriptionService.restorePurchases();
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        if (success) {
          _showSnackBar(context, 'Purchases restored successfully!', isError: false);
        } else {
          _showSnackBar(context, 'No purchases found to restore', isError: false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar(context, 'Failed to restore purchases: ${subscriptionService.errorMessage ?? e.toString()}', isError: true);
      }
    }
  }


  void _handleContactSupport() async {
    const email = 'support@dreamdex.com'; // Replace with your support email
    const subject = 'Dreamdex App Support';
    final url = 'mailto:$email?subject=${Uri.encodeComponent(subject)}';
    await _openUrl(url);
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Failed to open URL: $e');
    }
  }

  void _handleDeleteAccount(BuildContext context) {
    // Get services before showing dialog to avoid Provider context issues
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final convexService = Provider.of<ConvexService>(context, listen: false);
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your dreams and data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog

              if (context.mounted) {
                try {
                  debugPrint('=== STARTING ACCOUNT DELETION ===');
                  
                  if (authService.currentUser == null) {
                    _showSnackBar(context, 'No user logged in', isError: true);
                    return;
                  }

                  final firebaseUid = authService.currentUser!.uid;
                  
                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Deleting your account...',
                            style: TextStyle(color: AppColors.nightGrey),
                          ),
                        ],
                      ),
                    ),
                  );

                  // 1. First delete from Convex (dreams and user data)
                  
                  final convexResult = await convexService.deleteAccount(firebaseUid, null);
                  if (convexResult == null) {
                    if (context.mounted) Navigator.pop(context); // Close loading dialog
                    _showSnackBar(context, 'Failed to delete user data. Please try again.', isError: true);
                    return;
                  }

                  // 2. Clear subscription service user data
                  await subscriptionService.clearUserId();

                  // 3. Sign out locally
                  try {
                    // Sign out from Firebase
                    await authService.signOut();
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context); // Close loading dialog
                    _showSnackBar(context, 'Failed to sign out: $e', isError: true);
                    return;
                  }

                  // Close loading dialog
                  if (context.mounted) Navigator.pop(context);

                  // Show success message and navigate to welcome screen
                  _showSnackBar(context, 'Account data deleted successfully. ${convexResult['deletedDreams']} dreams were removed. You have been signed out.', isError: false);
                  
                  // Navigate to welcome screen after a delay
                  await Future.delayed(const Duration(seconds: 2));
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                    );
                  }
                } catch (e, stackTrace) {
                  // Close loading dialog if it's open
                  debugPrint('Error during account deletion: $e');
                  debugPrint('Stack trace: $stackTrace');
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  _showSnackBar(context, 'Failed to delete account: $e', isError: true);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              debugPrint('=== SIGN OUT BUTTON PRESSED ===');
              
              // Store navigator before any async operations
              final navigator = Navigator.of(context);
              
              navigator.pop(); // Close dialog
              debugPrint('Dialog closed');
              
              final authService = Provider.of<FirebaseAuthService>(context, listen: false);
              final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
              
              debugPrint('Starting logout process...');
              debugPrint('User before logout: ${authService.currentUser?.uid}');
              
              try {
                // Clear subscription service data first (this handles RevenueCat logout)
                debugPrint('Clearing subscription data...');
                await subscriptionService.clearUserId();
                debugPrint('Subscription data cleared');
              } catch (e) {
                debugPrint('Error clearing subscription data: $e');
                // Continue with logout even if this fails
              }
              
              try {
                // Then sign out from Firebase if user is authenticated
                if (authService.currentUser != null) {
                  debugPrint('Signing out from Firebase...');
                  await authService.signOut();
                  debugPrint('Firebase sign out completed');
                } else {
                  debugPrint('User already null, skipping Firebase signout');
                }
              } catch (e) {
                debugPrint('Error signing out from Firebase: $e');
                // Continue with navigation even if this fails
              }
              
              // Navigate using the stored navigator
              debugPrint('Navigating to login screen...');
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
              debugPrint('Navigation completed');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}