import 'package:flutter/material.dart';
import '../widgets/caravella_app_bar.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../state/theme_mode_notifier.dart';
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

    return Scaffold(
      appBar: const CaravellaAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Generali',
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
                    title: Text('Lingua', style: textTheme.titleMedium),
                    subtitle: Text(locale == 'it' ? 'Italiano' : 'English'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          String selectedLocale = locale;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Seleziona lingua',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 8),
                                    RadioListTile<String>(
                                      value: 'it',
                                      groupValue: selectedLocale,
                                      title: const Text('Italiano'),
                                      onChanged: (value) {
                                        setState(() => selectedLocale = value!);
                                        LocaleNotifier.of(context)
                                            ?.changeLocale(value!);
                                        if (onLocaleChanged != null) {
                                          onLocaleChanged!(value!);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<String>(
                                      value: 'en',
                                      groupValue: selectedLocale,
                                      title: const Text('English'),
                                      onChanged: (value) {
                                        setState(() => selectedLocale = value!);
                                        LocaleNotifier.of(context)
                                            ?.changeLocale(value!);
                                        if (onLocaleChanged != null) {
                                          onLocaleChanged!(value!);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
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
                    title: Text('Tema', style: textTheme.titleMedium),
                    subtitle: Text(loc.get('theme_automatic')),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () {
                      final themeMode =
                          ThemeModeNotifier.of(context)?.themeMode ??
                              ThemeMode.system;
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) {
                          ThemeMode selectedMode = themeMode;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Seleziona tema',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    const SizedBox(height: 8),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.system,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_automatic')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.light,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_light')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    RadioListTile<ThemeMode>(
                                      value: ThemeMode.dark,
                                      groupValue: selectedMode,
                                      title: Text(loc.get('theme_dark')),
                                      onChanged: (value) {
                                        setState(() => selectedMode = value!);
                                        ThemeModeNotifier.of(context)
                                            ?.changeTheme(value!);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Dati',
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
                title: Text('Gestione dati', style: textTheme.titleMedium),
                subtitle: const Text('Backup e importazione'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const DataPage(),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Text(
              'Informazioni',
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
                    title:
                        Text("Versione dell'app", style: textTheme.titleMedium),
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
                    title: Text('Informazioni', style: textTheme.titleMedium),
                    subtitle: Text('Sviluppatore, Source code e Licenza',
                        style: textTheme.bodySmall),
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
