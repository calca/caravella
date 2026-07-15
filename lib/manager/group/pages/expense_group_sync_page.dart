import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:provider/provider.dart';

import '../../../settings/widgets/settings_section.dart';
import '../../../settings/widgets/settings_card.dart';
import '../../../sync/widgets/paired_devices_list.dart';

/// Per-group sync settings sub-page, reached from [GroupSettingsPage].
class ExpenseGroupSyncPage extends StatefulWidget {
  final ExpenseGroup trip;

  const ExpenseGroupSyncPage({super.key, required this.trip});

  @override
  State<ExpenseGroupSyncPage> createState() => _ExpenseGroupSyncPageState();
}

class _ExpenseGroupSyncPageState extends State<ExpenseGroupSyncPage> {
  late ExpenseGroup _currentTrip;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

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

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final orchestrator = context.watch<SyncOrchestrator?>();

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.sync_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(_changed),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          SettingsSection(
            title: gloc.sync_title,
            description: gloc.sync_settings_desc,
            children: [
              SettingsCard(
                context: context,
                color: colorScheme.surface,
                semanticsToggled: _currentTrip.syncEnabled,
                child: SwitchListTile(
                  secondary: const Icon(Icons.sync_outlined),
                  title: Text(
                    gloc.sync_group_enable,
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    gloc.sync_group_enable_desc,
                    style: textTheme.bodySmall,
                  ),
                  value: _currentTrip.syncEnabled,
                  onChanged: orchestrator == null
                      ? null
                      : (value) => _handleSyncToggle(value),
                ),
              ),
              if (orchestrator != null && _currentTrip.syncEnabled) ...[
                const SizedBox(height: 8),
                SettingsCard(
                  context: context,
                  color: colorScheme.surface,
                  semanticsLabel: gloc.sync_paired_devices_title,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gloc.sync_paired_devices_title,
                          style: textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        PairedDevicesList(orchestrator: orchestrator),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
