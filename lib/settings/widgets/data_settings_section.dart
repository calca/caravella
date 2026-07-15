import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:provider/provider.dart';
import '../pages/data_backup_page.dart';
import '../../sync/sync_settings_screen.dart';
import 'settings_card.dart';
import 'settings_section.dart';

/// "Data" settings section: backup/restore and sync entry points.
class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final orchestrator = context.watch<SyncOrchestrator?>();
    return SettingsSection(
      title: loc.settings_data,
      description: loc.settings_data_desc,
      children: [
        _buildDataManageRow(context, loc),
        if (orchestrator != null) ...[
          const SizedBox(height: 8),
          _buildSyncRow(context, loc, orchestrator),
        ],
      ],
    );
  }

  Widget _buildSyncRow(
    BuildContext context,
    gen.AppLocalizations loc,
    SyncOrchestrator orchestrator,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.sync_outlined),
        title: Text(loc.sync_title, style: textTheme.titleMedium),
        subtitle: Text(loc.sync_settings_desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => SyncSettingsScreen(orchestrator: orchestrator),
          ),
        ),
      ),
    );
  }

  Widget _buildDataManageRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.storage_outlined),
        title: Text(loc.settings_data_manage, style: textTheme.titleMedium),
        subtitle: Text(loc.settings_data_desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const DataBackupPage())),
      ),
    );
  }
}
