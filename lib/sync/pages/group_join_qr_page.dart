import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/services/logger_service.dart';
import '../../data/expense_group_storage_v2.dart';
import '../widgets/qr_scanner_widget.dart';
import '../services/group_sync_coordinator.dart';
import '../services/revenue_cat_service.dart';
import '../utils/auth_guard.dart';
import '../models/subscription_tier.dart';
import '../../manager/details/pages/expense_group_detail_page.dart';
import '../../widgets/toast.dart';
import 'donation_page.dart';
import 'subscription_page.dart';

/// Page for joining a group by scanning a QR code
/// Requires authentication before showing the scanner
class GroupJoinQrPage extends StatefulWidget {
  const GroupJoinQrPage({super.key});

  @override
  State<GroupJoinQrPage> createState() => _GroupJoinQrPageState();
}

class _GroupJoinQrPageState extends State<GroupJoinQrPage> {
  final _syncCoordinator = GroupSyncCoordinator();
  final _revenueCat = RevenueCatService();
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  SubscriptionStatus? _subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authenticated = await AuthGuard.requireAuth(context);
    
    // Also check subscription if RevenueCat is configured
    SubscriptionStatus? status;
    if (_revenueCat.isConfigured) {
      try {
        status = await _revenueCat.getSubscriptionStatus();
      } catch (e) {
        LoggerService.error('Failed to check subscription: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
        _subscriptionStatus = status;
        _isCheckingAuth = false;
      });
      
      // If not authenticated, go back
      if (!authenticated) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _onGroupJoined(String groupId) async {
    try {
      LoggerService.info('Group joined: $groupId, checking limits...');

      // Check subscription limits if RevenueCat is configured
      if (_revenueCat.isConfigured && _subscriptionStatus != null) {
        // Check if subscription is active
        if (!_subscriptionStatus!.isActive) {
          if (mounted) {
            AppToast.show(
              context,
              'You need an active subscription to join shared groups.',
              type: ToastType.error,
            );
            Navigator.of(context).pop();
            return;
          }
        }

        // Get all synced groups count
        final allGroups = await ExpenseGroupStorageV2.getAllGroups();
        final syncedGroups = allGroups.where((g) => g.syncEnabled).length;

        // Check group limit
        if (!_subscriptionStatus!.canShareGroup(syncedGroups)) {
          if (mounted) {
            final limits = _subscriptionStatus!.limits;
            
            // Show donation page if RevenueCat not configured, otherwise show upgrade option
            if (!_revenueCat.isConfigured) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const DonationPage(isFromUpgradeFlow: true),
                ),
              );
              Navigator.of(context).pop();
              return;
            } else {
              AppToast.show(
                context,
                'You have reached the maximum of ${limits.maxSharedGroups} shared groups for your ${_subscriptionStatus!.tier.name.toUpperCase()} plan. Upgrade to PREMIUM for unlimited groups.',
                type: ToastType.error,
              );
              
              // Show subscription page for upgrade
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SubscriptionPage(isFromShareFlow: true),
                ),
              );
              Navigator.of(context).pop();
              return;
            }
          }
        }

        // Load the group to check participant count
        final group = await ExpenseGroupStorageV2.getTripById(groupId);
        if (group != null) {
          final participantCount = group.participants.length;
          if (!_subscriptionStatus!.canAddParticipant(participantCount)) {
            if (mounted) {
              final limits = _subscriptionStatus!.limits;
              
              // Show donation page if RevenueCat not configured, otherwise show upgrade option
              if (!_revenueCat.isConfigured) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const DonationPage(isFromUpgradeFlow: true),
                  ),
                );
                Navigator.of(context).pop();
                return;
              } else {
                AppToast.show(
                  context,
                  'This group has ${participantCount} participants. Your ${_subscriptionStatus!.tier.name.toUpperCase()} plan allows maximum ${limits.maxParticipantsPerGroup} participants per group. Upgrade to PREMIUM for unlimited participants.',
                  type: ToastType.error,
                );
                
                // Show subscription page for upgrade
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const SubscriptionPage(isFromShareFlow: true),
                  ),
                );
                Navigator.of(context).pop();
                return;
              }
            }
          }
        }
      }

      // Initialize sync for the joined group
      await _syncCoordinator.initializeGroupSync(groupId);

      // Load the group to navigate to its detail page
      final group = await ExpenseGroupStorageV2.getTripById(groupId);

      if (group != null && mounted) {
        // Navigate to the group detail page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => ExpenseGroupDetailPage(trip: group),
          ),
        );
      } else if (mounted) {
        // Group not found yet (will be synced)
        Navigator.of(context).pop();
      }
    } catch (e) {
      LoggerService.error('Failed to complete group join: $e');
      if (mounted) {
        AppToast.show(
          context,
          'Failed to join group. Please try again.',
          type: ToastType.error,
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Show loading while checking authentication
    if (_isCheckingAuth) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Join Group'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If not authenticated, show empty scaffold (will navigate back)
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Join Group'),
        ),
        body: const Center(
          child: Text('Authentication required'),
        ),
      );
    }

    // Authenticated - show scanner
    return Scaffold(
      body: Stack(
        children: [
          QrScannerWidget(onGroupJoined: _onGroupJoined),
          // Help button at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () => _showHelp(context),
              backgroundColor: theme.colorScheme.surface,
              child: Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'How to Join a Group',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpStep(
              '1',
              'Ask the group owner to generate a QR code',
              theme,
            ),
            _buildHelpStep(
              '2',
              'Point your camera at the QR code',
              theme,
            ),
            _buildHelpStep(
              '3',
              'Wait for the app to process the code',
              theme,
            ),
            _buildHelpStep(
              '4',
              'You will be added to the group and data will sync',
              theme,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpStep(String number, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
