import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Where "Update now" is in the paired device sheet: trying Wi-Fi, asking to
/// turn Bluetooth on, or in the Bluetooth step (looking, exchanging, done,
/// failed).
enum DeviceUpdatePhase {
  idle,
  wifi,
  needsBluetooth,
  searching,
  exchanging,
  done,
  failed;

  bool get inBluetoothStep =>
      this == searching || this == exchanging || this == done || this == failed;
}

/// The grey card with a paired device's last update, pairing date and the
/// groups it shares.
class DeviceFactsCard extends StatelessWidget {
  final DateTime? lastSyncAt;
  final DateTime pairedAt;
  final List<String> groupTitles;

  const DeviceFactsCard({
    super.key,
    required this.lastSyncAt,
    required this.pairedAt,
    required this.groupTitles,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final last = lastSyncAt;

    Widget fact(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: s.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return _Panel(
      child: Column(
        children: [
          fact(
            loc.sync_device_last_update,
            last == null
                ? loc.sync_device_never_short
                : DateFormat.MMMd(locale).add_Hm().format(last.toLocal()),
          ),
          fact(
            loc.sync_device_paired_on,
            DateFormat.yMMMd(locale).format(pairedAt.toLocal()),
          ),
          if (groupTitles.isNotEmpty)
            fact(loc.sync_device_groups, groupTitles.join(', ')),
        ],
      ),
    );
  }
}

/// "Bluetooth is off" with a "Turn on" button ([onTurnOn] null: no button).
class BluetoothOffPanel extends StatelessWidget {
  final VoidCallback? onTurnOn;

  /// Turning on is in progress: the button is disabled.
  final bool busy;

  const BluetoothOffPanel({super.key, this.onTurnOn, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return _Panel(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_disabled, color: s.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.sync_bt_off_title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  loc.sync_bt_off_desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: s.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onTurnOn != null) ...[
            const SizedBox(width: AppSpacing.xs),
            OutlinedButton(
              onPressed: busy ? null : onTurnOn,
              child: Text(loc.sync_join_turn_on),
            ),
          ],
        ],
      ),
    );
  }
}

/// The Bluetooth step of "Update now": the two steps (Wi-Fi skipped,
/// Bluetooth in progress), what to do on the other phone, and Cancel /
/// Retry.
class BluetoothUpdateSteps extends StatelessWidget {
  final DeviceUpdatePhase phase;

  /// What was exchanged, once [DeviceUpdatePhase.done].
  final SyncResult? result;

  /// What went wrong, once [DeviceUpdatePhase.failed].
  final String? problem;

  /// Wi-Fi sync was off (rather than the device out of reach).
  final bool wifiWasOff;

  /// What to do on the other phone, shown while looking.
  final String instruction;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const BluetoothUpdateSteps({
    super.key,
    required this.phase,
    required this.result,
    required this.problem,
    required this.wifiWasOff,
    required this.instruction,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final failed = phase == DeviceUpdatePhase.failed;
    final done = phase == DeviceUpdatePhase.done;
    final result = this.result;

    final btDetail = switch (phase) {
      DeviceUpdatePhase.exchanging => loc.sync_update_bt_found,
      DeviceUpdatePhase.done =>
        result == null
            ? loc.sync_bt_completed
            : loc.sync_update_bt_done(result.applied, result.sent),
      DeviceUpdatePhase.failed => problem ?? loc.sync_bt_error_detail,
      _ => loc.sync_update_bt_close,
    };

    Widget step(Widget leading, String title, String detail, {Color? color}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(dimension: 24, child: Center(child: leading)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color ?? s.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: _Panel(
            child: Column(
              children: [
                step(
                  Icon(Icons.wifi_off, size: 20, color: s.onSurfaceVariant),
                  loc.sync_update_step_wifi,
                  wifiWasOff
                      ? loc.sync_update_wifi_skipped_off
                      : loc.sync_update_wifi_skipped_away,
                ),
                step(
                  done
                      ? Icon(Icons.check_circle, size: 22, color: s.primary)
                      : failed
                      ? Icon(Icons.error_outline, size: 22, color: s.error)
                      : const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                  loc.sync_update_step_bluetooth,
                  btDetail,
                  color: failed ? s.error : null,
                ),
              ],
            ),
          ),
        ),
        if (!done && !failed) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: s.onSurfaceVariant,
            ),
          ),
        ],
        if (!done) ...[
          const SizedBox(height: AppSpacing.lg),
          if (failed) ...[
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.sync_bt_retry),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          OutlinedButton(onPressed: onCancel, child: Text(loc.cancel)),
        ],
      ],
    );
  }
}

/// The sheet's rounded grey container.
class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}
