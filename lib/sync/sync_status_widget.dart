import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'sync_history_sheet.dart';

/// Small AppBar badge showing the current sync status.
///
/// Uses [StreamBuilder] to listen to [SyncOrchestrator.events] and displays
/// an [IconButton] whose color reflects the latest sync state.
class SyncStatusWidget extends StatefulWidget {
  final SyncOrchestrator orchestrator;

  const SyncStatusWidget({super.key, required this.orchestrator});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return StreamBuilder<SyncEvent>(
      stream: widget.orchestrator.events,
      builder: (context, snapshot) {
        _updateStatus(snapshot.data);

        final (icon, color, label) = _resolveAppearance(context, loc);

        return Semantics(
          button: true,
          label: label,
          child: IconButton(
            icon: _status == SyncStatus.syncing
                ? _buildAnimatedIcon(icon, color)
                : Icon(icon, color: color, size: 20),
            tooltip: label,
            onPressed: () => _openHistory(context),
          ),
        );
      },
    );
  }

  void _updateStatus(SyncEvent? event) {
    if (event == null) return;

    switch (event) {
      case SyncStarted():
        _status = SyncStatus.syncing;
        _pulseController.repeat(reverse: true);
      case SyncCompleted():
        _status = SyncStatus.success;
        _lastSyncTime = event.result.syncedAt;
        _pulseController.stop();
        _pulseController.value = 1.0;
      case SyncFailed():
        _status = SyncStatus.error;
        _pulseController.stop();
        _pulseController.value = 1.0;
    }
  }

  (IconData, Color, String) _resolveAppearance(
    BuildContext context,
    gen.AppLocalizations loc,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_status == SyncStatus.syncing) {
      return (Icons.sync, colorScheme.tertiary, loc.sync_status_syncing);
    }
    if (_status == SyncStatus.error) {
      return (Icons.sync_problem, colorScheme.error, loc.sync_status_error);
    }

    // Check if last sync is recent (< 5 minutes).
    if (_lastSyncTime != null) {
      final elapsed = DateTime.now().toUtc().difference(_lastSyncTime!);
      if (elapsed.inMinutes < 5) {
        return (Icons.cloud_done, colorScheme.primary, loc.sync_status_synced);
      }
    }

    if (_lastSyncTime != null) {
      return (Icons.cloud_done, colorScheme.outline, loc.sync_status_synced);
    }

    return (
      Icons.sync_disabled,
      colorScheme.outline,
      loc.sync_status_never,
    );
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Opacity(
          opacity: 0.4 + 0.6 * _pulseController.value,
          child: Icon(icon, color: color, size: 20),
        );
      },
    );
  }

  void _openHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SyncHistorySheet(orchestrator: widget.orchestrator),
    );
  }
}
