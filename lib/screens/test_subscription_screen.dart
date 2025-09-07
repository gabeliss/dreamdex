import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../widgets/paywall_dialog.dart';
import '../theme/app_colors.dart';

/// Test screen to verify RevenueCat integration for Dreamdex
class TestSubscriptionScreen extends StatelessWidget {
  const TestSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RevenueCat Test - Dreamdex'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(subscriptionService),
                const SizedBox(height: 20),
                _buildActionButtons(context, subscriptionService),
                const SizedBox(height: 20),
                _buildDebugInfo(subscriptionService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(SubscriptionService service) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.nightGrey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: service.isPremium 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: service.isPremium ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    service.isPremium ? Icons.star : Icons.star_border,
                    color: service.isPremium ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    service.isPremium ? 'Premium Active ✅' : 'Free User 🔒',
                    style: TextStyle(
                      fontSize: 18,
                      color: service.isPremium ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (service.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Loading...', style: TextStyle(color: Colors.grey)),
            ],
            if (service.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${service.errorMessage}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SubscriptionService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: service.isLoading ? null : () async {
            await service.refreshSubscriptionStatus();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Status'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: service.isLoading ? null : () async {
            await showPaywall(context, PremiumFeature.unlimitedDreams);
          },
          icon: const Icon(Icons.star),
          label: const Text('Show Paywall'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: AppColors.primaryPurple,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: service.isLoading ? null : () async {
            final success = await service.restorePurchases();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        success ? Icons.check_circle : Icons.info,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(success ? 'Purchases restored!' : 'No purchases found'),
                    ],
                  ),
                  backgroundColor: success ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          icon: const Icon(Icons.restore),
          label: const Text('Restore Purchases'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugInfo(SubscriptionService service) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.nightGrey,
              ),
            ),
            const SizedBox(height: 12),
            _buildDebugItem('Service Initialized', service.isInitialized.toString()),
            _buildDebugItem('Offerings Count', service.offerings.length.toString()),
            _buildDebugItem('Has Monthly Package', (service.monthlyPackage != null).toString()),
            _buildDebugItem('Has Annual Package', (service.annualPackage != null).toString()),
            if (service.customerInfo != null) ...[
              _buildDebugItem('Customer ID', service.customerInfo!.originalAppUserId ?? 'N/A'),
              _buildDebugItem('First Seen', service.customerInfo!.firstSeen.toString()),
            ],
            if (service.monthlyPackage != null)
              _buildDebugItem('Monthly Price', service.monthlyPackage!.storeProduct.priceString),
            if (service.annualPackage != null)
              _buildDebugItem('Annual Price', service.annualPackage!.storeProduct.priceString),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}