import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// A single reusable attachment slot widget
/// Can display either an empty slot with add button or a thumbnail with content
class AttachmentSlot extends StatelessWidget {
  final String? filePath;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const AttachmentSlot({
    super.key,
    this.filePath,
    required this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (filePath == null) {
      return _EmptySlot(onTap: onTap);
    }
    return _FilledSlot(filePath: filePath!, onTap: onTap, onRemove: onRemove!);
  }
}

class _EmptySlot extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptySlot({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.surfaceContainerHighest,
              style: BorderStyle.solid,
            ),
            color: theme.colorScheme.surfaceContainerLow,
          ),
          child: Icon(
            Icons.add,
            size: 32,
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class _FilledSlot extends StatefulWidget {
  final String filePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FilledSlot({
    required this.filePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_FilledSlot> createState() => _FilledSlotState();
}

class _FilledSlotState extends State<_FilledSlot> {
  bool _imageLoaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(widget.filePath);
    final extension = path.extension(widget.filePath).toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildThumbnailContent(file, extension, theme),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailContent(File file, String extension, ThemeData theme) {
    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      return AnimatedOpacity(
        opacity: _imageLoaded ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Image.file(
          file,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) {
              _imageLoaded = true;
              return child;
            }
            if (frame != null && !_imageLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _imageLoaded = true;
                  });
                }
              });
            }
            return child;
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(theme);
          },
        ),
      );
    } else if (extension == '.pdf') {
      return Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      );
    } else if (['.mp4', '.mov'].contains(extension)) {
      return Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      );
    } else {
      return Center(
        child: Icon(
          Icons.insert_drive_file,
          size: 48,
          color: theme.colorScheme.primary,
        ),
      );
    }
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.error_outline,
        size: 48,
        color: theme.colorScheme.error,
      ),
    );
  }
}
