import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings_appearance)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          _buildThemeSelector(context, loc),
          const SizedBox(height: 16),
          _buildDynamicColorRow(context, loc),
          const SizedBox(height: 8),
          _buildLanguageRow(context, locale, loc),
        ],
      ),
    );
  }

  Widget _buildLanguageRow(
    BuildContext context,
    String locale,
    gen.AppLocalizations loc,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final label = _getLanguageLabel(locale, loc);
    return SettingsCard(
      context: context,
      semanticsButton: true,
      semanticsLabel: '${loc.settings_language} - Current: $label',
      semanticsHint: 'Double tap to change language',
      color: colorScheme.surface,
      onTap: () => _showLanguagePicker(context, locale, loc),
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(loc.settings_language, style: textTheme.titleMedium),
        subtitle: Text(label),
        trailing: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, gen.AppLocalizations loc) {
    final textTheme = Theme.of(context).textTheme;
    final currentMode =
        ThemeModeNotifier.of(context)?.themeMode ?? ThemeMode.system;
    final options = <(ThemeMode, String, IconData)>[
      (ThemeMode.system, loc.theme_automatic, Icons.smartphone_outlined),
      (ThemeMode.light, loc.theme_light, Icons.light_mode_outlined),
      (ThemeMode.dark, loc.theme_dark, Icons.dark_mode_outlined),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(loc.settings_theme, style: textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        Row(
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
        ),
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
            color: selected ? scheme.surfaceContainerHigh : null,
            border: Border.all(
              color: selected ? Colors.transparent : scheme.outlineVariant,
            ),
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dynamicColorNotifier = DynamicColorNotifier.of(context);
    final enabled = dynamicColorNotifier?.dynamicColorEnabled ?? false;

    return SettingsCard(
      context: context,
      color: colorScheme.surface,
      child: Semantics(
        toggled: enabled,
        label:
            '${loc.settings_dynamic_color} - ${enabled ? loc.accessibility_currently_enabled : loc.accessibility_currently_disabled}',
        hint: enabled
            ? loc.accessibility_double_tap_disable
            : loc.accessibility_double_tap_enable,
        child: ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(loc.settings_dynamic_color, style: textTheme.titleMedium),
          subtitle: Text(
            loc.settings_dynamic_color_desc,
            style: textTheme.bodySmall,
          ),
          trailing: Semantics(
            label: loc.accessibility_security_switch(
              enabled
                  ? loc.accessibility_switch_on
                  : loc.accessibility_switch_off,
            ),
            child: Switch(
              value: enabled,
              onChanged: (val) {
                dynamicColorNotifier?.changeDynamicColor(val);
              },
            ),
          ),
        ),
      ),
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
          ('pt', loc.settings_language_pt),
          ('zh', loc.settings_language_zh),
        ];
        return CaravellaBottomSheetScaffold(
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
                          onLocaleChanged?.call(e.$1);
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
}
