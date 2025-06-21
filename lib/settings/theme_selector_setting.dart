import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSelectorSetting extends StatefulWidget {
  const ThemeSelectorSetting({super.key});
  @override
  State<ThemeSelectorSetting> createState() => _ThemeSelectorSettingState();
}

class _ThemeSelectorSettingState extends State<ThemeSelectorSetting> {
  ThemeMode? _themeMode;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    await prefs.setString('theme_mode', value);
  }

  void _onChanged(ThemeMode? mode) {
    if (mode == null) return;
    setState(() {
      _themeMode = mode;
    });
    _saveTheme(mode);
    // Notifica l'app del cambio tema
    ThemeModeNotifier.of(context)?.changeTheme(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.brightness_6, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('Tema:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        DropdownButton<ThemeMode>(
          value: _themeMode,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text('Automatico')),
            DropdownMenuItem(value: ThemeMode.light, child: Text('Chiaro')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Scuro')),
          ],
          onChanged: _onChanged,
        ),
      ],
    );
  }
}

class ThemeModeNotifier extends InheritedWidget {
  final ThemeMode themeMode;
  final void Function(ThemeMode) changeTheme;
  const ThemeModeNotifier({
    super.key,
    required this.themeMode,
    required this.changeTheme,
    required super.child,
  });

  static ThemeModeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeNotifier>();
  }

  @override
  bool updateShouldNotify(ThemeModeNotifier oldWidget) => themeMode != oldWidget.themeMode;
}
