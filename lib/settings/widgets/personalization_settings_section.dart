import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../pages/group_type_templates_page.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// "Personalization" settings section: group type templates entry point.
class PersonalizationSettingsSection extends StatelessWidget {
  const PersonalizationSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SettingsSection(
      title: loc.settings_group_templates_section_title,
      description: loc.settings_group_templates_section_desc,
      children: [_buildGroupTemplatesRow(context, loc)],
    );
  }

  Widget _buildGroupTemplatesRow(
    BuildContext context,
    gen.AppLocalizations loc,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.category_outlined),
        title: Text(
          loc.settings_group_templates_manage_title,
          style: textTheme.titleMedium,
        ),
        subtitle: Text(
          loc.settings_group_templates_manage_desc,
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const GroupTypeTemplatesPage()),
        ),
      ),
    );
  }
}
