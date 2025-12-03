import 'package:flutter/material.dart';

/// Mixin for widgets that need keyboard-aware scroll behavior
/// Automatically adjusts scroll position when keyboard appears/disappears
mixin KeyboardAwareScrollMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  double _lastKeyboardHeight = 0;

  /// Override this to provide the scroll controller
  ScrollController? get scrollController;

  /// Override this to handle scroll to focused field
  void scrollToFocusedField();

  /// Override this to check if any field has focus
  bool get hasAnyFieldFocused;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Monitor keyboard height changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (currentKeyboardHeight != _lastKeyboardHeight) {
        _lastKeyboardHeight = currentKeyboardHeight;

        // If keyboard is opening and a field has focus, trigger scroll
        if (currentKeyboardHeight > 0 && hasAnyFieldFocused) {
          scrollToFocusedField();
        }
      }
    });
  }
}
