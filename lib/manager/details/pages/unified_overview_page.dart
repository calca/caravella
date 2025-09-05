import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../data/model/expense_group.dart';
import '../tabs/unified_overview_tab.dart';
import '../../group/widgets/section_header.dart';

/// Full screen page replacement for the previous bottom sheet overview/statistics.
/// Adds a swipe-down gesture to dismiss (mimics modal sheet UX).
class UnifiedOverviewPage extends StatefulWidget {
  final ExpenseGroup trip;
  const UnifiedOverviewPage({super.key, required this.trip});

  @override
  State<UnifiedOverviewPage> createState() => _UnifiedOverviewPageState();
}

class _UnifiedOverviewPageState extends State<UnifiedOverviewPage>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0; // current vertical drag translation
  // Base threshold (will be adjusted proportionally to screen height)
  static const double _baseDismissThreshold = 140.0;
  double _effectiveThreshold = 140.0;
  late final AnimationController _reboundCtrl;
  late Animation<double> _reboundAnim;
  bool _hapticSent = false;

  @override
  void initState() {
    super.initState();
    _reboundCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _reboundAnim = CurvedAnimation(parent: _reboundCtrl, curve: Curves.easeOut);
    _reboundCtrl.addListener(() {
      if (mounted) {
        setState(() {
          // animate back to 0 using controller value
          _dragOffset = _dragOffset * (1 - _reboundAnim.value);
        });
      }
    });
    _reboundCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dragOffset = 0.0; // snap exactly
      }
    });
  }

  @override
  void dispose() {
    _reboundCtrl.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy > 0) {
      setState(() {
        _dragOffset += d.delta.dy;
      });
    } else if (_dragOffset > 0 && d.delta.dy < 0) {
      // allow slight upward correction
      setState(() {
        _dragOffset = (_dragOffset + d.delta.dy).clamp(0.0, 1000.0);
      });
    }

    if (!_hapticSent && _dragOffset > _effectiveThreshold) {
      _hapticSent = true;
      HapticFeedback.lightImpact();
    } else if (_hapticSent && _dragOffset < _effectiveThreshold * 0.6) {
      // reset if user moves back up significantly
      _hapticSent = false;
    }
  }

  void _handleDragEnd(DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dy;
    final shouldDismiss = _dragOffset > _effectiveThreshold || velocity > 900;
    if (shouldDismiss) {
      Navigator.of(context).maybePop();
    } else {
      // animate back
      _reboundCtrl.reset();
      _reboundCtrl.forward();
      _hapticSent = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    // Adjust threshold to 18% of screen height but not below base
    _effectiveThreshold = (media.size.height * 0.18).clamp(
      _baseDismissThreshold,
      420.0,
    );
    final closeTooltip = MaterialLocalizations.of(context).closeButtonTooltip;
    return GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: closeTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          body: Column(
            children: [
              // Handle area (improves discoverability + larger drag target)
              Semantics(
                label: gloc.overview,
                hint: closeTooltip,
                container: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: _handleDragUpdate,
                  onVerticalDragEnd: _handleDragEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        curve: Curves.easeOut,
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.outlineVariant
                              .withValues(
                                alpha:
                                    ((_dragOffset / _effectiveThreshold).clamp(
                                                  0,
                                                  1,
                                                ) *
                                                0.9 +
                                            0.1)
                                        .clamp(0.0, 1.0),
                              ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SectionHeader(
                  title: widget.trip.title,
                  description: gloc.overview,
                  padding: EdgeInsets.zero,
                ),
              ),
              Expanded(child: UnifiedOverviewTab(trip: widget.trip)),
            ],
          ),
        ),
      ),
    );
  }
}
