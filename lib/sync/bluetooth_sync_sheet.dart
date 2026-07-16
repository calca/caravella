import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'bluetooth_sync_channel.dart';

/// State machine phases for the Bluetooth sync flow.
enum _BtPhase { searching, peerList, syncing, completed, error }

/// Discovered peer info.
class _BtPeer {
  final String name;
  final String endpointId;

  const _BtPeer({required this.name, required this.endpointId});
}

/// Modal bottom sheet for manual Bluetooth sync.
///
/// Manages its own state machine through five phases:
/// 1. Searching for nearby devices
/// 2. Peer list with sync buttons
/// 3. Syncing in progress
/// 4. Completed with result summary
/// 5. Error with retry
class BluetoothSyncSheet extends StatefulWidget {
  final BluetoothSyncChannel channel;

  const BluetoothSyncSheet({super.key, required this.channel});

  @override
  State<BluetoothSyncSheet> createState() => _BluetoothSyncSheetState();
}

class _BluetoothSyncSheetState extends State<BluetoothSyncSheet> {
  _BtPhase _phase = _BtPhase.searching;
  final List<_BtPeer> _peers = [];
  StreamSubscription<BluetoothPeerEvent>? _eventSub;
  SyncResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _startDiscovery() {
    _peers.clear();
    _phase = _BtPhase.searching;

    _eventSub?.cancel();
    _eventSub = widget.channel.events.listen(_handleEvent);

    widget.channel.startDiscovery().catchError((e) {
      if (mounted) {
        setState(() {
          _phase = _BtPhase.error;
          _errorMessage = e is BluetoothPermissionDeniedException
              ? gen.AppLocalizations.of(context).sync_bt_permission_denied
              : e.toString();
        });
      }
    });

    // Transition to peer list after a short delay even if no peers found,
    // so the user sees the empty list rather than an infinite spinner.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _phase == _BtPhase.searching) {
        setState(() => _phase = _BtPhase.peerList);
      }
    });
  }

  void _handleEvent(BluetoothPeerEvent event) {
    if (!mounted) return;

    switch (event) {
      case PeerFound(:final name, :final endpointId):
        setState(() {
          _peers.removeWhere((p) => p.endpointId == endpointId);
          _peers.add(_BtPeer(name: name, endpointId: endpointId));
          if (_phase == _BtPhase.searching) _phase = _BtPhase.peerList;
        });
      case PeerLost(:final endpointId):
        setState(() {
          _peers.removeWhere((p) => p.endpointId == endpointId);
        });
      case BtSyncStarted():
        setState(() => _phase = _BtPhase.syncing);
      case BtSyncCompleted(:final result):
        setState(() {
          _phase = _BtPhase.completed;
          _result = result;
        });
      case BtSyncError(:final error):
        setState(() {
          _phase = _BtPhase.error;
          _errorMessage = error;
        });
    }
  }

  Future<void> _syncWithPeer(String endpointId) async {
    setState(() => _phase = _BtPhase.syncing);
    try {
      final result = await widget.channel.syncWithPeer(endpointId);
      if (mounted) {
        setState(() {
          _phase = _BtPhase.completed;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _BtPhase.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _result = null;
    });
    _startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return GroupBottomSheetScaffold(
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
      _BtPhase.searching => _buildSearching(context, loc),
      _BtPhase.peerList => _buildPeerList(context, loc),
      _BtPhase.syncing => _buildSyncing(context, loc),
      _BtPhase.completed => _buildCompleted(context, loc),
      _BtPhase.error => _buildError(context, loc),
    };
  }

  Widget _buildSearching(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('searching'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            loc.sync_bt_searching,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerList(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_peers.isEmpty) {
      return Padding(
        key: const ValueKey('empty-peers'),
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            loc.sync_bt_searching,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ),
      );
    }

    return Column(
      key: const ValueKey('peer-list'),
      mainAxisSize: MainAxisSize.min,
      children: _peers.map((peer) {
        return Semantics(
          button: true,
          label: '${loc.sync_bt_sync_with} ${peer.name}',
          child: ListTile(
            visualDensity: VisualDensity.compact,
            leading: Icon(Icons.bluetooth, color: colorScheme.primary),
            title: Text(peer.name, style: textTheme.bodyMedium),
            trailing: FilledButton.tonal(
              onPressed: () => _syncWithPeer(peer.endpointId),
              child: Text(loc.sync_bt_sync_with),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSyncing(BuildContext context, gen.AppLocalizations loc) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('syncing'),
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            loc.sync_status_syncing,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.outline),
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
