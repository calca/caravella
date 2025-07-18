import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'setting_selector.dart';
import '../../state/theme_mode_notifier.dart';

class ThemeSelectorSetting extends StatefulWidget {
  const ThemeSelectorSetting({super.key});
  @override
  State<ThemeSelectorSetting> createState() => _ThemeSelectorSettingState();
}

class _ThemeSelectorSettingState extends State<ThemeSelectorSetting> {
  ThemeMode? _themeMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeMode = ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
  }

  void _onChanged(ThemeMode? mode) {
    if (mode == null) return;
    setState(() {
      _themeMode = mode;
    });
    ThemeModeNotifier.of(context)?.changeTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    return SettingSelector(
      label: 'Tema:',
      selector: DropdownButton<ThemeMode>(
        value: _themeMode,
        underline: const SizedBox(),
        isExpanded: true,
        items: [
          DropdownMenuItem(
              value: ThemeMode.system, child: Text(loc.get('theme_automatic'))),
          DropdownMenuItem(
              value: ThemeMode.light, child: Text(loc.get('theme_light'))),
          DropdownMenuItem(
              value: ThemeMode.dark, child: Text(loc.get('theme_dark'))),
        ],
        onChanged: _onChanged,
      ),
    );
  }
}
