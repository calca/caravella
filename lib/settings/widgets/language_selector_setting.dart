import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'setting_selector.dart';

class LanguageSelectorSetting extends StatefulWidget {
  final String locale;
  final ValueChanged<String> onChanged;
  const LanguageSelectorSetting(
      {super.key, required this.locale, required this.onChanged});

  @override
  State<LanguageSelectorSetting> createState() =>
      _LanguageSelectorSettingState();
}

class _LanguageSelectorSettingState extends State<LanguageSelectorSetting> {
  late String _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void _onChanged(String? locale) async {
    if (locale == null || locale == _locale) return;
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
    widget.onChanged(locale);
  }

  @override
  Widget build(BuildContext context) {
    return SettingSelector(
      icon: Icons.language,
      label: 'Lingua:',
      selector: DropdownButton<String>(
        value: _locale,
        underline: const SizedBox(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'it', child: Text('Italiano')),
          DropdownMenuItem(value: 'en', child: Text('English')),
        ],
        onChanged: _onChanged,
      ),
    );
  }
}
