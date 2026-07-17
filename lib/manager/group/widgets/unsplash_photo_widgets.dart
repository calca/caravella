import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/unsplash/unsplash_photo.dart';
import 'unsplash_thumbnail.dart';

/// Grid tile shown in [UnsplashSearchPage]'s results grid.
class PhotoTile extends StatelessWidget {
  final UnsplashPhoto photo;
  final VoidCallback onTap;
  const PhotoTile({super.key, required this.photo, required this.onTap});

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
            UnsplashThumbnail(url: photo.urls.thumb),
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

/// Footer pinned at the bottom of [UnsplashSearchPage], crediting Unsplash.
class UnsplashAttributionFooter extends StatelessWidget {
  const UnsplashAttributionFooter({super.key});

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
class PhotoPreviewSheet extends StatelessWidget {
  final UnsplashPhoto photo;
  const PhotoPreviewSheet({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CaravellaBottomSheetScaffold(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photo preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: UnsplashThumbnail(url: photo.urls.small),
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
