import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../manager/group/widgets/section_header.dart';
import '../../widgets/caravella_app_bar.dart';
import '../../updates/update_check_widget.dart';

class WhatsNewPage extends StatefulWidget {
  const WhatsNewPage({super.key});

  @override
  State<WhatsNewPage> createState() => _WhatsNewPageState();
}

class _WhatsNewPageState extends State<WhatsNewPage> {
  String _markdownContent = '';
  bool _isLoading = true;
  String? _error;

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return Scaffold(appBar: const CaravellaAppBar(), body: _buildBody(loc));
  }

  Widget _buildBody(gen.AppLocalizations loc) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Errore nel caricamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      children: [
        // Header section with icon and description
        SectionHeader(
          title: loc.whats_new_title,
          description: loc.whats_new_desc,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        ),

        // Update check widget (only on Android)
        if (Platform.isAndroid)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: UpdateCheckWidget(),
          ),

        // Changelog section header
        SectionHeader(
          title: loc.changelog_title,
          description: loc.changelog_desc,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
        ),

        // Changelog content in a card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildMarkdownContent(theme),
          ),
        ),
      ],
    );
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
