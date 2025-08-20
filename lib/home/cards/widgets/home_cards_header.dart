import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class HomeCardsHeader extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const HomeCardsHeader({
    super.key,
    required this.localizations,
    required this.theme,
  });

  String _getGreetingKey() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning';
    if (hour < 18) return 'good_afternoon';
    return 'good_evening';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_outlined; // Sole del mattino
    if (hour < 18) return Icons.wb_sunny; // Sole pieno del pomeriggio
    return Icons.nights_stay_outlined; // Luna della sera
  }

  @override
  Widget build(BuildContext context) {
    Color getFlavorBgColor() {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
      switch (flavor) {
        case 'prod':
          return theme.colorScheme.surfaceContainerHigh;
        case 'dev':
          return theme.colorScheme.tertiaryFixed;
        case 'staging':
        default:
          return theme.colorScheme.secondaryFixed;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          // Avatar statico
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: getFlavorBgColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getGreetingIcon(),
              size: 28,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),

          // Saluto dinamico
          Expanded(
            child: Text(
              _resolveGreeting(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resolveGreeting() {
    final key = _getGreetingKey();
    if (key == 'good_morning') return localizations.good_morning;
    if (key == 'good_afternoon') return localizations.good_afternoon;
    return localizations.good_evening;
  }
}
