import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../navigation_helpers.dart';
import '../../../manager/history/expenses_history_page.dart';

class EmptyGroupsState extends StatefulWidget {
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onGroupAdded;
  final bool allArchived;

  const EmptyGroupsState({
    super.key,
    required this.localizations,
    required this.theme,
    required this.onGroupAdded,
    this.allArchived = false,
  });

  @override
  State<EmptyGroupsState> createState() => _EmptyGroupsStateState();
}

class _EmptyGroupsStateState extends State<EmptyGroupsState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Staggered animations with smooth curves
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _titleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    _subtitleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Render the welcome logo in greyscale with muted opacity
          FadeTransition(
            opacity: _logoAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(_logoAnimation),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0.2126,
                  0.7152,
                  0.0722,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: Opacity(
                  opacity: 0.6,
                  child: Image.asset(
                    'assets/images/home/welcome/welcome-logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                    semanticLabel: widget.localizations.welcome_logo_semantic,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _titleAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_titleAnimation),
              child: Text(
                widget.localizations.no_active_groups,
                style: widget.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _subtitleAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_subtitleAnimation),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  widget.localizations.no_active_groups_subtitle,
                  style: widget.theme.textTheme.bodyLarge?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (widget.allArchived) ...[
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _subtitleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  widget.localizations.all_groups_archived_info,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _buttonAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(_buttonAnimation),
              child: FilledButton.icon(
                onPressed: () async {
                  final groupId = await NavigationHelpers.openGroupCreation(
                    context,
                  );
                  if (groupId != null) {
                    widget.onGroupAdded();
                  }
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(widget.localizations.create_first_group),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          if (widget.allArchived) ...[
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _buttonAnimation,
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).animate(_buttonAnimation),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ExpesensHistoryPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_rounded),
                  label: Text(widget.localizations.history),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
