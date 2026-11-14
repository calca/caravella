import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'app_bottom_sheet.dart';
import 'caravella_bottom_sheet_scaffold.dart';
import 'round_back_button.dart';

/// Second screens inside one modal sheet, so a sheet never opens another
/// sheet on top of it (nor closes to let another one rise).
///
/// Wrap a sheet's content in it; inside, [showSheetPage] slides a page in
/// from the side, in the same sheet, with a back button and its title; the
/// sheet follows its height. Back (the button, the system gesture or
/// [closeSheetPage]) slides the previous content back, which kept its state
/// (a typed rate, a chosen option) while hidden.
class SheetPager extends StatefulWidget {
  final Widget child;

  const SheetPager({super.key, required this.child});

  static SheetPagerState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<SheetPagerState>();

  @override
  State<SheetPager> createState() => SheetPagerState();
}

class _SheetPageEntry {
  final String title;
  final WidgetBuilder builder;
  final Completer<Object?> result = Completer<Object?>();

  _SheetPageEntry(this.title, this.builder);
}

class SheetPagerState extends State<SheetPager>
    with SingleTickerProviderStateMixin {
  static const Duration slide = Duration(milliseconds: 280);
  static const Duration resize = Duration(milliseconds: 240);

  final List<_SheetPageEntry> _pages = [];
  late final AnimationController _arrive = AnimationController(
    vsync: this,
    duration: slide,
    value: 1,
  );

  /// Where the arriving content starts: from the right on push, a little
  /// from the left on back.
  Offset _from = const Offset(1, 0);

  int get depth => _pages.length;

  @override
  void dispose() {
    _arrive.dispose();
    for (final p in _pages) {
      if (!p.result.isCompleted) p.result.complete(null);
    }
    super.dispose();
  }

  Future<T?> push<T>({required String title, required WidgetBuilder builder}) {
    final entry = _SheetPageEntry(title, builder);
    setState(() {
      _pages.add(entry);
      _from = const Offset(1, 0);
    });
    _arrive.forward(from: 0);
    return entry.result.future.then((v) => v as T?);
  }

  void pop([Object? result]) {
    if (_pages.isEmpty) return;
    final entry = _pages.last;
    setState(() {
      _pages.removeLast();
      _from = const Offset(-0.25, 0);
    });
    _arrive.forward(from: 0);
    if (!entry.result.isCompleted) entry.result.complete(result);
  }

  Widget _layer(Widget child, bool top) {
    final curve = CurvedAnimation(parent: _arrive, curve: Curves.easeOutCubic);
    return Offstage(
      offstage: !top,
      child: TickerMode(
        enabled: top,
        child: SlideTransition(
          position: top
              ? Tween(begin: _from, end: Offset.zero).animate(curve)
              : const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity: top ? curve : const AlwaysStoppedAnimation(1),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _pages.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) pop();
      },
      child: ClipRect(
        child: AnimatedSize(
          duration: resize,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              _layer(widget.child, _pages.isEmpty),
              for (var i = 0; i < _pages.length; i++)
                _layer(
                  _SheetPageFrame(
                    // Keyed by position, so a page keeps its state while
                    // another is on top of it.
                    key: ValueKey(i),
                    title: _pages[i].title,
                    onBack: pop,
                    child: Builder(builder: _pages[i].builder),
                  ),
                  i == _pages.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetPageFrame extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget child;

  const _SheetPageFrame({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Above the keyboard, as [CaravellaBottomSheetScaffold] is.
    return Padding(
      // The sheets' grid: back button and cards at 16.
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              RoundBackButton(onPressed: onBack),
              const SizedBox(width: 12),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SheetPageScope(child: child),
        ],
      ),
    );
  }
}

/// Marks content opened by [showSheetPage], which already shows its title.
class _SheetPageScope extends InheritedWidget {
  const _SheetPageScope({required super.child});

  @override
  bool updateShouldNotify(_SheetPageScope oldWidget) => false;
}

/// Whether [context] is inside a page [showSheetPage] opened (its title is
/// shown above it), so the content leaves out its own sheet title.
bool isSheetPage(BuildContext context) =>
    context.getInheritedWidgetOfExactType<_SheetPageScope>() != null;

/// Opens [builder] as a second screen of the sheet around [context] (see
/// [SheetPager]); outside a sheet, as a sheet of its own. The page returns
/// its result with [closeSheetPage].
Future<T?> showSheetPage<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  final pager = SheetPager.maybeOf(context);
  if (pager != null) return pager.push<T>(title: title, builder: builder);
  return showAppBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => CaravellaBottomSheetScaffold(
      title: title,
      child: _SheetPageScope(child: Builder(builder: builder)),
    ),
  );
}

/// Closes the page [showSheetPage] opened, with [result].
void closeSheetPage<T>(BuildContext context, [T? result]) {
  final pager = SheetPager.maybeOf(context);
  if (pager != null && pager.depth > 0) {
    pager.pop(result);
  } else {
    Navigator.of(context).pop(result);
  }
}
