import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';

/// Coordinator for form scrolling logic
/// Manages GlobalKeys and calculates scroll positions to make fields visible
class FormScrollCoordinator {
  final ScrollController? _scrollController;
  final BuildContext _context;

  FormScrollCoordinator({
    required ScrollController? scrollController,
    required BuildContext context,
  }) : _scrollController = scrollController,
       _context = context;

  /// Scrolls so the whole field is visible: above the keyboard and above
  /// whatever sits under the scrolling area (the expense page's Save bar,
  /// which rises with the keyboard), and below the top. A tall field (the
  /// note, four lines at least) is shown from its top when it can't fit.
  /// Runs again once the keyboard has finished rising.
  void scrollToField(GlobalKey? fieldKey) {
    if (fieldKey == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(fieldKey));
    // The keyboard takes about 300 ms to rise: check again when it's up.
    _again?.cancel();
    _again = Timer(const Duration(milliseconds: 350), () => _reveal(fieldKey));
  }

  Timer? _again;

  /// The form is gone: no check pending.
  void dispose() => _again?.cancel();

  void _reveal(GlobalKey fieldKey) {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final ctx = fieldKey.currentContext;
    if (ctx == null || !_context.mounted) return;
    try {
      final field = ctx.findRenderObject() as RenderBox?;
      final scrollable = Scrollable.maybeOf(ctx);
      final viewport = scrollable?.context.findRenderObject() as RenderBox?;
      if (field == null || !field.attached || viewport == null) return;

      // The visible part of the scrolling area, on screen.
      final viewTop = viewport.localToGlobal(Offset.zero).dy;
      final keyboardTop =
          MediaQuery.sizeOf(_context).height -
          MediaQuery.viewInsetsOf(_context).bottom;
      final viewBottom = math.min(viewTop + viewport.size.height, keyboardTop);
      const margin = 12.0;
      final top = field.localToGlobal(Offset.zero).dy;
      final bottom = top + field.size.height;

      double delta = 0;
      if (bottom > viewBottom - margin) delta = bottom - (viewBottom - margin);
      // Never past its top: a field taller than the room shows its start.
      if (top - delta < viewTop + margin) delta = top - (viewTop + margin);
      if (delta.abs() < 2) return;

      final target = (controller.offset + delta).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      if ((target - controller.offset).abs() > 2) {
        controller.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      LoggerService.warning('Scroll adjust error: $e', name: 'ui.scroll');
    }
  }

  /// Determines which field currently has focus and scrolls to it
  void scrollToFocusedField(Map<FocusNode, GlobalKey> focusKeyMap) {
    GlobalKey? focusedKey;

    for (final entry in focusKeyMap.entries) {
      if (entry.key.hasFocus) {
        focusedKey = entry.value;
        break;
      }
    }

    if (focusedKey != null) {
      scrollToField(focusedKey);
    }
  }

  /// Checks if a context contains the given focus node
  static bool contextContainsFocus(BuildContext context, FocusNode focus) {
    try {
      void visitor(Element element) {
        final widget = element.widget;
        if (widget is Focus && widget.focusNode == focus) {
          throw true; // Found it, break traversal
        }
        element.visitChildren(visitor);
      }

      context.visitChildElements(visitor);
      return false;
    } catch (e) {
      return e == true;
    }
  }
}
