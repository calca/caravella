import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'attachments/attachment_row.dart';
import 'attachments/attachment_state_manager.dart';
import '../errors/expense_error_handler.dart';

/// The expense's attachments: an "Attachments" section label with the count,
/// one [AttachmentRow] per file in a card, then an "Add attachment" pill
/// while there's room. [AttachmentStateManager] holds the logic.
class AttachmentInputWidget extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> attachments;
  final Function(String) onAttachmentAdded;
  final Function(int) onAttachmentRemoved;
  final Function(String) onAttachmentTapped;
  final bool enabled;

  /// Shows only a dashed "Attachments" pill that adds the first one (the
  /// expense form swaps it for the full strip once there is one).
  final bool asPill;

  const AttachmentInputWidget({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.attachments,
    required this.onAttachmentAdded,
    required this.onAttachmentRemoved,
    required this.onAttachmentTapped,
    this.enabled = true,
    this.asPill = false,
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

    if (widget.asPill) {
      final busy = _stateManager.isProcessing;
      return FormPill(
        icon: busy ? null : Icons.attach_file_rounded,
        leading: busy
            ? SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        label: loc.attachments,
        style: FormPillStyle.add,
        onTap: widget.enabled && !busy
            ? () => _showAttachmentSourcePicker(context)
            : null,
      );
    }

    final attachments = _stateManager.attachments;
    final busy = _stateManager.isProcessing;
    final radius = BorderRadius.circular(16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: FormSectionLabel(loc.attachments)),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                '${_stateManager.count}/${_stateManager.maxAttachments}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        CardOutline(
          borderRadius: radius,
          child: Material(
            color: theme.colorScheme.raisedSurface,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < attachments.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color: CardOutline.colorFor(theme.brightness),
                    ),
                  AttachmentRow(
                    filePath: attachments[i],
                    onTap: () => widget.onAttachmentTapped(attachments[i]),
                    onRemove: widget.enabled
                        ? () {
                            _stateManager.removeAttachment(i);
                            widget.onAttachmentRemoved(i);
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.enabled && (_stateManager.canAddMore || busy))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FormPill(
                icon: busy ? null : Icons.attach_file_rounded,
                leading: busy
                    ? SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                label: loc.attachment_source,
                style: FormPillStyle.add,
                onTap: busy ? null : () => _showAttachmentSourcePicker(context),
              ),
            ),
          ),
      ],
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
      builder: (context) => CaravellaBottomSheetScaffold(
        title: loc.attachment_source,
        child: SettingsGroup(
          topSpacing: 0,
          children: [
            SettingsTile(
              icon: Icons.photo_camera_outlined,
              title: loc.from_camera,
              chevron: false,
              onTap: () => Navigator.pop(context, AttachmentSource.camera),
            ),
            SettingsTile(
              icon: Icons.photo_library_outlined,
              title: loc.from_gallery,
              chevron: false,
              onTap: () => Navigator.pop(context, AttachmentSource.gallery),
            ),
            SettingsTile(
              icon: Icons.attach_file_rounded,
              title: loc.from_files,
              chevron: false,
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

    return showModalBottomSheet<CameraMediaType>(
      context: context,
      builder: (ctx) => CaravellaBottomSheetScaffold(
        title: loc.from_camera,
        child: SettingsGroup(
          topSpacing: 0,
          children: [
            SettingsTile(
              icon: Icons.photo_camera_outlined,
              title: loc.attachment_take_photo,
              chevron: false,
              onTap: () => Navigator.of(ctx).pop(CameraMediaType.photo),
            ),
            SettingsTile(
              icon: Icons.videocam_outlined,
              title: loc.attachment_record_video,
              chevron: false,
              onTap: () => Navigator.of(ctx).pop(CameraMediaType.video),
            ),
          ],
        ),
      ),
    );
  }
}
