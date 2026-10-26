import 'dart:async';

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

/// The "Shared" pill of a synced group (Home card, group page header), with
/// a dot for how its sync is doing ([GroupSyncStatus]): filled green when it
/// synced in the last 24 hours, filled ochre when the last exchange failed
/// (the color of Home's sync button on failure), hollow grey when it hasn't
/// synced for a day or ever. With [onTap] (group page) it is a button
/// opening the group's sync page, with a chevron to say so.
class GroupSyncBadge extends StatefulWidget {
  final ExpenseGroup group;

  /// Pill background and text color (they follow the surface it sits on).
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  const GroupSyncBadge({
    super.key,
    required this.group,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  @override
  State<GroupSyncBadge> createState() => _GroupSyncBadgeState();
}

class _GroupSyncBadgeState extends State<GroupSyncBadge> {
  SyncOrchestrator? _orchestrator;
  StreamSubscription<SyncEvent>? _sub;
  GroupSyncStatus? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Null on the JSON backend or before sync has started (or without the
    // app's providers, in widget tests): no dot then.
    SyncOrchestrator? orchestrator;
    try {
      orchestrator = context.watch<SyncOrchestrator?>();
    } on ProviderNotFoundException {
      orchestrator = null;
    }
    if (identical(orchestrator, _orchestrator)) return;
    _sub?.cancel();
    _orchestrator = orchestrator;
    _sub = orchestrator?.events.listen((e) {
      if (e is SyncCompleted) _load();
    });
    _load();
  }

  @override
  void didUpdateWidget(GroupSyncBadge old) {
    super.didUpdateWidget(old);
    if (old.group.id != widget.group.id) _load();
  }

  Future<void> _load() async {
    final orchestrator = _orchestrator;
    if (orchestrator == null) return;
    final status = await orchestrator.getGroupSyncStatus(widget.group.id);
    if (mounted) setState(() => _status = status);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final fg = widget.foreground;
    final status = _status;
    final label = Text(
      gloc.sync_group_shared,
      style: theme.textTheme.labelSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
      ),
    );
    final dot = status == null
        ? null
        : Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: switch (status.health) {
              GroupSyncHealth.ok => BoxDecoration(
                shape: BoxShape.circle,
                color: s.success,
              ),
              GroupSyncHealth.failed => BoxDecoration(
                shape: BoxShape.circle,
                color: s.warning,
              ),
              GroupSyncHealth.stale => BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: fg.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            },
          );
    final semantics = [
      gloc.sync_group_shared,
      if (status != null)
        switch (status.health) {
          GroupSyncHealth.ok => gloc.sync_badge_ok,
          GroupSyncHealth.failed => gloc.sync_badge_failed,
          GroupSyncHealth.stale => gloc.sync_badge_stale,
        },
    ].join(', ');
    final radius = BorderRadius.circular(16);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?dot,
        label,
        if (widget.onTap != null)
          Icon(Icons.chevron_right_rounded, size: 16, color: fg),
      ],
    );

    if (widget.onTap == null) {
      return Semantics(
        label: semantics,
        excludeSemantics: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: radius,
          ),
          child: content,
        ),
      );
    }
    return Semantics(
      button: true,
      label: semantics,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: Material(
        color: widget.background,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
            child: content,
          ),
        ),
      ),
    );
  }
}
