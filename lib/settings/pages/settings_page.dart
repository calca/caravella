import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:provider/provider.dart';
import '../widgets/general_settings_section.dart';
import '../widgets/privacy_settings_section.dart';
import '../widgets/data_settings_section.dart';
import '../widgets/info_settings_section.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    return AppSystemUI.edgeToEdge(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<FlagSecureNotifier>(
            create: (_) => FlagSecureNotifier(),
          ),
          ChangeNotifierProvider<AppFunctionsEnabledNotifier>(
            create: (_) => AppFunctionsEnabledNotifier(),
          ),
        ],
        child: SettingsScaffold(
          eyebrow: 'Caravella',
          title: gen.AppLocalizations.of(context).settings,
          children: [
            const UserProfileCard(),
            GeneralSettingsSection(
              locale: locale,
              onLocaleChanged: onLocaleChanged,
            ),
            const DataSettingsSection(),
            const PrivacySettingsSection(),
            const InfoSettingsSection(),
          ],
        ),
      ),
    );
  }
}
