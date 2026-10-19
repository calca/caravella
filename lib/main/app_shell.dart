import 'package:flutter/foundation.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Top-level destinations under the floating navigation.
enum AppTab { home, groups }

/// Root of the app below [MaterialApp]: Home and Groups as two tabs kept
/// alive (switched with a Material "fade through"), with a [FloatingNavBar]
/// floating over them.
///
/// Each tab registers its primary action (the round button next to the bar)
/// through [AppShellScope.of]: Home's is "new expense" in the featured group,
/// Groups' is "new group". A tab can also hide the bar (Home's welcome
/// screen). Pages pushed on top of the shell (group detail, settings…) cover
/// it entirely, so the bar only appears on the two tabs.
class AppShell extends StatefulWidget {
  final Widget home;
  final Widget groups;

  const AppShell({super.key, required this.home, required this.groups});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final ValueNotifier<AppTab> _tab = ValueNotifier(AppTab.home);
  final Map<AppTab, FloatingNavAction?> _actions = {};
  bool _navVisible = true;

  void _setAction(AppTab tab, FloatingNavAction? action) {
    if (_actions[tab] == action) return;
    _actions[tab] = action;
    if (mounted) setState(() {});
  }

  void _setNavVisible(bool visible) {
    if (_navVisible == visible) return;
    if (mounted) setState(() => _navVisible = visible);
  }

  void _select(AppTab tab) {
    if (_tab.value == tab) return;
    setState(() => _tab.value = tab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tab = _tab.value;
    // Both tabs use surfaceContainer as page color behind the bar.
    final pageColor = scheme.surfaceContainer;

    return AppShellScope._(
      tab: _tab,
      setAction: _setAction,
      setNavVisible: _setNavVisible,
      select: _select,
      // Back on Groups returns to Home instead of leaving the app.
      child: PopScope(
        canPop: tab == AppTab.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _select(AppTab.home);
        },
        child: Stack(
          children: [
            // Page color behind the tabs, so the fade through never shows
            // the black window between them.
            ColoredBox(
              color: pageColor,
              child: FadeThroughStack(
                index: tab.index,
                children: [widget.home, widget.groups],
              ),
            ),
            if (_navVisible) ...[
              // Content scrolling under the bar fades into the page instead
              // of showing half-hidden items behind it. Only as tall as the
              // bar, so at rest it doesn't wash the bottom of the Home card.
              Align(
                alignment: Alignment.bottomCenter,
                child: IgnorePointer(
                  child: Container(
                    height:
                        FloatingNavBar.reservedHeight +
                        MediaQuery.paddingOf(context).bottom,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          pageColor.withValues(alpha: 0),
                          pageColor.withValues(alpha: 0.92),
                        ],
                        stops: const [0, 0.45],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: FloatingNavBar(
                  selectedIndex: tab.index,
                  onSelected: (i) => _select(AppTab.values[i]),
                  items: [
                    FloatingNavItem(
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: gloc.nav_home,
                    ),
                    FloatingNavItem(
                      icon: Icons.folder_copy_outlined,
                      selectedIcon: Icons.folder_copy_rounded,
                      label: gloc.nav_groups,
                    ),
                  ],
                  action: _actions[tab],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lets the tabs of [AppShell] register their primary action, hide the bar
/// and react to tab changes. `maybeOf` returns null outside the shell (e.g.
/// the Groups page pushed from elsewhere), where pages keep their own FAB.
class AppShellScope extends InheritedWidget {
  final ValueNotifier<AppTab> _tab;
  final void Function(AppTab tab, FloatingNavAction? action) _setAction;
  final void Function(bool visible) _setNavVisible;
  final void Function(AppTab tab) _select;

  const AppShellScope._({
    required ValueNotifier<AppTab> tab,
    required void Function(AppTab, FloatingNavAction?) setAction,
    required void Function(bool) setNavVisible,
    required void Function(AppTab) select,
    required super.child,
  }) : _tab = tab,
       _setAction = setAction,
       _setNavVisible = setNavVisible,
       _select = select;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppShellScope>();

  /// The selected tab; listen to it to refresh a tab when it is shown.
  ValueListenable<AppTab> get tab => _tab;

  /// Sets (or clears, with null) the round button shown while [tab] is
  /// selected. Safe to call during build: applied after the frame.
  void setPrimaryAction(AppTab tab, FloatingNavAction? action) => WidgetsBinding
      .instance
      .addPostFrameCallback((_) => _setAction(tab, action));

  /// Shows or hides the whole bar. Safe to call during build.
  void setNavVisible(bool visible) => WidgetsBinding.instance
      .addPostFrameCallback((_) => _setNavVisible(visible));

  /// Switches to [tab] (e.g. "see all groups" from Home).
  void select(AppTab tab) => _select(tab);

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => false;
}

/// Like an [IndexedStack] — every child stays alive and keeps its state —
/// but switching child plays the Material "fade through": the old child
/// fades out in the first 35 %, then the new one fades in while scaling up
/// from 92 %. Instant when the platform asks to disable animations.
@visibleForTesting
class FadeThroughStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeThroughStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<FadeThroughStack> createState() => _FadeThroughStackState();
}

class _FadeThroughStackState extends State<FadeThroughStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );
  int? _previous;

  static const _outCurve = Interval(0, 0.35, curve: Curves.easeOut);
  static const _inCurve = Interval(0.35, 1, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(FadeThroughStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _previous = null;
      _controller.value = 1;
      return;
    }
    _previous = oldWidget.index;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _previous = null);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _layer(i, widget.children[i]),
      ],
    );
  }

  // Same wrapper chain for every child whatever its role, so switching
  // never rebuilds a child's subtree from scratch.
  Widget _layer(int i, Widget child) {
    final active = i == widget.index;
    final leaving = i == _previous;
    return TickerMode(
      enabled: active || leaving,
      child: Offstage(
        offstage: !active && !leaving,
        child: IgnorePointer(
          ignoring: !active,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final opacity = active
                  ? _inCurve.transform(t)
                  : leaving
                  ? 1 - _outCurve.transform(t)
                  : 0.0;
              final scale = active ? 0.92 + 0.08 * _inCurve.transform(t) : 1.0;
              return Opacity(
                opacity: opacity,
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
