import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.whats_new_title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: _buildBody(loc),
    );
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
    final mdTheme = GptMarkdownThemeData(
      brightness: theme.brightness,
      h1: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
      h2: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.w600,
      ),
      h3: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.secondary,
        fontWeight: FontWeight.w500,
      ),
      linkColor: theme.colorScheme.primary,
      hrLineColor: theme.colorScheme.outlineVariant,
      hrLineThickness: 1.0,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GptMarkdownTheme(
        gptThemeData: mdTheme,
        child: GptMarkdown(
          _markdownContent,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.start,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}
