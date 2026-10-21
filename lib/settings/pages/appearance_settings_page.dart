import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// "Appearance" settings subpage: language, dynamic color, theme.
class AppearanceSettingsPage extends StatelessWidget {
  final void Function(String)? onLocaleChanged;

  const AppearanceSettingsPage({super.key, this.onLocaleChanged});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.settings,
        title: loc.settings_appearance,
        children: [
          SettingsGroup(
            label: loc.settings_theme,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _buildThemeSelector(context, loc),
              ),
            ],
          ),
          SettingsGroup(
            children: [
              _buildDynamicColorRow(context, loc),
              _buildLanguageRow(context, locale, loc),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(
    BuildContext context,
    String locale,
    gen.AppLocalizations loc,
  ) {
    return SettingsTile(
      icon: Icons.language,
      title: loc.settings_language,
      subtitle: _getLanguageLabel(locale, loc),
      onTap: () => _showLanguagePicker(context, locale, loc),
    );
  }

  Widget _buildThemeSelector(BuildContext context, gen.AppLocalizations loc) {
    final currentMode =
        ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.system, loc.theme_automatic, Icons.smartphone_outlined),
      (ThemeMode.light, loc.theme_light, Icons.light_mode_outlined),
      (ThemeMode.dark, loc.theme_dark, Icons.dark_mode_outlined),
    ];
    return Row(
      children: [
        for (final option in options) ...[
          if (option != options.first) const SizedBox(width: 8),
          Expanded(
            child: _buildThemeOption(
              context,
              icon: option.$3,
              label: option.$2,
              selected: option.$1 == currentMode,
              onTap: () =>
                  ThemeModeNotifier.of(context)?.changeTheme(option.$1),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: selected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Same tonal fill as the selected pill of the floating bar.
            color: selected ? FloatingNavBar.selectedColor(scheme) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicColorRow(BuildContext context, gen.AppLocalizations loc) {
    final dynamicColorNotifier = DynamicColorNotifier.of(context);
    final enabled = dynamicColorNotifier?.dynamicColorEnabled ?? false;
    return SettingsTile(
      icon: Icons.palette_outlined,
      title: loc.settings_dynamic_color,
      subtitle: loc.settings_dynamic_color_desc,
      switchValue: enabled,
      onSwitch: (val) => dynamicColorNotifier?.changeDynamicColor(val),
    );
  }

  String _getLanguageLabel(String locale, gen.AppLocalizations genLoc) {
    switch (locale) {
      case 'it':
        return genLoc.settings_language_it;
      case 'pt':
        return genLoc.settings_language_pt;
      case 'es':
        return genLoc.settings_language_es;
      case 'zh':
        return genLoc.settings_language_zh;
      case 'en':
      default:
        return genLoc.settings_language_en;
    }
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    String currentLocale,
    gen.AppLocalizations loc,
  ) async {
    final names = {
      'it': loc.settings_language_it,
      'en': loc.settings_language_en,
      'es': loc.settings_language_es,
      'pt': loc.settings_language_pt,
      'zh': loc.settings_language_zh,
    };
    final picked = await showSelectionBottomSheet<String>(
      context: context,
      items: names.keys.toList(),
      selected: currentLocale,
      itemLabel: (code) => names[code]!,
      sheetTitle: loc.settings_select_language,
    );
    if (picked == null || picked == currentLocale || !context.mounted) return;
    LocaleNotifier.of(context)?.changeLocale(picked);
    onLocaleChanged?.call(picked);
  }
}
