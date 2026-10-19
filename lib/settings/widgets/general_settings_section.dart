import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import '../pages/appearance_settings_page.dart';

/// "General" settings section: the appearance entry point (the user name
/// is the [UserProfileCard] at the top of the page).
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
    return SettingsGroup(
      label: loc.settings_general,
      children: [
        SettingsTile(
          icon: Icons.palette_outlined,
          title: loc.settings_appearance,
          subtitle: loc.settings_appearance_desc,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  AppearanceSettingsPage(onLocaleChanged: onLocaleChanged),
            ),
          ),
        ),
      ],
    );
  }

  /// Asks for the user's name (shared with [UserProfileCard]).
  static Future<void> showNameDialog(
    BuildContext context,
    gen.AppLocalizations loc,
    UserNameNotifier userNameNotifier,
  ) async {
    final controller = TextEditingController(text: userNameNotifier.name);

    await showDialog(
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
    controller.dispose();
  }
}

/// Top card of the app settings: the user's name (or a prompt to set it),
/// tap to change it.
class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    return Consumer<UserNameNotifier>(
      builder: (context, user, _) {
        final name = user.hasName ? user.name : loc.settings_user_name_title;
        return SettingsProfileCard(
          leading: CircleAvatar(
            backgroundColor: s.onSurface.withValues(alpha: 0.06),
            foregroundColor: s.onSurface,
            child: user.hasName
                ? Text(
                    name.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : const Icon(Icons.person_outline),
          ),
          title: name,
          subtitle: loc.settings_user_name_desc,
          actionLabel: loc.edit,
          onTap: () =>
              GeneralSettingsSection.showNameDialog(context, loc, user),
        );
      },
    );
  }
}
