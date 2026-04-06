import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/unsplash/unsplash_photo.dart';
import '../../../services/unsplash/unsplash_service.dart';

/// Full-screen page for searching free images on Unsplash.
///
/// Returns the downloaded [File] when the user selects a photo, or null
/// if cancelled.
class UnsplashSearchPage extends StatefulWidget {
  const UnsplashSearchPage({super.key});

  @override
  State<UnsplashSearchPage> createState() => _UnsplashSearchPageState();

  /// Push the search page and return the downloaded image file (or null).
  static Future<File?> show(BuildContext context) {
    return Navigator.of(context).push<File?>(
      MaterialPageRoute(builder: (_) => const UnsplashSearchPage()),
    );
  }
}

class _UnsplashSearchPageState extends State<UnsplashSearchPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  List<UnsplashPhoto> _results = [];
  bool _isSearching = false;
  bool _isDownloading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _hasSearched = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    try {
      final results = await UnsplashService.searchPhotos(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _selectPhoto(UnsplashPhoto photo) async {
    setState(() => _isDownloading = true);
    try {
      final file = await UnsplashService.downloadPhoto(
        photo.urls.regular,
        downloadLocationUrl: photo.downloadLocationUrl,
      );
      if (mounted) {
        Navigator.of(context).pop(file);
      }
    } catch (e) {
      LoggerService.warning(
        'Failed to download Unsplash photo: $e',
        name: 'api.unsplash',
      );
      if (mounted) {
        setState(() => _isDownloading = false);
        final loc = gen.AppLocalizations.of(context);
        AppToast.show(context, loc.unsplash_error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CaravellaAppBar(
        headerSemanticLabel: loc.from_unsplash,
        backButtonSemanticLabel: loc.cancel,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Container(
                color: colorScheme.surface,
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  hintText: loc.unsplash_search_hint,
                  leading: const Icon(Icons.search_outlined),
                  trailing: _isSearching
                      ? [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ]
                      : _searchController.text.isNotEmpty
                          ? [
                              IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              ),
                            ]
                          : [],
                  onChanged: _onSearchChanged,
                  onSubmitted: _search,
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor:
                      WidgetStateProperty.all(colorScheme.surfaceContainer),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Results
              Expanded(child: _buildBody(theme, colorScheme, loc)),
            ],
          ),

          // Download overlay
          if (_isDownloading)
            ColoredBox(
              color: Colors.black38,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      loc.unsplash_downloading,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    ColorScheme colorScheme,
    gen.AppLocalizations loc,
  ) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48,
                  color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                loc.unsplash_error,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_hasSearched && _results.isEmpty && !_isSearching) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 48,
                  color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                loc.unsplash_no_results,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            loc.unsplash_search_hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final photo = _results[index];
        return _PhotoTile(
          photo: photo,
          onTap: () => _selectPhoto(photo),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final UnsplashPhoto photo;
  final VoidCallback onTap;
  const _PhotoTile({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.urls.small,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
            // Attribution overlay at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Text(
                  photo.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
