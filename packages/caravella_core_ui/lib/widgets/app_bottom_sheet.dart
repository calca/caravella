import 'package:material_ui/material_ui.dart';

import '../layout/window_size.dart';
import '../themes/app_motion.dart';
import 'side_panel.dart';

/// Shows a modal bottom sheet with the app's sheet motion
/// ([AppMotion.sheet]), so every sheet glides in and out the same way. Use
/// it instead of [showModalBottomSheet] (a test keeps it that way).
///
/// On expanded windows (840 dp and more) the same content opens in a
/// [showSidePanel] at the end side instead; the sheet-only options (drag,
/// handle, shape, scroll control) don't apply there.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = false,
  bool? showDragHandle,
  ShapeBorder? shape,
  double? elevation,
  Color? backgroundColor,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
}) => WindowSize.of(context) == WindowSize.expanded
    ? showSidePanel<T>(
        context: context,
        builder: builder,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        useRootNavigator: useRootNavigator,
      )
    : showModalBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: isScrollControlled,
        useSafeArea: useSafeArea,
        showDragHandle: showDragHandle,
        shape: shape,
        elevation: elevation,
        backgroundColor: backgroundColor,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useRootNavigator: useRootNavigator,
        sheetAnimationStyle: AppMotion.sheet,
      );
