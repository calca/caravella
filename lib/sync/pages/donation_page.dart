import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../widgets/toast.dart';
import '../../data/services/logger_service.dart';

/// Donation page shown when RevenueCat is not configured
/// Invites users to support the app via Buy Me a Coffee
class DonationPage extends StatelessWidget {
  final bool isFromUpgradeFlow;

  const DonationPage({
    super.key,
    this.isFromUpgradeFlow = false,
  });

  // Build-time constant - set via --dart-define=BUYMEACOFFEE_URL=...
  static const String buyMeCoffeeUrl = String.fromEnvironment(
    'BUYMEACOFFEE_URL',
    defaultValue: 'https://www.buymeacoffee.com/caravella',
  );

  Future<void> _openBuyMeCoffee(BuildContext context) async {
    try {
      final uri = Uri.parse(buyMeCoffeeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        LoggerService.info('Opened Buy Me a Coffee link');
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      LoggerService.error('Failed to open Buy Me a Coffee: $e');
      if (context.mounted) {
        AppToast.show(
          context,
          'Could not open donation link',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gloc = gen.AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Caravella'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon
            Icon(
              Icons.favorite,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Support Our Work',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              isFromUpgradeFlow
                  ? 'Want to use more than 1 group or add more than 2 participants? '
                      'Consider supporting our work to help us maintain and improve Caravella!'
                  : 'Caravella is free and open source. Your support helps us maintain '
                      'and improve the app for everyone.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Benefits card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How Your Support Helps',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      Icons.cloud_sync,
                      'Maintain sync infrastructure',
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.bug_report_outlined,
                      'Fix bugs and improve stability',
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.new_releases_outlined,
                      'Develop new features',
                    ),
                    _buildBenefitItem(
                      context,
                      Icons.security,
                      'Keep your data secure',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // FREE tier reminder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'FREE tier (1 group, 2 participants) will always remain free',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buy Me a Coffee button
            ElevatedButton.icon(
              onPressed: () => _openBuyMeCoffee(context),
              icon: const Icon(Icons.coffee),
              label: const Text('Buy Me a Coffee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDD00), // Buy Me a Coffee yellow
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 16),

            // Maybe later button
            if (isFromUpgradeFlow)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Maybe Later'),
              ),
            const SizedBox(height: 16),

            // Note
            Text(
              'Donations are voluntary and help us keep the app free for everyone. '
              'No features are locked behind donations.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
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
