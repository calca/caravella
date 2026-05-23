import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
  const UnsplashSearchPage({super.key, this.initialQuery});

  /// Optional query to pre-fill and auto-search when the page opens.
  final String? initialQuery;

  @override
  State<UnsplashSearchPage> createState() => _UnsplashSearchPageState();

  /// Push the search page and return the downloaded image file (or null).
  static Future<File?> show(BuildContext context, {String? initialQuery}) {
    return Navigator.of(context).push<File?>(
      MaterialPageRoute(
        builder: (_) => UnsplashSearchPage(initialQuery: initialQuery),
      ),
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
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _searchController.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _search(initial);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
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

  Future<void> _previewPhoto(UnsplashPhoto photo) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _PhotoPreviewSheet(photo: photo),
    );
    if (confirmed == true && mounted) {
      await _selectPhoto(photo);
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
                  backgroundColor: WidgetStateProperty.all(
                    colorScheme.surfaceContainer,
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Results
              Expanded(child: _buildBody(theme, colorScheme, loc)),

              // Attribution footer – always pinned at the bottom of the Column.
              // ColoredBox + SafeArea ensure it stays above the system nav bar
              // in edge-to-edge mode and doesn't blend with the content.
              ColoredBox(
                color: colorScheme.surface,
                child: const SafeArea(
                  top: false,
                  child: _UnsplashAttributionFooter(),
                ),
              ),
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
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: colorScheme.error,
              ),
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
              Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
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
        return _PhotoTile(photo: photo, onTap: () => _previewPhoto(photo));
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
            _UnsplashThumbnail(url: photo.urls.thumb),
            // Attribution overlay at the bottom – tapping opens photographer profile
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => launchUrl(
                  Uri.parse(
                    'https://unsplash.com/@${photo.user.username}'
                    '?utm_source=caravella&utm_medium=referral',
                  ),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
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
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
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

/// Loads an Unsplash thumbnail using the `http` package (same network path as
/// API calls) instead of [Image.network], which on Android emulators may bind
/// to the wlan0 interface even when only eth0 has a working default route.
class _UnsplashThumbnail extends StatefulWidget {
  final String url;
  const _UnsplashThumbnail({required this.url});

  @override
  State<_UnsplashThumbnail> createState() => _UnsplashThumbnailState();
}

class _UnsplashThumbnailState extends State<_UnsplashThumbnail> {
  Uint8List? _bytes;
  bool _error = false;
  bool _visible = false;
  // Incremented on every new fetch; checked after each await so that
  // responses from a superseded request are silently discarded.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(_UnsplashThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      // Immediately invalidate any in-flight request from the old URL before
      // resetting state and starting a new fetch.
      ++_generation;
      setState(() {
        _bytes = null;
        _error = false;
        _visible = false;
      });
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final gen = ++_generation;
    final url = widget.url;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && _generation == gen && mounted) {
        setState(() => _bytes = response.bodyBytes);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_generation == gen && mounted) setState(() => _visible = true);
        });
      }
    } on TimeoutException {
      LoggerService.warning(
        'Thumbnail load timed out: $url',
        name: 'api.unsplash',
      );
      if (_generation == gen && mounted) setState(() => _error = true);
    } catch (e) {
      LoggerService.warning('Thumbnail load failed: $e', name: 'api.unsplash');
      if (_generation == gen && mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
    if (_bytes == null) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
      child: Image.memory(_bytes!, fit: BoxFit.cover),
    );
  }
}

class _UnsplashAttributionFooter extends StatelessWidget {
  const _UnsplashAttributionFooter();

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${loc.unsplash_photos_by} ', style: baseStyle),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(
                'https://unsplash.com/?utm_source=caravella&utm_medium=referral',
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'Unsplash',
              style: baseStyle?.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet shown before a photo is selected, displaying a preview and
/// a tappable attribution link to the photographer's Unsplash profile.
class _PhotoPreviewSheet extends StatelessWidget {
  final UnsplashPhoto photo;
  const _PhotoPreviewSheet({required this.photo});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Photo preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: _UnsplashThumbnail(url: photo.urls.small),
            ),
          ),
          const SizedBox(height: 12),
          // Photographer attribution – tappable link with UTM params (required by Unsplash guidelines)
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse(
                'https://unsplash.com/@${photo.user.username}'
                '?utm_source=caravella&utm_medium=referral',
              ),
              mode: LaunchMode.externalApplication,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${loc.unsplash_photos_by} ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  photo.user.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(loc.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc.unsplash_use_photo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
