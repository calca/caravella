import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import '../themes/form_theme.dart';
import 'card_outline.dart';
import 'field_action_button.dart';

/// The one field for typing a name in place — adding a person or a
/// category, or renaming one: the outlined card field of an expense's
/// description, then × (cancel) and a filled ✓ (greyed out while empty).
/// Enter confirms too.
///
/// [onCommit] gets the trimmed text and returns whether it was taken: false
/// keeps the text (e.g. a duplicate the caller has just reported). With
/// [keepOpen], a taken entry empties the field and keeps it focused for
/// the next one; otherwise closing is up to the caller.
class InlineEntryField extends StatefulWidget {
  final String hintText;
  final String commitTooltip;
  final String cancelTooltip;
  final FutureOr<bool> Function(String value) onCommit;
  final VoidCallback onCancel;
  final bool keepOpen;

  /// Text to start from (renaming).
  final String? initialText;
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const InlineEntryField({
    super.key,
    required this.hintText,
    required this.commitTooltip,
    required this.cancelTooltip,
    required this.onCommit,
    required this.onCancel,
    this.keepOpen = false,
    this.initialText,
    this.textCapitalization = TextCapitalization.sentences,
    this.controller,
    this.focusNode,
  });

  @override
  State<InlineEntryField> createState() => _InlineEntryFieldState();
}

class _InlineEntryFieldState extends State<InlineEntryField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialText));
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    if (widget.controller != null && widget.initialText != null) {
      widget.controller!.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  Future<void> _commit() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final taken = await widget.onCommit(value);
    if (!mounted || !taken || !widget.keepOpen) return;
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return TextField(
      controller: _controller,
      focusNode: _focus,
      autofocus: true,
      textCapitalization: widget.textCapitalization,
      textInputAction: TextInputAction.done,
      // Enter adds and, with keepOpen, the keyboard stays for the next one.
      onSubmitted: (_) => _commit(),
      onEditingComplete: widget.keepOpen ? () {} : null,
      style: FormTheme.getFieldTextStyle(context),
      decoration:
          FormTheme.getCardDecoration(
            fillColor: s.raisedSurface,
            borderColor: CardOutline.colorFor(theme.brightness),
            focusColor: s.primary,
            errorColor: s.error,
            hintText: widget.hintText,
          ).copyWith(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: widget.cancelTooltip,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: widget.onCancel,
                  ),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => FieldActionButton(
                      icon: Icons.check_rounded,
                      tooltip: widget.commitTooltip,
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : _commit,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
