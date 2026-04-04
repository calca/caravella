import 'package:flutter/material.dart';
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

  /// Scrolls to make the specified field key visible
  /// Takes into account keyboard height and desired margins
  void scrollToField(GlobalKey? fieldKey) {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients || fieldKey == null) {
      return;
    }

    // Delay to allow layout & keyboard metrics update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;

      final ctx = fieldKey.currentContext;
      if (ctx == null) return;

      try {
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final keyboardHeight = MediaQuery.of(_context).viewInsets.bottom;
        final fieldTop = renderBox.localToGlobal(Offset.zero).dy;
        final fieldHeight = renderBox.size.height;
        final fieldBottom = fieldTop + fieldHeight;
        final screenHeight = MediaQuery.of(_context).size.height;
        final availableBottom = screenHeight - keyboardHeight - 12;

        double scrollDelta = 0;

        // If bottom obscured by keyboard -> scroll down
        if (keyboardHeight > 0 && fieldBottom > availableBottom) {
          scrollDelta = fieldBottom - availableBottom + 8;
        }

        // If top too high -> scroll up
        const topMargin = 24.0;
        if (fieldTop < topMargin) {
          scrollDelta = fieldTop - topMargin;
        }

        if (scrollDelta.abs() > 4) {
          final target = (controller.offset + scrollDelta).clamp(
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
        }
      } catch (e) {
        LoggerService.warning('Scroll adjust error', name: 'ui.scroll');
      }
    });
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
