import 'package:flutter/material.dart';
import 'setting_selector.dart';
import '../state/theme_mode_notifier.dart';

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
    return SettingSelector(
      icon: Icons.brightness_6,
      label: 'Tema:',
      selector: DropdownButton<ThemeMode>(
        value: _themeMode,
        underline: const SizedBox(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('Automatico')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Chiaro')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Scuro')),
        ],
        onChanged: _onChanged,
      ),
    );
  }
}
