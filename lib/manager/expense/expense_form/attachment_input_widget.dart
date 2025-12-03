import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class AttachmentInputWidget extends StatelessWidget {
  final String groupId;
  final List<String> attachments;
  final Function(String) onAttachmentAdded;
  final Function(int) onAttachmentRemoved;
  final Function(String) onAttachmentTapped;

  const AttachmentInputWidget({
    super.key,
    required this.groupId,
    required this.attachments,
    required this.onAttachmentAdded,
    required this.onAttachmentRemoved,
    required this.onAttachmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(loc.attachments, style: theme.textTheme.titleSmall),
              ],
            ),
            Text(
              '${attachments.length}/5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index < attachments.length) {
                return _AttachmentThumbnail(
                  filePath: attachments[index],
                  onTap: () => onAttachmentTapped(attachments[index]),
                  onRemove: () => onAttachmentRemoved(index),
                );
              } else {
                return _EmptyAttachmentSlot(
                  onTap: () => _showAttachmentSourcePicker(context),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showAttachmentSourcePicker(BuildContext context) async {
    final loc = gen.AppLocalizations.of(context);

    if (attachments.length >= 5) {
      AppToast.show(
        context,
        loc.attachment_limit_reached,
        type: ToastType.error,
      );
      return;
    }

    final source = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      builder: (context) => GroupBottomSheetScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc.from_camera),
              onTap: () => Navigator.pop(context, _AttachmentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc.from_gallery),
              onTap: () => Navigator.pop(context, _AttachmentSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(loc.from_files),
              onTap: () => Navigator.pop(context, _AttachmentSource.files),
            ),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      await _pickAttachment(context, source);
    }
  }

  Future<void> _pickAttachment(
    BuildContext context,
    _AttachmentSource source,
  ) async {
    try {
      String? filePath;

      switch (source) {
        case _AttachmentSource.camera:
          // Show dialog to choose between photo and video
          final mediaType = await showDialog<_CameraMediaType>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(gen.AppLocalizations.of(context).attachment_source),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Photo'),
                    onTap: () => Navigator.of(ctx).pop(_CameraMediaType.photo),
                  ),
                  ListTile(
                    leading: const Icon(Icons.videocam),
                    title: const Text('Video'),
                    onTap: () => Navigator.of(ctx).pop(_CameraMediaType.video),
                  ),
                ],
              ),
            ),
          );

          if (mediaType != null && context.mounted) {
            final picker = ImagePicker();
            XFile? file;

            if (mediaType == _CameraMediaType.photo) {
              file = await picker.pickImage(source: ImageSource.camera);
            } else {
              file = await picker.pickVideo(source: ImageSource.camera);
            }

            if (file != null) {
              filePath = await _saveAttachment(file.path);
            }
          }
          break;
        case _AttachmentSource.gallery:
          final picker = ImagePicker();
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
          );
          if (image != null) {
            filePath = await _saveAttachment(image.path);
          }
          break;
        case _AttachmentSource.files:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'mp4', 'mov'],
          );
          if (result != null && result.files.single.path != null) {
            filePath = await _saveAttachment(result.files.single.path!);
          }
          break;
      }

      if (filePath != null) {
        onAttachmentAdded(filePath);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, 'Error: $e', type: ToastType.error);
      }
    }
  }

  Future<String> _saveAttachment(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${directory.path}/attachments/$groupId');

    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(sourcePath)}';
    final targetPath = '${attachmentsDir.path}/$fileName';
    final extension = path.extension(sourcePath).toLowerCase();

    // Compress images to reduce storage
    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      try {
        final sourceFile = File(sourcePath);
        final imageBytes = await sourceFile.readAsBytes();
        final image = img.decodeImage(imageBytes);

        if (image != null) {
          // Resize if too large (max 1920px on longest side)
          final resized = image.width > 1920 || image.height > 1920
              ? img.copyResize(
                  image,
                  width: image.width > image.height ? 1920 : null,
                  height: image.height > image.width ? 1920 : null,
                )
              : image;

          // Compress as JPEG with 85% quality
          final compressed = img.encodeJpg(resized, quality: 85);
          await File(targetPath).writeAsBytes(compressed);

          return targetPath;
        }
      } catch (e) {
        // If compression fails, fall back to simple copy
        await File(sourcePath).copy(targetPath);
        return targetPath;
      }
    }

    // For non-images (PDF, video), just copy
    await File(sourcePath).copy(targetPath);

    return targetPath;
  }
}

enum _AttachmentSource { camera, gallery, files }

enum _CameraMediaType { photo, video }

class _EmptyAttachmentSlot extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyAttachmentSlot({required this.onTap});

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
              color: theme.colorScheme.outlineVariant,
              style: BorderStyle.solid,
            ),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Icon(
            Icons.add,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  final String filePath;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _AttachmentThumbnail({
    required this.filePath,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(filePath);
    final extension = path.extension(filePath).toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
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
              onTap: onRemove,
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
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(theme);
        },
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
