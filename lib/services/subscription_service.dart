import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _premiumEntitlementId = 'premium';
  static const String _lastSubscriptionCheckKey = 'last_subscription_check';
  static const Duration _cacheValidityDuration = Duration(hours: 1);

  bool _isInitialized = false;
  bool _isPremium = false;
  bool _isLoading = false;
  CustomerInfo? _customerInfo;
  List<Offering> _offerings = [];
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  CustomerInfo? get customerInfo => _customerInfo;
  List<Offering> get offerings => _offerings;
  String? get errorMessage => _errorMessage;

  // Premium feature limits for free users
  static const int freeDreamAnalysisLimit = 3;
  static const int freeImageGenerationLimit = 2;
  static const int freeDreamsPerMonthLimit = 10;

  /// Initialize RevenueCat with API keys
  /// Call this in main() before runApp()
  static Future<void> initialize({
    required String apiKey,
    String? appleApiKey,
    String? googleApiKey,
    bool enableDebugLogs = false,
  }) async {
    if (enableDebugLogs) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    late PurchasesConfiguration configuration;
    if (defaultTargetPlatform == TargetPlatform.android) {
      configuration = PurchasesConfiguration(googleApiKey ?? apiKey);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      configuration = PurchasesConfiguration(appleApiKey ?? apiKey);
    } else {
      configuration = PurchasesConfiguration(apiKey);
    }

    await Purchases.configure(configuration);
  }

  /// Initialize the service after RevenueCat is configured
  Future<void> initializeService() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _setError(null);
      
      // Add a small delay to ensure RevenueCat is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if we have cached subscription status
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastSubscriptionCheckKey) ?? 0;
      final cachedPremium = prefs.getBool('is_premium') ?? false;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final isExpired = now - lastCheck > _cacheValidityDuration.inMilliseconds;

      if (!isExpired && cachedPremium) {
        _isPremium = cachedPremium;
        notifyListeners();
      }

      // Always refresh from server, but don't block if we have cache
      await _refreshCustomerInfo();
      await _loadOfferings();

      _isInitialized = true;
      debugPrint('SubscriptionService initialized successfully');
    } catch (e) {
      _setError('Failed to initialize subscription service: ${e.toString()}');
      debugPrint('SubscriptionService initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh customer info from RevenueCat
  Future<void> refreshSubscriptionStatus() async {
    if (!_isInitialized) {
      await initializeService();
      return;
    }

    await _refreshCustomerInfo();
  }

  Future<void> _refreshCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      final wasPremium = _isPremium;
      _isPremium = _customerInfo?.entitlements.active.containsKey(_premiumEntitlementId) ?? false;

      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', _isPremium);
      await prefs.setInt(_lastSubscriptionCheckKey, DateTime.now().millisecondsSinceEpoch);

      if (wasPremium != _isPremium) {
        debugPrint('Subscription status changed: isPremium = $_isPremium');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing customer info: $e');
      _setError('Failed to refresh subscription status');
    }
  }

  /// Load available offerings (subscription packages)
  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      _offerings = offerings.all.values.toList();
      debugPrint('Loaded ${_offerings.length} offerings');
      
      // Log detailed offering information for debugging
      if (kDebugMode && _offerings.isNotEmpty) {
        for (final offering in _offerings) {
          debugPrint('Offering: ${offering.identifier}');
          for (final package in offering.availablePackages) {
            debugPrint('  Package: ${package.identifier} - ${package.storeProduct.title} - ${package.storeProduct.priceString}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
      
      // In development mode, provide more detailed error information
      if (kDebugMode) {
        debugPrint('This is likely because:');
        debugPrint('1. App Store Connect subscriptions are not yet approved');
        debugPrint('2. StoreKit configuration file needs to be selected in Xcode scheme');
        debugPrint('3. RevenueCat dashboard configuration doesn\'t match App Store Connect');
      }
      
      _setError('Failed to load subscription options');
    }
  }

  /// Purchase a subscription package
  Future<bool> purchasePackage(Package package) async {
    try {
      _setLoading(true);
      _setError(null);

      final purchaserInfo = await Purchases.purchasePackage(package);
      _customerInfo = purchaserInfo.customerInfo;
      _isPremium = _customerInfo?.entitlements.active.containsKey(_premiumEntitlementId) ?? false;

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', _isPremium);
      await prefs.setInt(_lastSubscriptionCheckKey, DateTime.now().millisecondsSinceEpoch);

      notifyListeners();
      return _isPremium;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Purchase cancelled by user');
        return false;
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        _setError('Payment is pending approval');
        return false;
      } else {
        _setError('Purchase failed: ${e.message}');
        debugPrint('Purchase error: ${e.message}');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error during purchase: ${e.toString()}');
      debugPrint('Unexpected purchase error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases() async {
    try {
      _setLoading(true);
      _setError(null);

      final restorerInfo = await Purchases.restorePurchases();
      _customerInfo = restorerInfo;
      _isPremium = _customerInfo?.entitlements.active.containsKey(_premiumEntitlementId) ?? false;

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', _isPremium);
      await prefs.setInt(_lastSubscriptionCheckKey, DateTime.now().millisecondsSinceEpoch);

      notifyListeners();
      return _isPremium;
    } catch (e) {
      _setError('Failed to restore purchases: ${e.toString()}');
      debugPrint('Restore purchases error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set user ID for RevenueCat (call when user logs in)
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
      await _refreshCustomerInfo();
    } catch (e) {
      debugPrint('Error setting user ID: $e');
    }
  }

  /// Clear user ID (call when user logs out)
  Future<void> clearUserId() async {
    try {
      await Purchases.logOut();
      _isPremium = false;
      _customerInfo = null;
      
      // Clear cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_premium');
      await prefs.remove(_lastSubscriptionCheckKey);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user ID: $e');
    }
  }

  /// Check if user can use a premium feature
  bool canUseFeature(PremiumFeature feature) {
    if (_isPremium) return true;

    // For free users, implement usage limits
    // This would typically check against stored usage counts
    return false; // Simplified for now
  }

  /// Get the primary offering (usually the default subscription)
  Offering? get primaryOffering {
    if (_offerings.isEmpty) return null;
    return _offerings.first;
  }

  /// Get monthly subscription package
  Package? get monthlyPackage {
    final offering = primaryOffering;
    if (offering == null) return null;
    
    return offering.availablePackages.firstWhere(
      (package) => package.packageType == PackageType.monthly,
      orElse: () => offering.availablePackages.first,
    );
  }

  /// Get annual subscription package
  Package? get annualPackage {
    final offering = primaryOffering;
    if (offering == null) return null;
    
    return offering.availablePackages.firstWhere(
      (package) => package.packageType == PackageType.annual,
      orElse: () => offering.availablePackages.first,
    );
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum PremiumFeature {
  aiAnalysis,
  imageGeneration,
  unlimitedDreams,
}