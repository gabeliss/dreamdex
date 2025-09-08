import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';

class PaywallDialog extends StatefulWidget {
  final PremiumFeature feature;
  final String? customTitle;
  final String? customDescription;

  const PaywallDialog({
    super.key,
    required this.feature,
    this.customTitle,
    this.customDescription,
  });

  @override
  State<PaywallDialog> createState() => _PaywallDialogState();
}

class _PaywallDialogState extends State<PaywallDialog> {
  bool _isLoading = false;

  String get _featureTitle {
    if (widget.customTitle != null) return widget.customTitle!;
    
    switch (widget.feature) {
      case PremiumFeature.aiAnalysis:
        return 'AI Dream Analysis';
      case PremiumFeature.imageGeneration:
        return 'Dream Image Generation';
      case PremiumFeature.unlimitedDreams:
        return 'Unlimited Dreams';
    }
  }

  String get _featureDescription {
    if (widget.customDescription != null) return widget.customDescription!;
    
    switch (widget.feature) {
      case PremiumFeature.aiAnalysis:
        return 'Get unlimited AI-powered analysis of your dreams with detailed insights and interpretations.';
      case PremiumFeature.imageGeneration:
        return 'Generate beautiful AI images based on your dreams to visualize your subconscious experiences.';
      case PremiumFeature.unlimitedDreams:
        return 'Record and store unlimited dreams without any monthly restrictions.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        final monthlyPackage = subscriptionService.monthlyPackage;
        final annualPackage = subscriptionService.annualPackage;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upgrade to Premium',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Unlock $_featureTitle',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        _featureDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Premium features list
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureItem('Unlimited AI Dream Analysis'),
                            _buildFeatureItem('AI Image Generation'),
                            _buildFeatureItem('Unlimited Dream Storage'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Subscription packages
                if (subscriptionService.offerings.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        if (annualPackage != null)
                          _buildSubscriptionButton(
                            annualPackage,
                            'Best Value',
                            subscriptionService,
                            isPrimary: true,
                          ),
                        if (annualPackage != null && monthlyPackage != null)
                          const SizedBox(height: 12),
                        if (monthlyPackage != null)
                          _buildSubscriptionButton(
                            monthlyPackage,
                            null,
                            subscriptionService,
                          ),
                      ],
                    ),
                  ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Maybe Later',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cancel anytime • Restore purchases',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionButton(
    Package package,
    String? badge,
    SubscriptionService subscriptionService, {
    bool isPrimary = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isPrimary ? null : Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isLoading ? null : () => _handlePurchase(package, subscriptionService),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isPrimary ? const Color(0xFF667eea) : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  package.storeProduct.title,
                  style: TextStyle(
                    color: isPrimary ? const Color(0xFF667eea) : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  package.storeProduct.priceString,
                  style: TextStyle(
                    color: isPrimary ? Colors.black87 : Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? const Color(0xFF667eea) : Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase(Package package, SubscriptionService subscriptionService) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await subscriptionService.purchasePackage(package);
      if (success && mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Welcome to Premium! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Utility function to show paywall
Future<bool?> showPaywall(
  BuildContext context, 
  PremiumFeature feature, {
  String? title,
  String? description,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PaywallDialog(
      feature: feature,
      customTitle: title,
      customDescription: description,
    ),
  );
}