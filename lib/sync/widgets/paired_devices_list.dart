import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Displays the devices granted access to a specific group's sync.
///
/// Self-loads via [orchestrator] on mount. Pass a new [key] (e.g. an
/// incrementing counter) to force a reload after a pairing completes
/// elsewhere (the QR scan / Bluetooth flow).
class PairedDevicesList extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  /// The group whose granted devices this list shows — pairing is scoped
  /// per group, so there is no "all paired devices" view anymore.
  final String groupId;

  /// Whether to show a trailing "remove" action per device. Removing here
  /// revokes only this group's grant, not the device's overall pairing.
  final bool showRemoveAction;

  const PairedDevicesList({
    super.key,
    required this.orchestrator,
    required this.groupId,
    this.showRemoveAction = false,
  });

  @override
  State<PairedDevicesList> createState() => _PairedDevicesListState();
}

class _PairedDevicesListState extends State<PairedDevicesList> {
  late Future<List<PairedDevice>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.orchestrator.getPairedDevicesForGroup(widget.groupId);
  }

  IconData _iconFor(String platform) {
    switch (platform) {
      case 'ios':
      case 'android':
        return Icons.smartphone;
      case 'macos':
      case 'windows':
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.devices_other;
    }
  }

  Future<void> _remove(PairedDevice device) async {
    await widget.orchestrator.revokeGroupAccess(device.deviceId, widget.groupId);
    if (mounted) {
      setState(() {
        _future = widget.orchestrator.getPairedDevicesForGroup(widget.groupId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<PairedDevice>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final devices = snapshot.data!;
        if (devices.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              loc.sync_paired_devices_empty,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          );
        }

        return Column(
          children: devices.map((device) {
            return Semantics(
              label: '${device.deviceName}, ${loc.sync_group_shared}',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                leading: Icon(
                  _iconFor(device.platform),
                  color: colorScheme.primary,
                ),
                title: Text(device.deviceName, style: textTheme.bodyMedium),
                trailing: widget.showRemoveAction
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: loc.sync_paired_devices_remove,
                        onPressed: () => _remove(device),
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
