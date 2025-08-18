import 'package:flutter/material.dart';
import '../widgets/caravella_app_bar.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../state/theme_mode_notifier.dart';
import 'flag_secure_notifier.dart';
import 'flag_secure_android.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'terms_page.dart';
import 'data_page.dart';

class SettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const SettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentThemeMode = ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
    String currentThemeLabel;
    switch (currentThemeMode) {
      case ThemeMode.light:
        currentThemeLabel = loc.get('theme_light');
        break;
      case ThemeMode.dark:
        currentThemeLabel = loc.get('theme_dark');
        break;
      case ThemeMode.system:
        currentThemeLabel = loc.get('theme_automatic');
        break;
    }

    return ChangeNotifierProvider<FlagSecureNotifier>(
      create: (_) => FlagSecureNotifier(),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                loc.get('settings_general'),
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                      leading: const Icon(Icons.language),
                      title: Text(
                        loc.get('settings_language'),
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        locale == 'it'
                            ? loc.get('settings_language_it')
                            : loc.get('settings_language_en'),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        _showLanguagePicker(context, locale, loc);
                      },
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
                      leading: const Icon(Icons.brightness_6),
                      title: Text(
                        loc.get('settings_theme'),
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(currentThemeLabel),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () {
                        _showThemePicker(context, loc);
                      },
                    ),
                  ),
                  // ...existing code...
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Privacy',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                        builder: (context, notifier, _) => ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text(
                            loc.get('settings_flag_secure_title'),
                            style: textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            loc.get('settings_flag_secure_desc'),
                            style: textTheme.bodySmall,
                          ),
                          trailing: Switch(
                            value: notifier.enabled,
                            onChanged: (val) async {
                              notifier.setEnabled(val);
                              await FlagSecureAndroid.setFlagSecure(val);
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                loc.get('settings_data'),
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: Text(
                    loc.get('settings_data_manage'),
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(loc.get('settings_data_desc')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const DataPage()),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                loc.get('settings_info'),
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                        loc.get('settings_app_version'),
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
                        loc.get('settings_info_card'),
                        style: textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        loc.get('settings_info_card_desc'),
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
}

void _showLanguagePicker(BuildContext context, String currentLocale, AppLocalizations loc) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      final entries = [
        ('it', loc.get('settings_language_it')),
        ('en', loc.get('settings_language_en')),
      ];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.get('settings_select_language'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...entries.map((e) {
                final selected = e.$1 == currentLocale;
                return ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text(e.$2),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? Icon(Icons.check, key: ValueKey(e.$1), color: Theme.of(context).colorScheme.primary)
                        : const SizedBox.shrink(),
                  ),
                  onTap: selected
                      ? null
                      : () {
                          LocaleNotifier.of(context)?.changeLocale(e.$1);
                          final stateWidget = context.findAncestorWidgetOfExactType<SettingsPage>();
                          if (stateWidget != null && stateWidget.onLocaleChanged != null) {
                            stateWidget.onLocaleChanged!(e.$1);
                          }
                          Navigator.of(context).pop();
                        },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

void _showThemePicker(BuildContext context, AppLocalizations loc) {
  final currentMode = ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
  final entries = <(ThemeMode, String, IconData)>[
    (ThemeMode.system, loc.get('theme_automatic'), Icons.settings_suggest_outlined),
    (ThemeMode.light, loc.get('theme_light'), Icons.light_mode_outlined),
    (ThemeMode.dark, loc.get('theme_dark'), Icons.dark_mode_outlined),
  ];
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        loc.get('settings_select_theme'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: MaterialLocalizations.of(context).closeButtonLabel,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...entries.map((e) {
                final selected = e.$1 == currentMode;
                return ListTile(
                  leading: Icon(e.$3, color: selected ? Theme.of(context).colorScheme.primary : null),
                  title: Text(e.$2),
                  trailing: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: selected
                        ? Icon(Icons.check, key: ValueKey(e.$1), color: Theme.of(context).colorScheme.primary)
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
