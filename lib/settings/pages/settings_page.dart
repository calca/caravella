import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import '../widgets/general_settings_section.dart';
import '../widgets/privacy_settings_section.dart';
import '../widgets/personalization_settings_section.dart';
import '../widgets/data_settings_section.dart';
import '../widgets/info_settings_section.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    return AppSystemUI.surface(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<FlagSecureNotifier>(
            create: (_) => FlagSecureNotifier(),
          ),
          ChangeNotifierProvider<AppFunctionsEnabledNotifier>(
            create: (_) => AppFunctionsEnabledNotifier(),
          ),
        ],
        child: Scaffold(
          appBar: const CaravellaAppBar(),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              0,
              0,
              0,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            children: [
              GeneralSettingsSection(
                locale: locale,
                onLocaleChanged: onLocaleChanged,
              ),
              const PersonalizationSettingsSection(),
              const PrivacySettingsSection(),
              const DataSettingsSection(),
              const InfoSettingsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
