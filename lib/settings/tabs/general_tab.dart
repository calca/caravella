import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../widgets/language_selector_setting.dart';
import '../widgets/theme_selector_setting.dart';
import '../../state/locale_notifier.dart';

class GeneralTab extends StatelessWidget {
  final void Function(String)? onLocaleChanged;
  const GeneralTab({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localizations = AppLocalizations(locale);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.get('settings_title'),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        LanguageSelectorSetting(
          locale: localizations.locale,
          onChanged: (selected) {
            LocaleNotifier.of(context)?.changeLocale(selected);
            if (onLocaleChanged != null) {
              onLocaleChanged!(selected);
            }
          },
        ),
        const SizedBox(height: 16),
        const ThemeSelectorSetting(),
      ],
    );
  }
}
