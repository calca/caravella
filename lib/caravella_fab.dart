import 'package:flutter/material.dart';
import 'history_page.dart';
import 'add_trip_page.dart';

class CaravellaFab extends StatelessWidget {
  final void Function()? onRefresh;
  const CaravellaFab({Key? key, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('History'),
                onTap: () {
                  Navigator.of(context).pop(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add trip'),
                onTap: () {
                  Navigator.of(context).pop(1);
                },
              ),
            ],
          ),
        );
        if (result == 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HistoryPage(),
            ),
          );
        } else if (result == 1) {
          final addResult = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTripPage(),
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
