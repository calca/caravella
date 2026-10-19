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
  ) => showDialog<void>(
    context: context,
    builder: (_) => _NameDialog(loc: loc, user: userNameNotifier),
  );
}

/// The name dialog owns its text controller, so it is disposed only when
/// the dialog is gone — disposing it right after `showDialog` returned
/// crashed while the closing animation still built the field.
class _NameDialog extends StatefulWidget {
  final gen.AppLocalizations loc;
  final UserNameNotifier user;

  const _NameDialog({required this.loc, required this.user});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.user.name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.user.setName(_controller.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    return Material3Dialog(
      title: Text(loc.settings_user_name_title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(hintText: loc.settings_user_name_hint),
        textCapitalization: TextCapitalization.words,
        maxLength: 50,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        Material3DialogActions.cancel(context, loc.cancel),
        Material3DialogActions.primary(context, loc.save, onPressed: _save),
      ],
    );
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
