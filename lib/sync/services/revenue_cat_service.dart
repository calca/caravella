import 'package:purchases_flutter/purchases_flutter.dart';
import '../../data/services/logger_service.dart';
import '../models/subscription_tier.dart';

/// RevenueCat integration service for managing subscriptions
class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  SubscriptionStatus? _cachedStatus;

  /// Product IDs for subscriptions
  static const String basicProductId = 'caravella_basic_monthly';
  static const String premiumProductId = 'caravella_premium_monthly';

  /// Initialize RevenueCat SDK
  Future<void> initialize({
    required String apiKey,
    String? userId,
  }) async {
    if (_isInitialized) return;

    try {
      final configuration = PurchasesConfiguration(apiKey);
      if (userId != null) {
        configuration.appUserID = userId;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      
      LoggerService.info('RevenueCat initialized successfully');
    } catch (e) {
      LoggerService.error('Failed to initialize RevenueCat: $e');
      rethrow;
    }
  }

  /// Check if RevenueCat is configured
  bool get isConfigured {
    // Check if API key is available from environment
    const apiKey = String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
    return apiKey.isNotEmpty;
  }

  /// Get current subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    if (!_isInitialized) {
      if (!isConfigured) {
        // If not configured, return free tier (1 group, 2 participants)
        return const SubscriptionStatus(
          tier: SubscriptionTier.free,
          isActive: true,
        );
      }
      throw Exception('RevenueCat not initialized');
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      
      // Check entitlements
      final entitlements = customerInfo.entitlements.active;
      
      if (entitlements.containsKey('premium')) {
        final entitlement = entitlements['premium']!;
        return SubscriptionStatus(
          tier: SubscriptionTier.premium,
          isActive: true,
          expirationDate: entitlement.expirationDate != null 
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
          productId: entitlement.productIdentifier,
        );
      } else if (entitlements.containsKey('basic')) {
        final entitlement = entitlements['basic']!;
        return SubscriptionStatus(
          tier: SubscriptionTier.basic,
          isActive: true,
          expirationDate: entitlement.expirationDate != null
              ? DateTime.parse(entitlement.expirationDate!)
              : null,
          productId: entitlement.productIdentifier,
        );
      }

      // No active paid subscription - return FREE tier
      return const SubscriptionStatus(
        tier: SubscriptionTier.free,
        isActive: true,
      );
    } catch (e) {
      LoggerService.error('Failed to get subscription status: $e');
      
      // Return cached status if available
      if (_cachedStatus != null) {
        return _cachedStatus!;
      }
      
      rethrow;
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      LoggerService.error('Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      final result = await Purchases.purchasePackage(package);
      
      // Update cached status
      await _updateCachedStatus();
      
      return result.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        LoggerService.error('Purchase failed: $e');
      }
      return null;
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    if (!_isInitialized) {
      throw Exception('RevenueCat not initialized');
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      
      // Update cached status
      await _updateCachedStatus();
      
      return customerInfo;
    } catch (e) {
      LoggerService.error('Failed to restore purchases: $e');
      return null;
    }
  }

  /// Check if user has active subscription
  Future<bool> hasActiveSubscription() async {
    final status = await getSubscriptionStatus();
    return status.isActive;
  }

  /// Check if user can share a group (considering limits)
  Future<bool> canShareGroup(int currentSharedGroupsCount) async {
    final status = await getSubscriptionStatus();
    return status.canShareGroup(currentSharedGroupsCount);
  }

  /// Check if user can add participant to group (considering limits)
  Future<bool> canAddParticipant(int currentParticipantsCount) async {
    final status = await getSubscriptionStatus();
    return status.canAddParticipant(currentParticipantsCount);
  }

  /// Get subscription tier
  Future<SubscriptionTier> getSubscriptionTier() async {
    final status = await getSubscriptionStatus();
    return status.tier;
  }

  /// Update cached subscription status
  Future<void> _updateCachedStatus() async {
    try {
      _cachedStatus = await getSubscriptionStatus();
    } catch (e) {
      LoggerService.error('Failed to update cached status: $e');
    }
  }

  /// Listen to customer info updates
  void listenToCustomerInfo(Function(CustomerInfo) onUpdate) {
    if (!_isInitialized) return;
    
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      onUpdate(customerInfo);
      _updateCachedStatus();
    });
  }

  /// Set user ID for RevenueCat
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;

    try {
      await Purchases.logIn(userId);
      LoggerService.info('RevenueCat user ID set: $userId');
    } catch (e) {
      LoggerService.error('Failed to set RevenueCat user ID: $e');
    }
  }

  /// Log out user
  Future<void> logOut() async {
    if (!_isInitialized) return;

    try {
      await Purchases.logOut();
      _cachedStatus = null;
      LoggerService.info('RevenueCat user logged out');
    } catch (e) {
      LoggerService.error('Failed to log out RevenueCat user: $e');
    }
  }
}
