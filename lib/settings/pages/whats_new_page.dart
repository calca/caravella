import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../widgets/caravella_app_bar.dart';

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
    _loadMarkdownContent();
  }

  Future<void> _loadMarkdownContent() async {
    try {
      final content = await rootBundle.loadString('assets/docs/CHANGELOG.md');
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
      return const Center(
        child: CircularProgressIndicator(),
      );
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

    return Markdown(
      data: _markdownContent,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        h2: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        h3: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
        p: Theme.of(context).textTheme.bodyMedium,
        listBullet: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        blockSpacing: 16,
        listIndent: 24,
      ),
    );
  }
}