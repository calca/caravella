import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../update/app_update_localizations.dart';

class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({super.key});

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  String _markdownContent = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Don't load content in initState, wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadMarkdownContent();
    }
  }

  Future<void> _loadMarkdownContent() async {
    try {
      // Get current locale
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode;

      // Try to load locale-specific changelog first
      String filePath = 'assets/docs/CHANGELOG_$languageCode.md';
      String content;

      try {
        content = await rootBundle.loadString(filePath);
      } catch (_) {
        // Fallback to English if locale-specific file doesn't exist
        content = await rootBundle.loadString('assets/docs/CHANGELOG_en.md');
      }

      if (mounted) {
        setState(() {
          _markdownContent = content;
          _isLoading = false;
        });
      }
    } catch (e, st) {
      LoggerService.error(
        'Failed to load changelog',
        name: 'settings.whats_new',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.settings,
        title: loc.whats_new_title,
        children: _buildBody(loc),
      ),
    );
  }

  List<Widget> _buildBody(gen.AppLocalizations loc) {
    if (_isLoading) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_hasError) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                loc.whats_new_load_error,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ];
    }

    final theme = Theme.of(context);
    return [
      // Update check (only on Android, Play builds)
      if (Platform.isAndroid && GmsIntegrations.instance.appUpdates != null)
        GmsIntegrations.instance.appUpdates!.buildUpdateCheckWidget(
          localizations: AppUpdateLocalizations(loc),
          cardBuilder: (context, child) => SettingsGroup(children: [child]),
        ),
      SettingsGroup(
        label: loc.changelog_title,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: _buildMarkdownContent(theme),
          ),
        ],
      ),
    ];
  }

  Widget _buildMarkdownContent(ThemeData theme) {
    final mdTheme = GptMarkdownThemeData(
      brightness: theme.brightness,
      h1: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      linkColor: theme.colorScheme.onSurface,
      hrLineColor: theme.colorScheme.outlineVariant,
      hrLineThickness: 1.0,
    );

    return GptMarkdownTheme(
      gptThemeData: mdTheme,
      child: GptMarkdown(
        _markdownContent,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.start,
        textDirection: Directionality.of(context),
      ),
    );
  }
}
