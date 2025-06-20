import 'package:flutter/material.dart';
import 'history_page.dart';
import 'add_trip_page.dart';
import 'app_localizations.dart';

class CaravellaFab extends StatelessWidget {
  final void Function()? onRefresh;
  final AppLocalizations localizations;
  const CaravellaFab({super.key, this.onRefresh, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final navigator = Navigator.of(context);
        final result = await showModalBottomSheet<int>(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(localizations.get('history')),
                onTap: () {
                  navigator.pop(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(localizations.get('add_trip')),
                onTap: () {
                  navigator.pop(1);
                },
              ),
            ],
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
        }
      },
      label: const SizedBox.shrink(),
      icon: const Icon(Icons.flight_takeoff),
    );
  }
}
