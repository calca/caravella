import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/history/expenses_history_page.dart';
import '../../../settings/pages/settings_page.dart';

class SimpleBottomBar extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const SimpleBottomBar({
    super.key,
    required this.localizations,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 0), // Solo padding superiore
      alignment: Alignment.topLeft, // Allineamento in alto a sinistra
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Allinea a sinistra
        crossAxisAlignment: CrossAxisAlignment.start, // Allinea in alto
        children: [
          // Bottone Tutti
          Flexible(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExpesensHistoryPage(),
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              child: Text(
                localizations.all.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),

          const SizedBox(width: 8), // Spazio tra i bottoni ridotto
          // Bottone Opzioni
          Flexible(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              ),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.8,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              child: Text(
                localizations.options.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
