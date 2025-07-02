import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../manager/trips_history_page.dart';
import '../../../settings/settings_page.dart';

class SimpleBottomBar extends StatelessWidget {
  final AppLocalizations localizations;
  final ThemeData theme;

  const SimpleBottomBar({
    super.key,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: 20), // Rimosso padding orizzontale
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Allinea a sinistra
        children: [
          // Bottone Tutti
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const TripsHistoryPage()),
            ),
            style: TextButton.styleFrom(
              foregroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text(
              localizations.get('all').toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16), // Spazio tra i bottoni

          // Bottone Opzioni
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
            style: TextButton.styleFrom(
              foregroundColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Text(
              localizations.get('options').toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
