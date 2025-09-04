import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/dream_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<DreamService>(
          builder: (context, dreamService, child) {
            final stats = dreamService.getDreamStats();
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildProfileCard(stats),
                  const SizedBox(height: 30),
                  _buildStatsGrid(stats),
                  const SizedBox(height: 30),
                  _buildSettingsSection(context),
                ],
              ),
            );
          },
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
          'Track your dream journey',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.shadowGrey,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.2),
      ],
    );
  }

  Widget _buildProfileCard(Map<String, int> stats) {
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
            'Dream Explorer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.cloudWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats['total']} dreams captured',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.cloudWhite.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    final statItems = [
      {'title': 'Total Dreams', 'value': stats['total']!, 'icon': Icons.auto_stories},
      {'title': 'This Week', 'value': stats['thisWeek']!, 'icon': Icons.calendar_today},
      {'title': 'This Month', 'value': stats['thisMonth']!, 'icon': Icons.calendar_month},
      {'title': 'Favorites', 'value': stats['favorites']!, 'icon': Icons.favorite},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cloudWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mistGrey),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowGrey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item['icon'] as IconData,
                size: 30,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  '${item['value']}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.nightGrey,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.shadowGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms, delay: (300 + index * 50).ms)
          .slideY(begin: 0.2);
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final settingsItems = [
      {
        'title': 'Export Dreams',
        'subtitle': 'Export your dreams to a file',
        'icon': Icons.download,
        'onTap': () => _showComingSoonDialog(context),
      },
      {
        'title': 'Dream Analysis',
        'subtitle': 'Configure AI analysis settings',
        'icon': Icons.psychology,
        'onTap': () => _showComingSoonDialog(context),
      },
      {
        'title': 'Notifications',
        'subtitle': 'Dream reminder settings',
        'icon': Icons.notifications,
        'onTap': () => _showComingSoonDialog(context),
      },
      {
        'title': 'Privacy',
        'subtitle': 'Data and privacy settings',
        'icon': Icons.privacy_tip,
        'onTap': () => _showComingSoonDialog(context),
      },
      {
        'title': 'About',
        'subtitle': 'App version and information',
        'icon': Icons.info,
        'onTap': () => _showAboutDialog(context),
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
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.ultraLightPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: AppColors.primaryPurple,
                  size: 20,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(item['subtitle'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is coming in a future update!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Dreamdex',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          gradient: AppColors.dreamGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.bedtime,
          size: 32,
          color: AppColors.cloudWhite,
        ),
      ),
      children: const [
        Text('A beautiful app for tracking and analyzing your dreams with AI.'),
      ],
    );
  }
}