import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import 'auth/login_screen.dart';

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
    final auth = ClerkAuth.of(context);
    final user = auth.user;
    
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
            user?.firstName ?? 'User',
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
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }


  Widget _buildSettingsSection(BuildContext context) {
    final settingsItems = [
      {
        'title': 'Manage Subscription',
        'subtitle': 'View and manage your subscription',
        'icon': Icons.subscriptions,
        'onTap': () => _handleManageSubscription(),
      },
      {
        'title': 'Restore Purchases',
        'subtitle': 'Restore previous purchases',
        'icon': Icons.restore,
        'onTap': () => _handleRestorePurchases(context),
      },
      {
        'title': 'Theme',
        'subtitle': 'Change app appearance',
        'icon': Icons.palette,
        'onTap': () => _showThemeDialog(context),
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
        'title': 'Delete Account',
        'subtitle': 'Permanently delete your account',
        'icon': Icons.delete_forever,
        'onTap': () => _handleDeleteAccount(context),
        'isDestructive': true,
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
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive ? Colors.red.withOpacity(0.1) : AppColors.ultraLightPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: isDestructive ? Colors.red : AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : null,
                ),
              ),
              subtitle: Text(
                item['subtitle'] as String,
                style: TextStyle(
                  color: isDestructive ? Colors.red.withOpacity(0.7) : null,
                ),
              ),
              trailing: Icon(
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
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2);
  }

  void _handleManageSubscription() async {
    const url = 'https://apps.apple.com/account/subscriptions'; // iOS
    // For Android, you'd use: 'https://play.google.com/store/account/subscriptions'
    await _openUrl(url);
  }

  void _handleRestorePurchases(BuildContext context) async {
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
      // TODO: Implement actual restore purchases logic with your in-app purchase plugin
      await Future.delayed(const Duration(seconds: 2)); // Placeholder
      
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar(context, 'Purchases restored successfully!', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar(context, 'Failed to restore purchases: $e', isError: true);
      }
    }
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Light theme selected', isError: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'Dark theme selected', isError: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('System'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(context, 'System theme selected', isError: false);
              },
            ),
          ],
        ),
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('Type "DELETE" to confirm account deletion:'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                try {
                  // TODO: Implement actual account deletion logic
                  _showSnackBar(context, 'Account deletion requested. You will be contacted within 24 hours.', isError: false);
                } catch (e) {
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
              Navigator.pop(context); // Close dialog
              
              try {
                final auth = ClerkAuth.of(context);
                await auth.signOut();
                
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sign out failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}