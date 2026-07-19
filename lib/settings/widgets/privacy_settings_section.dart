import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import '../../settings/flag_secure_android.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// "Privacy" settings section: FLAG_SECURE toggle and Android App Functions
/// toggle. Both rows are Android-only.
class PrivacySettingsSection extends StatelessWidget {
  const PrivacySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    return SettingsSection(
      title: loc.settings_privacy,
      description: loc.settings_privacy_desc,
      children: [
        if (isAndroid) _buildFlagSecureRow(context, loc),
        if (isAndroid) const SizedBox(height: 8),
        if (isAndroid) _buildAppFunctionsRow(context, loc),
      ],
    );
  }

  Widget _buildFlagSecureRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<FlagSecureNotifier>(
      builder: (context, notifier, _) {
        Future<void> toggle(bool val) async {
          notifier.setEnabled(val);
          await FlagSecureAndroid.setFlagSecure(val);
        }

        return SettingsCard(
          context: context,
          color: colorScheme.surface,
          semanticsToggled: notifier.enabled,
          semanticsLabel: loc.settings_flag_secure_title,
          semanticsHint: notifier.enabled
              ? loc.accessibility_double_tap_disable
              : loc.accessibility_double_tap_enable,
          onTap: () => toggle(!notifier.enabled),
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(
              loc.settings_flag_secure_title,
              style: textTheme.titleMedium,
            ),
            subtitle: Text(
              loc.settings_flag_secure_desc,
              style: textTheme.bodySmall,
            ),
            trailing: Switch(
              value: notifier.enabled,
              onChanged: toggle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppFunctionsRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<AppFunctionsEnabledNotifier>(
      builder: (context, notifier, _) {
        Future<void> toggle(bool val) => notifier.setEnabled(val);

        return SettingsCard(
          context: context,
          color: colorScheme.surface,
          semanticsToggled: notifier.enabled,
          semanticsLabel: loc.settings_app_functions_title,
          semanticsHint: notifier.enabled
              ? loc.accessibility_double_tap_disable
              : loc.accessibility_double_tap_enable,
          onTap: () => toggle(!notifier.enabled),
          child: ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: Text(
              loc.settings_app_functions_title,
              style: textTheme.titleMedium,
            ),
            subtitle: Text(
              loc.settings_app_functions_desc,
              style: textTheme.bodySmall,
            ),
            trailing: Switch(
              value: notifier.enabled,
              onChanged: toggle,
            ),
          ),
        );
      },
    );
  }
}
