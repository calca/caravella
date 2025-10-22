import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../services/revenue_cat_service.dart';
import '../models/subscription_tier.dart';
import '../../data/services/logger_service.dart';
import '../../widgets/toast.dart';

/// Subscription page for purchasing BASIC or PREMIUM plans
class SubscriptionPage extends StatefulWidget {
  final bool isFromShareFlow; // True if shown from share button, false if from settings

  const SubscriptionPage({
    super.key,
    this.isFromShareFlow = false,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _revenueCat = RevenueCatService();
  bool _isLoading = true;
  bool _isPurchasing = false;
  Offerings? _offerings;
  SubscriptionStatus? _currentStatus;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _isLoading = true);

    try {
      final offerings = await _revenueCat.getOfferings();
      final status = await _revenueCat.getSubscriptionStatus();

      if (mounted) {
        setState(() {
          _offerings = offerings;
          _currentStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to load offerings: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _purchasePackage(Package package, SubscriptionTier tier) async {
    setState(() => _isPurchasing = true);

    try {
      final customerInfo = await _revenueCat.purchasePackage(package);

      if (customerInfo != null && mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
          'Subscription activated!',
          type: ToastType.success,
        );

        // If from share flow, pop with success
        if (widget.isFromShareFlow) {
          Navigator.of(context).pop(true);
        } else {
          // Reload status
          await _loadOfferings();
        }
      }
    } catch (e) {
      LoggerService.error('Purchase failed: $e');
      if (mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
          'Purchase failed. Please try again.',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    try {
      final customerInfo = await _revenueCat.restorePurchases();

      if (customerInfo != null && mounted) {
        AppToast.show(
          context,
          'Purchases restored!',
          type: ToastType.success,
        );
        await _loadOfferings();
      }
    } catch (e) {
      LoggerService.error('Restore failed: $e');
      if (mounted) {
        AppToast.show(
          context,
          'No purchases to restore.',
          type: ToastType.info,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        actions: [
          TextButton(
            onPressed: _isPurchasing ? null : _restorePurchases,
            child: const Text('Restore'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // FREE tier info
                  Card(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'FREE Tier (Always Available)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• Share 1 group\n'
                            '• Max 2 participants per group\n'
                            '• Real-time sync across devices\n'
                            '• End-to-end encryption',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (widget.isFromShareFlow) ...[
                    Icon(
                      Icons.upgrade,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upgrade for More',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'ve reached the FREE tier limit. Upgrade to share more groups and add more participants.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                  ] else ...[
                    Text(
                      'Upgrade Your Plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose the plan that fits your needs',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Current subscription status
                  if (_currentStatus?.isActive ?? false) ...[
                    Card(
                      color: theme.colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Current Plan: ${_currentStatus!.tier.name.toUpperCase()}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // BASIC Plan
                  _buildPlanCard(
                    context,
                    title: 'BASIC',
                    price: _getPackagePrice(RevenueCatService.basicProductId),
                    features: [
                      'Share up to 5 groups',
                      'Up to 5 participants per group',
                      'Real-time sync across devices',
                      'End-to-end encryption',
                      'QR code sharing',
                    ],
                    tier: SubscriptionTier.basic,
                    isRecommended: false,
                  ),

                  const SizedBox(height: 16),

                  // PREMIUM Plan
                  _buildPlanCard(
                    context,
                    title: 'PREMIUM',
                    price: _getPackagePrice(RevenueCatService.premiumProductId),
                    features: [
                      'Unlimited shared groups',
                      'Unlimited participants',
                      'Real-time sync across devices',
                      'End-to-end encryption',
                      'QR code sharing',
                      'Priority support',
                      'Advanced features',
                    ],
                    tier: SubscriptionTier.premium,
                    isRecommended: true,
                  ),

                  const SizedBox(height: 32),

                  // Terms and privacy
                  Text(
                    'Subscriptions will be charged to your App Store or Google Play account. '
                    'Auto-renewal can be turned off at any time from your account settings.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String? price,
    required List<String> features,
    required SubscriptionTier tier,
    required bool isRecommended,
  }) {
    final theme = Theme.of(context);
    final isCurrentPlan = _currentStatus?.tier == tier && (_currentStatus?.isActive ?? false);
    final package = _getPackage(tier);

    return Card(
      elevation: isRecommended ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isRecommended
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (isRecommended) const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                if (price != null) ...[
                  Text(
                    price,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'per month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                if (isCurrentPlan)
                  OutlinedButton(
                    onPressed: null,
                    child: const Text('Current Plan'),
                  )
                else if (package != null)
                  FilledButton(
                    onPressed: _isPurchasing
                        ? null
                        : () => _purchasePackage(package, tier),
                    style: FilledButton.styleFrom(
                      backgroundColor: isRecommended
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    child: _isPurchasing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Subscribe'),
                  )
                else
                  OutlinedButton(
                    onPressed: null,
                    child: const Text('Not Available'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getPackagePrice(String productId) {
    if (_offerings == null) return null;

    final currentOffering = _offerings!.current;
    if (currentOffering == null) return null;

    for (final package in currentOffering.availablePackages) {
      if (package.storeProduct.identifier == productId) {
        return package.storeProduct.priceString;
      }
    }

    return null;
  }

  Package? _getPackage(SubscriptionTier tier) {
    if (_offerings == null) return null;

    final currentOffering = _offerings!.current;
    if (currentOffering == null) return null;

    final productId = tier == SubscriptionTier.basic
        ? RevenueCatService.basicProductId
        : RevenueCatService.premiumProductId;

    for (final package in currentOffering.availablePackages) {
      if (package.storeProduct.identifier == productId) {
        return package;
      }
    }

    return null;
  }
}
