import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_channel.dart';

/// State machine phases for the Bluetooth advertise (share) flow.
enum _AdvertisePhase { waiting, completed, error }

/// Modal bottom sheet for sharing a group via Bluetooth: advertises this
/// device and waits for a nearby device to discover and connect to it,
/// rather than the other way around (that's [BluetoothSyncSheet], reached
/// from the app-level sync settings, group-agnostic since the discovering
/// side doesn't know what it's about to receive).
class BluetoothAdvertiseSheet extends StatefulWidget {
  final BluetoothSyncChannel channel;
  final String groupId;
  final String groupTitle;

  const BluetoothAdvertiseSheet({
    super.key,
    required this.channel,
    required this.groupId,
    required this.groupTitle,
  });

  @override
  State<BluetoothAdvertiseSheet> createState() =>
      _BluetoothAdvertiseSheetState();
}

class _BluetoothAdvertiseSheetState extends State<BluetoothAdvertiseSheet> {
  _AdvertisePhase _phase = _AdvertisePhase.waiting;
  StreamSubscription<BluetoothPeerEvent>? _eventSub;
  SyncResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startAdvertising();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    widget.channel.stopAll();
    super.dispose();
  }

  void _startAdvertising() {
    _eventSub?.cancel();
    _eventSub = widget.channel.events.listen(_handleEvent);

    widget.channel
        .startAdvertising(groupId: widget.groupId, groupTitle: widget.groupTitle)
        .catchError((e) {
      if (mounted) {
        setState(() {
          _phase = _AdvertisePhase.error;
          _errorMessage = e is BluetoothPermissionDeniedException
              ? gen.AppLocalizations.of(context).sync_bt_permission_denied
              : e.toString();
        });
      }
    });
  }

  void _handleEvent(BluetoothPeerEvent event) {
    if (!mounted) return;

    switch (event) {
      case BtSyncCompleted(:final result):
        setState(() {
          _phase = _AdvertisePhase.completed;
          _result = result;
        });
      case BtSyncError(:final error):
        setState(() {
          _phase = _AdvertisePhase.error;
          _errorMessage = error;
        });
      default:
        break;
    }
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _result = null;
      _phase = _AdvertisePhase.waiting;
    });
    _startAdvertising();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return CaravellaBottomSheetScaffold(
      title: loc.sync_bt_title,
      scrollable: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildPhase(context, loc),
      ),
    );
  }

  Widget _buildPhase(BuildContext context, gen.AppLocalizations loc) {
    return switch (_phase) {
      _AdvertisePhase.waiting => _buildWaiting(context, loc),
      _AdvertisePhase.completed => _buildCompleted(context, loc),
      _AdvertisePhase.error => _buildError(context, loc),
    };
  }

  Widget _buildWaiting(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      key: const ValueKey('waiting'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            loc.sync_bt_advertise_waiting,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
          const SizedBox(height: 4),
          Text(
            loc.sync_qr_sharing_group(widget.groupTitle),
            style: textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final received = _result?.applied ?? 0;
    final sent = _result?.skipped ?? 0;

    return Padding(
      key: const ValueKey('completed'),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: colorScheme.primary, size: 48),
          const SizedBox(height: 12),
          Text(loc.sync_bt_completed, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            loc.sync_bt_received_sent(received, sent),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      key: const ValueKey('error'),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 48),
          const SizedBox(height: 12),
          Text(loc.sync_bt_error, style: textTheme.titleMedium),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _retry,
            child: Text(loc.sync_bt_retry),
          ),
        ],
      ),
    );
  }
}
