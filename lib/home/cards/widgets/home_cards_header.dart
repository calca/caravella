import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import '../../../settings/pages/settings_page.dart';

class HomeCardsHeader extends StatelessWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;

  const HomeCardsHeader({
    super.key,
    required this.localizations,
    required this.theme,
  });

  // Time slot for more expressive messages/icons
  String _getTimeSlot() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 8) return 'early_morning';
    if (h >= 8 && h < 12) return 'morning';
    if (h >= 12 && h < 14) return 'lunch';
    if (h >= 14 && h < 18) return 'afternoon';
    if (h >= 18 && h < 22) return 'evening';
    return 'night';
  }

  // Compact data holder for greeting UI
  static const _morning = 'morning';
  static const _earlyMorning = 'early_morning';
  static const _lunch = 'lunch';
  static const _afternoon = 'afternoon';
  static const _evening = 'evening';
  static const _night = 'night';

  _GreetingData _getGreetingData() {
    final slot = _getTimeSlot();
    final String message = switch (slot) {
      _earlyMorning || _morning => localizations.good_morning,
      _lunch || _afternoon => localizations.good_afternoon,
      _ => localizations.good_evening,
    };
    final IconData icon = switch (slot) {
      _earlyMorning => Icons.wb_twilight, // alba
      _morning => Icons.wb_sunny, // sole
      _lunch => Icons.lunch_dining, // pranzo
      _afternoon => Icons.wb_sunny_outlined, // pomeriggio
      _evening => Icons.wb_twilight, // tramonto
      _night => Icons.nights_stay_outlined, // notte
      _ => Icons.nights_stay_outlined,
    };
    return _GreetingData(message: message, icon: icon);
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

    return Row(
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
            _getGreetingData().icon,
            size: 28,
            color: getFlavorBgColor(),
          ),
        ),
        const SizedBox(width: 16),

        // Saluto su due righe (saluto + nome), centrato verticalmente
        Expanded(
          child: Consumer<UserNameNotifier>(
            builder: (context, userNameNotifier, child) {
              final greetingData = _getGreetingData();
              final hasName = userNameNotifier.hasName;
              final name = hasName ? userNameNotifier.name : null;

              return SizedBox(
                height: 56, // allinea verticalmente con l'avatar
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingData.message,
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
        const SizedBox(width: 8),

        // CTA button: apre direttamente la pagina delle impostazioni
        IconButton(
          icon: Icon(
            Icons.settings,
            color: theme.colorScheme.onSurface,
          ),
          tooltip: localizations.settings,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }
}

class _GreetingData {
  final String message;
  final IconData icon;
  const _GreetingData({required this.message, required this.icon});
}
