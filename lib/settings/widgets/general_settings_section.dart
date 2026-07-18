import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import '../pages/appearance_settings_page.dart';

/// "General" settings section: user name and appearance entry point.
class GeneralSettingsSection extends StatelessWidget {
  final String locale;
  final void Function(String)? onLocaleChanged;

  const GeneralSettingsSection({
    super.key,
    required this.locale,
    this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SettingsSection(
      title: loc.settings_general,
      description: loc.settings_general_desc,
      children: [
        _buildUserNameRow(context, loc),
        const SizedBox(height: 8),
        _buildAppearanceRow(context, loc),
      ],
    );
  }

  Widget _buildUserNameRow(BuildContext context, gen.AppLocalizations loc) {
    return Consumer<UserNameNotifier>(
      builder: (context, userNameNotifier, child) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return SettingsCard(
          context: context,
          semanticsButton: true,
          semanticsLabel: loc.settings_user_name_title,
          semanticsHint: 'Double tap to enter your name',
          color: colorScheme.surface,
          onTap: () => _showNameDialog(context, loc, userNameNotifier),
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              loc.settings_user_name_title,
              style: textTheme.titleMedium,
            ),
            subtitle: Text(
              userNameNotifier.hasName
                  ? userNameNotifier.name
                  : loc.settings_user_name_desc,
              style: textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              AppearanceSettingsPage(onLocaleChanged: onLocaleChanged),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: Text(loc.settings_appearance, style: textTheme.titleMedium),
        subtitle: Text(loc.settings_appearance_desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  void _showNameDialog(
    BuildContext context,
    gen.AppLocalizations loc,
    UserNameNotifier userNameNotifier,
  ) {
    final controller = TextEditingController(text: userNameNotifier.name);

    showDialog(
      context: context,
      builder: (context) {
        return Material3Dialog(
          title: Text(loc.settings_user_name_title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: loc.settings_user_name_hint),
            textCapitalization: TextCapitalization.words,
            maxLength: 50,
          ),
          actions: [
            Material3DialogActions.cancel(context, loc.cancel),
            Material3DialogActions.primary(
              context,
              loc.save,
              onPressed: () {
                userNameNotifier.setName(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
