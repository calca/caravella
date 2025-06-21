import 'package:flutter/material.dart';

// --- Language selector components extracted from settings_page.dart ---
class LanguageSettingTile extends StatelessWidget {
  final String locale;
  final ValueChanged<String> onChanged;
  const LanguageSettingTile({required this.locale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text('Lingua'),
      subtitle: Text(locale == 'it' ? 'Italiano' : 'English'),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => LanguageSelectorSheet(selected: locale),
        );
        if (selected != null && selected != locale) {
          onChanged(selected);
        }
      },
      trailing: const Icon(Icons.arrow_drop_down),
    );
  }
}

class LanguageSelectorSheet extends StatelessWidget {
  final String selected;
  const LanguageSelectorSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Italiano'),
            selected: selected == 'it',
            onTap: () => Navigator.of(context).pop('it'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            selected: selected == 'en',
            onTap: () => Navigator.of(context).pop('en'),
          ),
        ],
      ),
    );
  }
}