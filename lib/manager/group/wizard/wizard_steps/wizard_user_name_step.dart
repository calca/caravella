import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../../pages/group_creation_wizard_page.dart';

/// First start only: the user's name, saved as they type, with their
/// initials in an avatar that follows along.
class WizardUserNameStep extends StatefulWidget {
  final VoidCallback onSubmitted;

  const WizardUserNameStep({super.key, required this.onSubmitted});

  @override
  State<WizardUserNameStep> createState() => _WizardUserNameStepState();
}

class _WizardUserNameStepState extends State<WizardUserNameStep> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserNameNotifier>();
    if (user.hasName) _controller.text = user.name;
    _controller.addListener(_save);
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) context.read<UserNameNotifier>().setName(name);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final initials = nameInitials(_controller.text);

    return WizardStepLayout(
      eyebrow: gloc.wizard_user_name_welcome,
      title: gloc.wizard_name_title,
      children: [
        WizardCard(
          child: Row(
            children: [
              ExcludeSemantics(
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: s.surfaceContainerHighest,
                  foregroundColor: s.onSurface,
                  child: initials.isEmpty
                      ? const Icon(Icons.person_outline)
                      : Text(
                          initials,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => widget.onSubmitted(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: gloc.wizard_user_name_hint,
                    labelText: gloc.wizard_user_name_label,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        WizardNote(gloc.wizard_name_note, icon: Icons.lock_outline_rounded),
      ],
    );
  }
}
