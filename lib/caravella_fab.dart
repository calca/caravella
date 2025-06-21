import 'package:flutter/material.dart';
import 'history_page.dart';
import 'add_trip_page.dart';
import 'app_localizations.dart';
import 'settings_page.dart';

class CaravellaFab extends StatelessWidget {
  final void Function()? onRefresh;
  final AppLocalizations localizations;
  const CaravellaFab({super.key, this.onRefresh, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final navigator = Navigator.of(context);
        final result = await showModalBottomSheet<int>(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MenuButton(
                  icon: Icons.history,
                  label: localizations.get('history'),
                  onTap: () {
                    navigator.pop(0);
                  },
                ),
                _MenuButton(
                  icon: Icons.add,
                  label: localizations.get('add_trip'),
                  onTap: () {
                    navigator.pop(1);
                  },
                ),
                _MenuButton(
                  icon: Icons.settings,
                  label: localizations.get('settings'),
                  onTap: () {
                    navigator.pop(2);
                  },
                ),
              ],
            ),
          ),
        );
        if (result == 0) {
          navigator.push(
            MaterialPageRoute(
              builder: (context) => HistoryPage(localizations: localizations),
            ),
          );
        } else if (result == 1) {
          final addResult = await navigator.push(
            MaterialPageRoute(
              builder: (context) => AddTripPage(localizations: localizations),
            ),
          );
          if (addResult == true && onRefresh != null) {
            onRefresh!();
          }
        } else if (result == 2) {
          navigator.push(
            MaterialPageRoute(
              builder: (context) => SettingsPage(localizations: localizations),
            ),
          );
        }
      },
      child: const Icon(Icons.flight_takeoff),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 32),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
