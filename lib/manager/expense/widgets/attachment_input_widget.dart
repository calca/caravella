import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'attachments/attachment_slot.dart';
import 'attachments/attachment_state_manager.dart';
import '../errors/expense_error_handler.dart';

/// Refactored attachment input widget with improved architecture
/// Now uses AttachmentStateManager for business logic and AttachmentSlot for UI
/// Reduces complexity from 406 lines to ~200 lines
class AttachmentInputWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> attachments;
  final Function(String) onAttachmentAdded;
  final Function(int) onAttachmentRemoved;
  final Function(String) onAttachmentTapped;
  final bool enabled;

  const AttachmentInputWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.attachments,
    required this.onAttachmentAdded,
    required this.onAttachmentRemoved,
    required this.onAttachmentTapped,
    this.enabled = true,
  });

  @override
  State<AttachmentInputWidget> createState() => _AttachmentInputWidgetState();
}

class _AttachmentInputWidgetState extends State<AttachmentInputWidget> {
  late AttachmentStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stateManager = AttachmentStateManager(
      groupId: widget.groupId,
      groupName: widget.groupName,
      initialAttachments: widget.attachments,
    );
    _stateManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _stateManager.removeListener(_onStateChanged);
    _stateManager.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

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
              '${_stateManager.count}/${_stateManager.maxAttachments}',
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
            itemCount: _stateManager.maxAttachments,
            itemBuilder: (context, index) {
              final attachments = _stateManager.attachments;
              if (index < attachments.length) {
                return AttachmentSlot(
                  filePath: attachments[index],
                  onTap: () => widget.onAttachmentTapped(attachments[index]),
                  onRemove: widget.enabled
                      ? () {
                          _stateManager.removeAttachment(index);
                          widget.onAttachmentRemoved(index);
                        }
                      : null,
                );
              } else if (index == attachments.length &&
                  _stateManager.isProcessing) {
                // Show loading slot while processing
                return _buildLoadingSlot(theme);
              } else {
                return AttachmentSlot(
                  onTap: (widget.enabled && !_stateManager.isProcessing)
                      ? () => _showAttachmentSourcePicker(context)
                      : () {}, // no-op when disabled
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingSlot(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.surfaceContainerLow,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAttachmentSourcePicker(BuildContext context) async {
    final loc = gen.AppLocalizations.of(context);

    if (!_stateManager.canAddMore) {
      ExpenseErrorHandler.showAttachmentLimitError(
        context,
        maxCount: _stateManager.maxAttachments,
      );
      return;
    }

    final source = await showModalBottomSheet<AttachmentSource>(
      context: context,
      builder: (context) => GroupBottomSheetScaffold(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc.from_camera),
              onTap: () => Navigator.pop(context, AttachmentSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc.from_gallery),
              onTap: () => Navigator.pop(context, AttachmentSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(loc.from_files),
              onTap: () => Navigator.pop(context, AttachmentSource.files),
            ),
          ],
        ),
      ),
    );

    if (source != null && context.mounted) {
      await _handleAttachmentSelection(context, source);
    }
  }

  Future<void> _handleAttachmentSelection(
    BuildContext context,
    AttachmentSource source,
  ) async {
    try {
      CameraMediaType? mediaType;

      // For camera, ask user to choose between photo and video
      if (source == AttachmentSource.camera) {
        mediaType = await _showCameraMediaTypePicker(context);
        if (mediaType == null) return;
      }

      final filePath = await _stateManager.addAttachment(
        source,
        cameraMediaType: mediaType,
      );

      if (filePath != null && context.mounted) {
        widget.onAttachmentAdded(filePath);
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.show(context, 'Error: $e', type: ToastType.error);
      }
    }
  }

  Future<CameraMediaType?> _showCameraMediaTypePicker(
    BuildContext context,
  ) async {
    final loc = gen.AppLocalizations.of(context);

    return showDialog<CameraMediaType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.attachment_source),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Photo'),
              onTap: () => Navigator.of(ctx).pop(CameraMediaType.photo),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () => Navigator.of(ctx).pop(CameraMediaType.video),
            ),
          ],
        ),
      ),
    );
  }
}
