import 'package:flutter/material.dart';
import '../widgets/caravella_app_bar.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart'
    as gen; // generated strongly-typed
import '../state/locale_notifier.dart';
import '../state/theme_mode_notifier.dart';
import 'flag_secure_notifier.dart';

import 'flag_secure_android.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'terms_page.dart';
import 'data_page.dart';
import '../widgets/bottom_sheet_scaffold.dart';
import '../manager/group/widgets/section_header.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final genLoc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentThemeMode =
        ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
    String currentThemeLabel = switch (currentThemeMode) {
      ThemeMode.light => genLoc.theme_light,
      ThemeMode.dark => genLoc.theme_dark,
      ThemeMode.system => genLoc.theme_automatic,
    };

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
            SectionHeader(
              title: genLoc.settings_general,
              description: genLoc.settings_general_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      button: true,
                      label: '${genLoc.settings_language} - Current: ${_getLanguageLabel(locale, genLoc)}',
                      hint: 'Double tap to change language',
                      child: ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(
                          genLoc.settings_language,
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          _getLanguageLabel(locale, genLoc),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          _showLanguagePicker(context, locale, genLoc);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Semantics(
                      button: true,
                      label:
                          '${genLoc.settings_theme} - Current: $currentThemeLabel',
                      hint: 'Double tap to change theme',
                      child: ListTile(
                        leading: const Icon(Icons.brightness_6),
                        title: Text(
                          genLoc.settings_theme,
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Text(currentThemeLabel),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () {
                          _showThemePicker(context, genLoc);
                        },
                      ),
                    ),
                  ),
                  // ...existing code...
                ],
              ),
            ),
            SectionHeader(
              title: genLoc.settings_privacy,
              description: genLoc.settings_privacy_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (Theme.of(context).platform == TargetPlatform.android)
                    Card(
                      elevation: 0,
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Consumer<FlagSecureNotifier>(
                        builder: (context, notifier, _) => Semantics(
                          toggled: notifier.enabled,
                          label:
                              '${genLoc.settings_flag_secure_title} - ${notifier.enabled ? genLoc.accessibility_currently_enabled : genLoc.accessibility_currently_disabled}',
                          hint: notifier.enabled
                              ? genLoc.accessibility_double_tap_disable
                              : genLoc.accessibility_double_tap_enable,
                          child: ListTile(
                            leading: const Icon(Icons.privacy_tip_outlined),
                            title: Text(
                              genLoc.settings_flag_secure_title,
                              style: textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              genLoc.settings_flag_secure_desc,
                              style: textTheme.bodySmall,
                            ),
                            trailing: Semantics(
                              label: genLoc.accessibility_security_switch(
                                notifier.enabled
                                    ? genLoc.accessibility_switch_on
                                    : genLoc.accessibility_switch_off,
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
                    ),
                ],
              ),
            ),
            SectionHeader(
              title: genLoc.settings_data,
              description: genLoc.settings_data_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.storage_outlined),
                      title: Text(
                        genLoc.settings_data_manage,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(genLoc.settings_data_desc),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => const DataPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(
              title: genLoc.settings_info,
              description: genLoc.settings_info_desc,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        genLoc.settings_app_version,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: FutureBuilder<String>(
                        future: _getAppVersion(),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '-');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        genLoc.settings_info_card,
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        genLoc.settings_info_card_desc,
                        style: textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const TermsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
