import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/data_backup_page.dart';
import 'settings_card.dart';
import 'settings_section.dart';

/// "Data" settings section: backup/restore entry point.
class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SettingsSection(
      title: loc.settings_data,
      description: loc.settings_data_desc,
      children: [_buildDataManageRow(context, loc)],
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
