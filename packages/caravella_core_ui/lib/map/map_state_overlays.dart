import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import '../widgets/card_outline.dart';
import 'map_tile_status.dart';

/// "Loading" pill in the middle of a map, while [status] says it's slow.
///
/// Touches go through to the map.
class MapLoadingOverlay extends StatelessWidget {
  final MapTileStatus status;
  final String message;

  const MapLoadingOverlay({
    super.key,
    required this.status,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;

    return ListenableBuilder(
      listenable: status,
      builder: (context, _) {
        if (status.state != MapTileState.slow) return const SizedBox.shrink();
        return IgnorePointer(
          child: Center(
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: s.raisedSurface,
                shape: const StadiumBorder(),
                elevation: 2,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: s.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Card saying the map can't be shown, with a way to try again.
///
/// Takes no space unless [status] says the tiles failed.
class MapUnavailableCard extends StatelessWidget {
  final MapTileStatus status;
  final String title;
  final String message;
  final String retryLabel;

  const MapUnavailableCard({
    super.key,
    required this.status,
    required this.title,
    required this.message,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final radius = BorderRadius.circular(24);

    return ListenableBuilder(
      listenable: status,
      builder: (context, _) {
        if (status.state != MapTileState.unavailable) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Semantics(
            liveRegion: true,
            container: true,
            child: CardOutline(
              borderRadius: radius,
              child: Material(
                color: s.raisedSurface,
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: s.onSurface.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 19,
                          color: s.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: s.onSurfaceVariant,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-12, 0),
                              child: TextButton(
                                onPressed: status.retry,
                                child: Text(retryLabel),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Error message overlay for map operations
///
/// Shows a small error message, typically for non-critical errors
/// like failed searches or geocoding issues.
class MapErrorOverlay extends StatelessWidget {
  final String message;

  const MapErrorOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(message, style: TextStyle(color: colorScheme.error)),
    );
  }
}

/// Full-page error state for critical map failures
///
/// Displays a centered error icon, title, and message when the map
/// cannot be displayed due to a critical error.
class MapErrorState extends StatelessWidget {
  final String title;
  final String message;

  const MapErrorState({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-page empty state for maps with no data
///
/// Displays a centered icon, title, and subtitle when there is
/// no location data to display on the map.
class MapEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const MapEmptyState({
    super.key,
    this.icon = Icons.map_outlined,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// "No results found" message for search operations
///
/// A simple text message shown when a search returns no results.
class MapNoResultsMessage extends StatelessWidget {
  final String message;

  const MapNoResultsMessage({super.key, this.message = 'No results found'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
