import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import '../../../settings/user_name_notifier.dart';

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
          return theme.colorScheme.onSurface;
        case 'dev':
        case 'staging':
        default:
          return theme.colorScheme.tertiary;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar statico
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getGreetingIcon(),
              size: 28,
              color: getFlavorBgColor(),
            ),
          ),
          const SizedBox(width: 16),

          // Saluto su due righe (saluto + nome), centrato verticalmente
          Expanded(
            child: Consumer<UserNameNotifier>(
              builder: (context, userNameNotifier, child) {
                final greeting = _resolveGreeting();
                final hasName = userNameNotifier.hasName;
                final name = hasName ? userNameNotifier.name : null;

                return SizedBox(
                  height: 56, // allinea verticalmente con l'avatar
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: (name == null || name.isEmpty)
                            ? theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              )
                            : theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface,
                              ),
                      ),
                      if (name != null && name.isNotEmpty)
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _resolveGreeting() {
    final key = _getGreetingKey();
    final baseGreeting = switch (key) {
      'good_morning' => localizations.good_morning,
      'good_afternoon' => localizations.good_afternoon,
      _ => localizations.good_evening,
    };

    // Try to get user name if available
    return baseGreeting;
  }
}
