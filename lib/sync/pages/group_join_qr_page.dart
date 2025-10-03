import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/services/logger_service.dart';
import '../widgets/qr_scanner_widget.dart';
import '../services/group_sync_coordinator.dart';
import '../../data/expense_group_storage_v2.dart';
import '../../manager/details/pages/expense_group_detail_page.dart';

/// Page for joining a group by scanning a QR code
class GroupJoinQrPage extends StatefulWidget {
  const GroupJoinQrPage({super.key});

  @override
  State<GroupJoinQrPage> createState() => _GroupJoinQrPageState();
}

class _GroupJoinQrPageState extends State<GroupJoinQrPage> {
  final _syncCoordinator = GroupSyncCoordinator();

  Future<void> _onGroupJoined(String groupId) async {
    try {
      LoggerService.info('Group joined: $groupId, initializing sync...');

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
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

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
