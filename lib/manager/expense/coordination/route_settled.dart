import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Completes once the route around [context] has finished its entry
/// animation (after the current frame when there is none), so work that
/// moves the layout — opening the keyboard, filling in a location — doesn't
/// land while the sheet or page is still sliding in.
///
/// Completes as well if the route is dismissed before settling; check
/// `context.mounted` afterwards.
Future<void> routeSettled(BuildContext context) async {
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null || animation.isCompleted) return;

  final done = Completer<void>();
  void listener(AnimationStatus status) {
    if (status.isCompleted || status.isDismissed) {
      animation.removeStatusListener(listener);
      if (!done.isCompleted) done.complete();
    }
  }

  animation.addStatusListener(listener);
  return done.future;
}
