import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/model/expense_group.dart';
import '../../data/services/logger_service.dart';
import '../../data/expense_group_storage_v2.dart';
import '../services/qr_generation_service.dart';
import '../services/group_sync_coordinator.dart';
import '../services/revenue_cat_service.dart';
import '../models/subscription_tier.dart';
import '../widgets/qr_display_widget.dart';
import '../../widgets/toast.dart';
import 'subscription_page.dart';

/// Page for sharing a group via QR code
class GroupShareQrPage extends StatefulWidget {
  final ExpenseGroup group;

  const GroupShareQrPage({
    super.key,
    required this.group,
  });

  @override
  State<GroupShareQrPage> createState() => _GroupShareQrPageState();
}

class _GroupShareQrPageState extends State<GroupShareQrPage> {
  final _qrService = QrGenerationService();
  final _syncCoordinator = GroupSyncCoordinator();
  final _revenueCat = RevenueCatService();
  bool _isGenerating = false;
  bool _isInitializingSync = false;
  bool _isCheckingSubscription = true;
  SubscriptionStatus? _subscriptionStatus;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAndInitialize();
  }

  Future<void> _checkSubscriptionAndInitialize() async {
    // Check subscription status
    if (_revenueCat.isConfigured) {
      try {
        final status = await _revenueCat.getSubscriptionStatus();
        if (mounted) {
          setState(() {
            _subscriptionStatus = status;
            _isCheckingSubscription = false;
          });
        }

        // If no active subscription, show subscription page
        if (!status.isActive) {
          if (mounted) {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (ctx) => const SubscriptionPage(isFromShareFlow: true),
              ),
            );

            // If user didn't subscribe, go back
            if (result != true && mounted) {
              Navigator.of(context).pop();
              return;
            }

            // Reload subscription status after purchase
            if (mounted) {
              final newStatus = await _revenueCat.getSubscriptionStatus();
              setState(() => _subscriptionStatus = newStatus);
            }
          }
        }

        // Check group and participant limits
        if (mounted && _subscriptionStatus != null) {
          await _checkLimits();
        }
      } catch (e) {
        LoggerService.error('Failed to check subscription: $e');
        if (mounted) {
          setState(() => _isCheckingSubscription = false);
        }
      }
    } else {
      // No RevenueCat configured, allow access
      setState(() => _isCheckingSubscription = false);
    }

    await _initializeGroupSharingIfNeeded();
  }

  Future<void> _checkLimits() async {
    if (_subscriptionStatus == null || !_subscriptionStatus!.isActive) {
      return;
    }

    try {
      // Get all synced groups count
      final allGroups = await ExpenseGroupStorageV2.getAllGroups();
      final syncedGroups = allGroups.where((g) => g.syncEnabled).length;

      // Check group limit
      if (!_subscriptionStatus!.canShareGroup(syncedGroups)) {
        if (mounted) {
          final limits = _subscriptionStatus!.limits;
          AppToast.show(
            context,
            'You have reached the maximum of ${limits.maxSharedGroups} shared groups for your ${_subscriptionStatus!.tier.name.toUpperCase()} plan.',
            type: ToastType.error,
          );
          Navigator.of(context).pop();
          return;
        }
      }

      // Check participant limit
      final participantCount = widget.group.participants.length;
      if (!_subscriptionStatus!.canAddParticipant(participantCount)) {
        if (mounted) {
          final limits = _subscriptionStatus!.limits;
          AppToast.show(
            context,
            'This group has ${participantCount} participants. Your ${_subscriptionStatus!.tier.name.toUpperCase()} plan allows maximum ${limits.maxParticipantsPerGroup} participants per group.',
            type: ToastType.error,
          );
          Navigator.of(context).pop();
          return;
        }
      }
    } catch (e) {
      LoggerService.error('Failed to check limits: $e');
    }
  }

  Future<void> _initializeGroupSharingIfNeeded() async {
    // Check if group already has encryption enabled
    final hasKey = await _qrService.hasGroupKey(widget.group.id);
    if (!hasKey) {
      // Initialize encryption for this group
      await _qrService.initializeGroupEncryption(widget.group.id);
    }
  }

  Future<void> _generateAndShowQr() async {
    setState(() => _isGenerating = true);

    try {
      final gloc = gen.AppLocalizations.of(context);

      // Generate QR payload
      final payload = await _qrService.generateQrPayload(widget.group.id);

      if (payload == null) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.no_expenses_to_export,
            type: ToastType.error,
          );
        }
        return;
      }

      // Navigate to QR display page
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => QrDisplayWidget(payload: payload),
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to generate QR: $e');
      if (mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
          gloc.csv_save_error,
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _enableSync() async {
    setState(() => _isInitializingSync = true);

    try {
      final gloc = gen.AppLocalizations.of(context);

      // Initialize sync for this group
      final success = await _syncCoordinator.initializeGroupSync(widget.group.id);

      if (!success) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.csv_save_error,
            type: ToastType.error,
          );
        }
        return;
      }

      if (mounted) {
        AppToast.show(
          context,
          'Sync enabled successfully',
          type: ToastType.success,
        );
        Navigator.of(context).pop(true); // Return true to indicate sync was enabled
      }
    } catch (e) {
      LoggerService.error('Failed to enable sync: $e');
      if (mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
          gloc.csv_save_error,
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializingSync = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Show loading while checking subscription
    if (_isCheckingSubscription) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Share Group'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Group'),
        actions: [
          if (_subscriptionStatus != null && _subscriptionStatus!.isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(
                  _subscriptionStatus!.tier.name.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 100,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Multi-Device Sync',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Share this group with your other devices using a QR code. '
                  'All data will be end-to-end encrypted and synced in real-time.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      context,
                      '1',
                      'Generate a QR code on this device',
                    ),
                    _buildStep(
                      context,
                      '2',
                      'Scan the QR code with your other device',
                    ),
                    _buildStep(
                      context,
                      '3',
                      'Both devices will sync automatically',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateAndShowQr,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (!widget.group.syncEnabled)
              OutlinedButton.icon(
                onPressed: _isInitializingSync ? null : _enableSync,
                icon: _isInitializingSync
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_sync),
                label: const Text('Enable Sync'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            const SizedBox(height: 32),
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          size: 20,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Security',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only share QR codes with devices you own. '
                          'Data is end-to-end encrypted and never stored unencrypted on servers.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
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
