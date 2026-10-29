import 'dart:async';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/unsplash/unsplash_photo.dart';
import '../../../services/unsplash/unsplash_service.dart';
import '../widgets/unsplash_photo_widgets.dart';

/// Full-screen page for searching free images on Unsplash.
///
/// Returns the downloaded [File] when the user selects a photo, or null
/// if cancelled.
class UnsplashSearchPage extends StatefulWidget {
  const UnsplashSearchPage({super.key, this.initialQuery, this.search});

  /// Optional query to pre-fill and auto-search when the page opens.
  final String? initialQuery;

  /// Fetches one page of results: [UnsplashService.searchPhotos] unless a
  /// test supplies another.
  @visibleForTesting
  final Future<UnsplashSearchResults> Function(String query, {int page})?
  search;

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
  final _scrollController = ScrollController();
  Timer? _debounce;

  List<UnsplashPhoto> _results = [];
  bool _isSearching = false;
  bool _isDownloading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  /// The query [_results] belong to, the last page loaded and how many the
  /// search has: scrolling near the end loads the next one.
  String _query = '';
  int _page = 0;
  int _totalPages = 0;
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;

  /// Bumped by every new search, so a page that arrives for an older query
  /// is dropped.
  int _generation = 0;

  bool get _hasMore => _page < _totalPages;

  Future<UnsplashSearchResults> _fetch(String query, int page) =>
      (widget.search ?? UnsplashService.searchPhotos)(query, page: page);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      _generation++;
      setState(() {
        _results = [];
        _page = _totalPages = 0;
        _isSearching = _isLoadingMore = _loadMoreFailed = false;
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
    final generation = ++_generation;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _isLoadingMore = _loadMoreFailed = false;
    });
    try {
      final results = await _fetch(query, 1);
      if (!mounted || generation != _generation) return;
      setState(() {
        _query = query;
        _results = results.photos;
        _page = 1;
        _totalPages = results.totalPages;
        _isSearching = false;
        _hasSearched = true;
      });
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      _checkLoadMoreAfterLayout();
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 400) _loadMore();
  }

  /// A page that doesn't fill the screen can't be scrolled to its end, so
  /// check again once it's laid out.
  void _checkLoadMoreAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onScroll();
    });
  }

  Future<void> _loadMore() async {
    if (_isSearching || _isLoadingMore || _loadMoreFailed || !_hasMore) {
      return;
    }
    final generation = _generation;
    setState(() => _isLoadingMore = true);
    try {
      final results = await _fetch(_query, _page + 1);
      if (!mounted || generation != _generation) return;
      // Pages can overlap when Unsplash reorders results in between.
      final seen = {for (final photo in _results) photo.id};
      setState(() {
        _results = [
          ..._results,
          ...results.photos.where((photo) => seen.add(photo.id)),
        ];
        _page++;
        _totalPages = results.totalPages;
        _isLoadingMore = false;
      });
      _checkLoadMoreAfterLayout();
    } catch (e) {
      if (!mounted || generation != _generation) return;
      LoggerService.warning(
        'Failed to load Unsplash page ${_page + 1}: $e',
        name: 'api.unsplash',
      );
      setState(() {
        _isLoadingMore = false;
        _loadMoreFailed = true;
      });
    }
  }

  void _retryLoadMore() {
    setState(() => _loadMoreFailed = false);
    _loadMore();
  }

  Future<void> _previewPhoto(UnsplashPhoto photo) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PhotoPreviewSheet(photo: photo),
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

    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: Stack(
          children: [
            Column(
              children: [
                // Round back button and the search pill, like the other
                // search pages.
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Semantics(
                          label: loc.cancel,
                          child: const RoundBackButton(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ]
                                : _searchController.text.isNotEmpty
                                ? [
                                    IconButton(
                                      tooltip: loc.clear,
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
                              colorScheme.raisedSurface,
                            ),
                            shape: WidgetStateProperty.all(
                              const StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Results
                Expanded(child: _buildBody(theme, colorScheme, loc)),

                // Attribution footer – always pinned at the bottom of the Column.
                // ColoredBox + SafeArea ensure it stays above the system nav bar
                // in edge-to-edge mode and doesn't blend with the content.
                ColoredBox(
                  color: colorScheme.surfaceContainer,
                  child: const SafeArea(
                    top: false,
                    child: UnsplashAttributionFooter(),
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
            style: AppTextStyles.subtle(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final photo = _results[index];
              return PhotoTile(photo: photo, onTap: () => _previewPhoto(photo));
            },
          ),
        ),
        if (_isLoadingMore || _loadMoreFailed)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Center(
                child: _loadMoreFailed
                    ? Column(
                        children: [
                          Text(
                            loc.unsplash_load_more_error,
                            style: AppTextStyles.subtle(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _retryLoadMore,
                            child: Text(loc.unsplash_retry),
                          ),
                        ],
                      )
                    : const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
