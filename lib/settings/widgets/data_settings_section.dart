import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import '../pages/data_backup_page.dart';
import '../pages/group_type_templates_page.dart';
import '../../sync/sync_settings_screen.dart';

/// "Data" settings section: sync, backup/restore and group type templates.
class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final orchestrator = context.watch<SyncOrchestrator?>();
    return SettingsGroup(
      label: loc.settings_data,
      children: [
        if (orchestrator != null)
          SettingsTile(
            icon: Icons.sync_rounded,
            title: loc.sync_title,
            subtitle: loc.sync_settings_desc,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) =>
                    SyncSettingsScreen(orchestrator: orchestrator),
              ),
            ),
          ),
        SettingsTile(
          icon: Icons.storage_outlined,
          title: loc.settings_data_manage,
          subtitle: loc.data_title,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => const DataBackupPage())),
        ),
        SettingsTile(
          icon: Icons.category_outlined,
          title: loc.settings_group_templates_manage_title,
          subtitle: loc.settings_group_templates_manage_desc,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GroupTypeTemplatesPage()),
          ),
        ),
      ],
    );
  }
}
