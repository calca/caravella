import 'package:flutter/material.dart';
import '../../widgets/caravella_app_bar.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart'
    as gen; // generated strongly-typed
import '../../state/locale_notifier.dart';
import '../../state/theme_mode_notifier.dart';
import '../flag_secure_notifier.dart';

import '../flag_secure_android.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'developer_page.dart';
import 'data_backup_page.dart';
import '../../widgets/bottom_sheet_scaffold.dart';
import '../../settings/widgets/settings_card.dart';
import '../../settings/widgets/settings_section.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FlagSecureNotifier>(
          create: (_) => FlagSecureNotifier(),
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
            _buildGeneralSection(context, loc, locale),
            _buildPrivacySection(context, loc),
            _buildDataSection(context, loc),
            _buildInfoSection(context, loc),
          ],
        ),
      ),
    );
  }

  // SECTION BUILDERS -------------------------------------------------------
  Widget _buildGeneralSection(
    BuildContext context,
    gen.AppLocalizations loc,
    String locale,
  ) {
    return SettingsSection(
      title: loc.settings_general,
      description: loc.settings_general_desc,
      children: [
        _buildLanguageRow(context, loc, locale),
        const SizedBox(height: 8),
        _buildThemeRow(context, loc),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, gen.AppLocalizations loc) {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    return SettingsSection(
      title: loc.settings_privacy,
      description: loc.settings_privacy_desc,
      children: [
        if (isAndroid) _buildFlagSecureRow(context, loc),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context, gen.AppLocalizations loc) {
    return SettingsSection(
      title: loc.settings_data,
      description: loc.settings_data_desc,
      children: [
        _buildDataManageRow(context, loc),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, gen.AppLocalizations loc) {
    return SettingsSection(
      title: loc.settings_info,
      description: loc.settings_info_desc,
      children: [
        _buildInfoCardRow(context, loc),
        const SizedBox(height: 8),
        _buildAppVersionRow(context, loc),
      ],
    );
  }

  // ROW BUILDERS -----------------------------------------------------------
  Widget _buildLanguageRow(
    BuildContext context,
    gen.AppLocalizations loc,
    String locale,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final label = _getLanguageLabel(locale, loc);
    return SettingsCard(
      context: context,
      semanticsButton: true,
      semanticsLabel: '${loc.settings_language} - Current: $label',
      semanticsHint: 'Double tap to change language',
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(loc.settings_language, style: textTheme.titleMedium),
        subtitle: Text(label),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () => _showLanguagePicker(context, locale, loc),
      ),
    );
  }

  Widget _buildThemeRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentMode =
        ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
    final label = switch (currentMode) {
      ThemeMode.light => loc.theme_light,
      ThemeMode.dark => loc.theme_dark,
      ThemeMode.system => loc.theme_automatic,
    };
    return SettingsCard(
      context: context,
      semanticsButton: true,
      semanticsLabel: '${loc.settings_theme} - Current: $label',
      semanticsHint: 'Double tap to change theme',
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.brightness_6),
        title: Text(loc.settings_theme, style: textTheme.titleMedium),
        subtitle: Text(label),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () => _showThemePicker(context, loc),
      ),
    );
  }

  Widget _buildFlagSecureRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: Consumer<FlagSecureNotifier>(
        builder: (context, notifier, _) => Semantics(
          toggled: notifier.enabled,
          label:
              '${loc.settings_flag_secure_title} - ${notifier.enabled ? loc.accessibility_currently_enabled : loc.accessibility_currently_disabled}',
          hint: notifier.enabled
              ? loc.accessibility_double_tap_disable
              : loc.accessibility_double_tap_enable,
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
            trailing: Semantics(
              label: loc.accessibility_security_switch(
                notifier.enabled
                    ? loc.accessibility_switch_on
                    : loc.accessibility_switch_off,
              ),
              child: Switch(
                value: notifier.enabled,
                onChanged: (val) async {
                  notifier.setEnabled(val);
                  await FlagSecureAndroid.setFlagSecure(val);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataManageRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.storage_outlined),
        title: Text(loc.settings_data_manage, style: textTheme.titleMedium),
        subtitle: Text(loc.settings_data_desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const DataBackupPage())),
      ),
    );
  }

  Widget _buildAppVersionRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(loc.settings_app_version, style: textTheme.titleMedium),
        subtitle: FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) => Text(snapshot.data ?? '-'),
        ),
      ),
    );
  }

  Widget _buildInfoCardRow(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(loc.settings_info_card, style: textTheme.titleMedium),
        subtitle: Text(loc.settings_info_card_desc, style: textTheme.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (ctx) => const DeveloperPage())),
      ),
    );
  }

  // GENERIC CARD WRAPPER ---------------------------------------------------
  // ...existing code...

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '-';
    }
  }

  String _getLanguageLabel(String locale, gen.AppLocalizations genLoc) {
    switch (locale) {
      case 'it':
        return genLoc.settings_language_it;
      case 'es':
        return genLoc.settings_language_es;
      case 'en':
      default:
        return genLoc.settings_language_en;
    }
  }
}

void _showLanguagePicker(
  BuildContext context,
  String currentLocale,
  gen.AppLocalizations loc,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final entries = [
        ('it', loc.settings_language_it),
        ('en', loc.settings_language_en),
        ('es', loc.settings_language_es),
      ];
      return GroupBottomSheetScaffold(
        title: loc.settings_select_language,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...entries.map((e) {
              final selected = e.$1 == currentLocale;
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(e.$2),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? Icon(
                          Icons.check,
                          key: ValueKey(e.$1),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const SizedBox.shrink(),
                ),
                onTap: selected
                    ? null
                    : () {
                        LocaleNotifier.of(context)?.changeLocale(e.$1);
                        final stateWidget = context
                            .findAncestorWidgetOfExactType<SettingsPage>();
                        if (stateWidget != null &&
                            stateWidget.onLocaleChanged != null) {
                          stateWidget.onLocaleChanged!(e.$1);
                        }
                        Navigator.of(context).pop();
                      },
              );
            }),
          ],
        ),
      );
    },
  );
}

void _showThemePicker(BuildContext context, gen.AppLocalizations loc) {
  final currentMode =
      ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
  final entries = <(ThemeMode, String, IconData)>[
    (ThemeMode.system, loc.theme_automatic, Icons.settings_suggest_outlined),
    (ThemeMode.light, loc.theme_light, Icons.light_mode_outlined),
    (ThemeMode.dark, loc.theme_dark, Icons.dark_mode_outlined),
  ];
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return GroupBottomSheetScaffold(
        title: loc.settings_select_theme,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...entries.map((e) {
              final selected = e.$1 == currentMode;
              return ListTile(
                leading: Icon(
                  e.$3,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(e.$2),
                trailing: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? Icon(
                          Icons.check,
                          key: ValueKey(e.$1),
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const SizedBox.shrink(),
                ),
                onTap: selected
                    ? null
                    : () {
                        ThemeModeNotifier.of(context)?.changeTheme(e.$1);
                        Navigator.of(context).pop();
                      },
              );
            }),
          ],
        ),
      );
    },
  );
}
