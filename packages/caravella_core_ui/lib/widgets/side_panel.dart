import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../themes/app_motion.dart';

/// Shows [builder]'s content in a panel that slides in from the end side of
/// the window, full height — how [showAppBottomSheet] presents a sheet on
/// expanded windows (tablets in landscape, desktop browsers), where a sheet
/// rising from the bottom would be a wide, short strip far from the pointer.
///
/// The content is the same widget a bottom sheet would show: it gets a
/// [Material] in the sheet color, the panel's full height (it may stay
/// shorter: it is aligned to the top) and [SidePanelScope] so it can drop
/// what only makes sense at the bottom (a drag handle) and offer a close
/// button instead. Tapping outside, Esc and back close it like a sheet.
Future<T?> showSidePanel<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  Color? backgroundColor,
  bool useRootNavigator = false,
}) {
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: AppMotion.sheet.duration!,
    pageBuilder: (context, _, _) => _SidePanel(
      backgroundColor: backgroundColor,
      child: Builder(builder: builder),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.sheet.curve!,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween(
          begin: Offset(rtl ? -1 : 1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

class _SidePanel extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;

  const _SidePanel({required this.backgroundColor, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetTheme = theme.bottomSheetTheme;
    final color =
        backgroundColor ??
        sheetTheme.modalBackgroundColor ??
        sheetTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerLow;
    final width = math.min(
      SidePanelScope.width,
      MediaQuery.sizeOf(context).width,
    );
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: Material(
          color: color,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.horizontal(
              start: Radius.circular(28),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: SidePanelScope._(
            child: SafeArea(
              left: false,
              child: Align(alignment: Alignment.topCenter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Marks content shown by [showSidePanel], for widgets written for bottom
/// sheets (e.g. [CaravellaBottomSheetScaffold] hides its handle and shows a
/// close button).
class SidePanelScope extends InheritedWidget {
  /// The panel's width on expanded windows.
  static const double width = 440;

  const SidePanelScope._({required super.child});

  static bool isIn(BuildContext context) =>
      context.getInheritedWidgetOfExactType<SidePanelScope>() != null;

  @override
  bool updateShouldNotify(SidePanelScope oldWidget) => false;
}

/// The top of a sheet's content: the drag handle in a bottom sheet, a close
/// button in a side panel ([showSidePanel]), where dragging does nothing.
class SheetHandle extends StatelessWidget {
  /// Space around the handle (the close button keeps its own).
  final EdgeInsetsGeometry margin;

  const SheetHandle({
    super.key,
    this.margin = const EdgeInsets.only(top: 12, bottom: 4),
  });

  @override
  Widget build(BuildContext context) {
    if (SidePanelScope.isIn(context)) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(top: 8, end: 8),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: CloseButton(onPressed: () => Navigator.of(context).maybePop()),
        ),
      );
    }
    return Center(
      child: Container(
        width: 44,
        height: 4,
        margin: margin,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
