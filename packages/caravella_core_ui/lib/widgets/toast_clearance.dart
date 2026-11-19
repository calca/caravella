import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

/// Marks something at the bottom of a page that toasts must not cover —
/// the floating navigation, a "+" button, a Save bar — so [AppToast]s
/// rise just above it.
///
/// It measures where its child actually is: [bottom] is the distance from
/// the child's top edge to the bottom of the screen, the highest among the
/// marked widgets of the page on top. Pages under another one, and widgets
/// moved off screen (a hidden "+"), don't count, so on a page with nothing
/// marked toasts sit near the bottom of the screen.
///
/// [FloatingNavBar] and [AddFab] mark themselves; wrap any other bottom
/// bar in one.
class ToastClearance extends StatefulWidget {
  final Widget child;

  const ToastClearance({super.key, required this.child});

  static final ValueNotifier<double> _bottom = ValueNotifier(0);
  static final Map<Object, double> _heights = {};
  static bool _scheduled = false;

  /// Space toasts leave at the bottom of the screen, in logical pixels.
  static ValueListenable<double> get bottom => _bottom;

  static void _report(Object owner, double? height) {
    final changed = height == null || height <= 0
        ? _heights.remove(owner) != null
        : _heights[owner] != height;
    if (height != null && height > 0) _heights[owner] = height;
    if (!changed || _scheduled) return;
    // Reported while painting: publish once the frame is done.
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _bottom.value = _heights.values.fold(0.0, (a, b) => a > b ? a : b);
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  State<ToastClearance> createState() => _ToastClearanceState();
}

class _ToastClearanceState extends State<ToastClearance> {
  bool _current = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rebuilt when a page is pushed over this one or popped back to it.
    _current = ModalRoute.isCurrentOf(context) ?? true;
    if (!_current) ToastClearance._report(this, null);
  }

  @override
  void dispose() {
    ToastClearance._report(this, null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Measure(
    onPaint: (top) {
      if (!_current) return ToastClearance._report(this, null);
      final screen = MediaQuery.sizeOf(context).height;
      ToastClearance._report(this, top == null ? null : screen - top);
    },
    child: widget.child,
  );
}

/// Reports, each time it paints, where its top edge is on screen.
class _Measure extends SingleChildRenderObjectWidget {
  final void Function(double? top) onPaint;

  const _Measure({required this.onPaint, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasure(onPaint);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasure renderObject) {
    renderObject.onPaint = onPaint;
    // Report again, e.g. when the page comes back on top.
    renderObject.markNeedsPaint();
  }
}

class _RenderMeasure extends RenderProxyBox {
  void Function(double? top) onPaint;

  _RenderMeasure(this.onPaint);

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    // localToGlobal includes slides and other paint transforms, so a "+"
    // sliding away stops counting.
    onPaint(hasSize ? localToGlobal(Offset.zero).dy : null);
  }
}
