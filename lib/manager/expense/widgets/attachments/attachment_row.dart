import 'dart:io';

import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as path;

/// One attachment of the expense form's list: a round preview (the photo
/// itself, or a monochrome icon for PDFs, videos and other files), the file
/// name, its type and size, and a remove button when [onRemove] is set.
/// Tapping the row opens the attachment.
class AttachmentRow extends StatelessWidget {
  final String filePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const AttachmentRow({
    super.key,
    required this.filePath,
    required this.onTap,
    this.onRemove,
  });

  static const double _previewSize = 40;
  static const _images = {'.jpg', '.jpeg', '.png', '.webp', '.heic'};
  static const _videos = {'.mp4', '.mov'};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final name = displayName(filePath);
    final extension = path.extension(filePath).toLowerCase();
    final details = [
      if (extension.length > 1) extension.substring(1).toUpperCase(),
      ?_size(filePath),
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: 16,
            end: onRemove == null ? 16 : 4,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              ExcludeSemantics(child: _preview(extension, s)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(details, style: AppTextStyles.subtle(context)),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: gloc.attachment_remove(name),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: s.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// The file name without the timestamp the app puts in front when saving
  /// it (`AttachmentsStorageService.getAttachmentPath`).
  static String displayName(String filePath) =>
      path.basename(filePath).replaceFirst(RegExp(r'^\d{10,}_'), '');

  Widget _preview(String extension, ColorScheme s) {
    Widget icon(IconData data) => Container(
      width: _previewSize,
      height: _previewSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.onSurface.withValues(alpha: 0.06),
      ),
      child: Icon(data, size: 20, color: s.onSurfaceVariant),
    );

    if (_images.contains(extension)) {
      return ClipOval(
        child: Image.file(
          File(filePath),
          width: _previewSize,
          height: _previewSize,
          fit: BoxFit.cover,
          // Decode a thumbnail, not the full photo.
          cacheWidth: 160,
          errorBuilder: (_, _, _) => icon(Icons.image_outlined),
        ),
      );
    }
    if (_videos.contains(extension)) return icon(Icons.videocam_outlined);
    if (extension == '.pdf') return icon(Icons.description_outlined);
    return icon(Icons.insert_drive_file_outlined);
  }

  /// The file's size ("21 kB", "1.4 MB"), or null if it can't be read.
  static String? _size(String filePath) {
    try {
      final bytes = File(filePath).lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} kB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return null;
    }
  }
}
