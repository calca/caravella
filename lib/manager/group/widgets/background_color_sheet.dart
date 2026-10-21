import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../data/group_form_state.dart';

/// Bottom sheet for picking a suggested (or random) background color,
/// opened from [BackgroundPicker]'s main sheet.
class ColorSheet extends StatelessWidget {
  final GroupFormState state;
  const ColorSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);
    Widget card(Widget child) => CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
    return CaravellaBottomSheetScaffold(
      title: loc.color_suggested_title,
      subtitle: loc.color_suggested_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          card(
            Builder(
              builder: (ctx) {
                final scheme = Theme.of(ctx).colorScheme;
                final palette = ExpenseGroupColorPalette.getPaletteColors(
                  scheme,
                );
                final firstRow = palette.take(6).toList();
                final secondRow = palette.skip(6).take(6).toList();
                return Column(
                  children: [
                    _ColorPaletteRow(
                      state: state,
                      colors: firstRow,
                      startIndex: 0,
                    ),
                    const SizedBox(height: 14),
                    _ColorPaletteRow(
                      state: state,
                      colors: secondRow,
                      startIndex: 6,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          card(
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.background_random_color,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.color_random_subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _RandomColorButton(
                  state: state,
                  semanticLabel: loc.background_random_color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPaletteRow extends StatelessWidget {
  final GroupFormState state;
  final List<Color> colors;
  final int startIndex; // Index offset for this row
  const _ColorPaletteRow({
    required this.state,
    required this.colors,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(colors.length, (i) {
        final c = colors[i];
        final colorIndex = startIndex + i;
        final selected = state.color == colorIndex;
        return InkWell(
          onTap: () {
            state.setColor(colorIndex);
            Navigator.pop(context); // chiudi subito la sheet dopo selezione
          },
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.9)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                width: selected ? 3 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? Icon(Icons.check, color: scheme.onPrimary, size: 22)
                : null,
          ),
        );
      }),
    );
  }
}

class _RandomColorButton extends StatefulWidget {
  final GroupFormState state;
  final String semanticLabel;
  const _RandomColorButton({required this.state, required this.semanticLabel});

  @override
  State<_RandomColorButton> createState() => _RandomColorButtonState();
}

class _RandomColorButtonState extends State<_RandomColorButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _spin;
  late final Animation<double> _scale;
  bool _animating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _spin = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _roll() async {
    if (_animating) return;
    setState(() => _animating = true);
    _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 320));
    // Pick a random palette index
    final randomIndex =
        (DateTime.now().microsecondsSinceEpoch) %
        ExpenseGroupColorPalette.paletteSize;
    widget.state.setColor(randomIndex);
    await _controller.forward();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final button = IconButton.filled(
      onPressed: _roll,
      tooltip: widget.semanticLabel,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _spin.value,
            child: Transform.scale(scale: _scale.value, child: child),
          );
        },
        child: const Icon(Icons.colorize_outlined),
      ),
    );
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: _animating ? ExcludeSemantics(child: button) : button,
    );
  }
}
