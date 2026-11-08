import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';

import '../../../sync/bluetooth_sync_factory.dart';
import '../../../sync/invite_sheet.dart';
import '../../../sync/multi_user_sync_page.dart';
import '../../../sync/sync_history_page.dart';
import '../../../sync/widgets/paired_devices_list.dart';

/// Per-group sync settings sub-page, reached from [GroupSettingsPage].
///
/// Sharing this group needs a way to reach the other phone: Wi-Fi or
/// Bluetooth allowed in Settings › Sync › Sync with others (the privacy
/// switches). With both off the switch is locked off, with a button to
/// those settings; once sharing is on, the page has a single
/// "Invite a device" button opening [InviteSheet] (QR code and Bluetooth at
/// once), scoped to this group, above the devices it's shared with.
class ExpenseGroupSyncPage extends StatefulWidget {
  final ExpenseGroup trip;

  const ExpenseGroupSyncPage({super.key, required this.trip});

  @override
  State<ExpenseGroupSyncPage> createState() => _ExpenseGroupSyncPageState();
}

class _ExpenseGroupSyncPageState extends State<ExpenseGroupSyncPage> {
  late ExpenseGroup _currentTrip;
  bool _changed = false;

  bool _lanAvailable = false;
  bool _btAvailable = false;
  bool _checkingChannels = true;
  bool? _hasHistory;
  int _deviceCount = 0;
  SyncOrchestrator? _lastCheckedOrchestrator;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orchestrator = Provider.of<SyncOrchestrator?>(context, listen: false);
    _ensureChannelsChecked(orchestrator);
  }

  Future<void> _ensureChannelsChecked(SyncOrchestrator? orchestrator) async {
    if (orchestrator == null ||
        identical(orchestrator, _lastCheckedOrchestrator)) {
      return;
    }
    _lastCheckedOrchestrator = orchestrator;

    final lan = await orchestrator.isLanSyncEnabled();
    final history = await orchestrator.getHistory(
      limit: 1,
      groupId: _currentTrip.id,
    );
    final bt =
        BluetoothSyncFactory.isEnabled &&
        await BluetoothSyncFactory.isUserEnabled();

    if (mounted) {
      setState(() {
        _lanAvailable = lan;
        _btAvailable = bt;
        _checkingChannels = false;
        _hasHistory = history.isNotEmpty;
      });
    }
  }

  // Sharing can only ever be truly active while Wi-Fi or Bluetooth is
  // allowed in the privacy switches — without one, a group's stored
  // `syncEnabled` flag is just a dormant preference, so the switch must
  // neither display nor be toggleable as if it were live.
  bool _canToggleSync(SyncOrchestrator? orchestrator, bool canToggleOn) =>
      orchestrator != null && canToggleOn;

  Future<void> _handleSyncToggle(bool enabled) async {
    final groupNotifier = Provider.of<ExpenseGroupNotifier>(
      context,
      listen: false,
    );
    await groupNotifier.updateGroupMetadata(
      _currentTrip.copyWith(syncEnabled: enabled),
    );

    if (!mounted) return;

    setState(() {
      _currentTrip = _currentTrip.copyWith(syncEnabled: enabled);
      _changed = true;
    });
  }

  Future<void> _openChannelSettings(SyncOrchestrator orchestrator) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiUserSyncPage(orchestrator: orchestrator),
      ),
    );
    // Back from the switches: read them again.
    _lastCheckedOrchestrator = null;
    await _ensureChannelsChecked(orchestrator);
  }

  void _invite(BuildContext context, SyncOrchestrator orchestrator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => InviteSheet(
        orchestrator: orchestrator,
        groupId: _currentTrip.id,
        groupTitle: _currentTrip.title,
        wifiEnabled: _lanAvailable,
        bluetooth: BluetoothSyncFactory.createChannel(orchestrator),
        bluetoothEnabled: _btAvailable,
        onTurnOnBluetooth: () async {
          await BluetoothSyncFactory.setUserEnabled(true);
          if (mounted) setState(() => _btAvailable = true);
        },
      ),
    );
  }

  void _openHistory(BuildContext context, SyncOrchestrator orchestrator) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SyncHistoryPage(
          orchestrator: orchestrator,
          groupId: _currentTrip.id,
          groupTitle: _currentTrip.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final orchestrator = context.watch<SyncOrchestrator?>();

    final channelsAvailable = _lanAvailable || _btAvailable;
    final canToggleOn =
        orchestrator != null && !_checkingChannels && channelsAvailable;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_changed);
      },
      child: AppSystemUI.edgeToEdge(
        child: SettingsScaffold(
          eyebrow: _currentTrip.title,
          title: gloc.sync_title,
          description: gloc.sync_settings_desc,
          children: [
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.sync_outlined,
                  title: gloc.sync_group_enable,
                  subtitle: canToggleOn
                      ? gloc.sync_group_enable_desc
                      : gloc.sync_group_needs_channel,
                  switchValue: _currentTrip.syncEnabled && canToggleOn,
                  onSwitch: !_canToggleSync(orchestrator, canToggleOn)
                      ? null
                      : (value) => _handleSyncToggle(value),
                ),
                if (orchestrator != null &&
                    !_checkingChannels &&
                    !channelsAvailable)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: OutlinedButton(
                      onPressed: () => _openChannelSettings(orchestrator),
                      child: Text(gloc.sync_group_open_settings),
                    ),
                  ),
              ],
            ),
            if (orchestrator != null &&
                _currentTrip.syncEnabled &&
                canToggleOn) ...[
              SettingsGroup(
                label: gloc.sync_shared_with,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: PairedDevicesList(
                      orchestrator: orchestrator,
                      groupId: _currentTrip.id,
                      groupTitle: _currentTrip.title,
                      onLoaded: (count) {
                        if (mounted && count != _deviceCount) {
                          setState(() => _deviceCount = count);
                        }
                      },
                      emptyBuilder: (context) => _SharedWithNobody(
                        hint: _btAvailable
                            ? gloc.sync_invite_button_desc
                            : gloc.sync_invite_button_desc_wifi,
                        onInvite: () => _invite(context, orchestrator),
                      ),
                      trailing: _InviteAnotherRow(
                        onTap: () => _invite(context, orchestrator),
                      ),
                    ),
                  ),
                ],
              ),
              if (_deviceCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text(
                    gloc.sync_device_tap_hint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
            if (orchestrator != null)
              SettingsGroup(
                children: [
                  SettingsTile(
                    icon: Icons.history,
                    title: gloc.sync_history_title,
                    subtitle: _hasHistory == false
                        ? gloc.sync_history_empty
                        : null,
                    enabled: _hasHistory ?? false,
                    onTap: () => _openHistory(context, orchestrator),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// "Shared with" with no device yet: what sharing is for, and Invite.
class _SharedWithNobody extends StatelessWidget {
  final String hint;
  final VoidCallback onInvite;

  const _SharedWithNobody({required this.hint, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // This phone, a dashed link and an empty place for the other.
          ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.primaryContainer,
                  ),
                  child: Icon(Icons.smartphone, color: s.onPrimaryContainer),
                ),
                const SizedBox(width: AppSpacing.xs),
                ...List.generate(
                  3,
                  (_) => Container(
                    width: 5,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: s.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: s.surfaceContainerHighest,
                    border: Border.all(color: s.outlineVariant, width: 2),
                  ),
                  child: Icon(Icons.add, color: s.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            gloc.sync_shared_empty_title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            gloc.sync_shared_empty_body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: s.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onInvite,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            label: Text(gloc.sync_invite_button),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: s.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The last row of "Shared with": invite one more device.
class _InviteAnotherRow extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteAnotherRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: gloc.sync_invite_another,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.primaryContainer,
                ),
                child: Icon(Icons.add, color: s.onPrimaryContainer),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  gloc.sync_invite_another,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: s.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
