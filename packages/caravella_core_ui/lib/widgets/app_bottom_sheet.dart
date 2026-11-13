import 'package:material_ui/material_ui.dart';

import '../themes/app_motion.dart';

/// Shows a modal bottom sheet with the app's sheet motion
/// ([AppMotion.sheet]), so every sheet glides in and out the same way. Use
/// it instead of [showModalBottomSheet] (a test keeps it that way).
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
}) => showModalBottomSheet<T>(
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
