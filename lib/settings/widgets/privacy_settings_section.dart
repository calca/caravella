import 'package:material_ui/material_ui.dart';
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
    if (!isAndroid) return const SizedBox.shrink();
    return SettingsGroup(
      label: loc.settings_privacy,
      children: [
        Consumer<FlagSecureNotifier>(
          builder: (context, notifier, _) => SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: loc.settings_flag_secure_title,
            subtitle: loc.settings_flag_secure_desc,
            switchValue: notifier.enabled,
            onSwitch: (val) async {
              final applied = await FlagSecureAndroid.setFlagSecure(val);
              if (!applied) {
                if (context.mounted) {
                  AppToast.show(
                    context,
                    loc.settings_flag_secure_error,
                    type: ToastType.error,
                  );
                }
                return;
              }
              await notifier.setEnabled(val);
            },
          ),
        ),
        Consumer<AppFunctionsEnabledNotifier>(
          builder: (context, notifier, _) => SettingsTile(
            icon: Icons.smart_toy_outlined,
            title: loc.settings_app_functions_title,
            subtitle: loc.settings_app_functions_desc,
            switchValue: notifier.enabled,
            onSwitch: notifier.setEnabled,
          ),
        ),
      ],
    );
  }
}
