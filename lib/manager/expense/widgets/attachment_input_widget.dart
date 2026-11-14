import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'attachments/attachment_row.dart';
import 'attachments/attachment_state_manager.dart';
import '../errors/expense_error_handler.dart';

/// The expense's attachments: an "Attachments" section label with the count,
/// one [AttachmentRow] per file in a card, then an "Add attachment" pill
/// while there's room, or the limit once it's full. The pill opens the
/// sources (photo, video, gallery, file) in place, as pills under it: no
/// sheet, so none opens on top of the expense sheet.
/// [AttachmentStateManager] holds the logic.
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

  /// The sources are open under the pill.
  bool _choosing = false;

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
      final pill = FormPill(
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
        // Same pill as under the list once there is one.
        label: loc.attachment_source,
        style: FormPillStyle.add,
        onTap: widget.enabled && !busy ? _toggleSources : null,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [pill, _sources(context)],
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
                onTap: busy ? null : _toggleSources,
              ),
            ),
          ),
        if (widget.enabled && _stateManager.canAddMore)
          _sources(context)
        else if (widget.enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Text(
              loc.attachment_limit(_stateManager.maxAttachments),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  void _toggleSources() {
    if (!_stateManager.canAddMore) return;
    setState(() => _choosing = !_choosing);
  }

  /// Photo, video, gallery and file as pills, under the "add" pill while
  /// [_choosing]; the sheet grows to show them.
  Widget _sources(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    Widget source(
      IconData icon,
      String label,
      AttachmentSource source, [
      CameraMediaType? media,
    ]) => FormPill(
      icon: icon,
      label: label,
      onTap: () {
        setState(() => _choosing = false);
        _handleAttachmentSelection(context, source, mediaType: media);
      },
    );
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: !_choosing
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  source(
                    Icons.photo_camera_outlined,
                    loc.attachment_take_photo,
                    AttachmentSource.camera,
                    CameraMediaType.photo,
                  ),
                  source(
                    Icons.videocam_outlined,
                    loc.attachment_record_video,
                    AttachmentSource.camera,
                    CameraMediaType.video,
                  ),
                  source(
                    Icons.photo_library_outlined,
                    loc.from_gallery,
                    AttachmentSource.gallery,
                  ),
                  source(
                    Icons.attach_file_rounded,
                    loc.from_files,
                    AttachmentSource.files,
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _handleAttachmentSelection(
    BuildContext context,
    AttachmentSource source, {
    CameraMediaType? mediaType,
  }) async {
    try {
      final filePath = await _stateManager.addAttachment(
        source,
        cameraMediaType: mediaType,
      );

      if (filePath != null && context.mounted) {
        widget.onAttachmentAdded(filePath);
      }
    } catch (e) {
      if (context.mounted) {
        ExpenseErrorHandler.showAttachmentAddError(context, e);
      }
    }
  }
}
