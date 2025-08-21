import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../pages/image_crop_page.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class BackgroundPicker extends StatelessWidget {
  const BackgroundPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
    final loc = gen.AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _showPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                _preview(state),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.imagePath != null
                            ? loc.change_image
                            : state.color != null
                            ? loc.background_color_selected
                            : loc.background,
                      ),
                      Text(
                        state.imagePath != null
                            ? loc.background_tap_to_replace
                            : state.color != null
                            ? loc.background_tap_to_change
                            : loc.background_select_image_or_color,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _preview(GroupFormState state) {
    Widget child;
    if (state.loadingImage) {
      child = const SizedBox(
        key: ValueKey('loading'),
        width: 48,
        height: 48,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    } else if (state.imagePath != null) {
      child = ClipRRect(
        key: ValueKey(state.imagePath),
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(state.imagePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    } else if (state.color != null) {
      child = Container(
        key: ValueKey(state.color),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(state.color!),
          shape: BoxShape.circle,
        ),
      );
    } else {
      child = const Icon(
        Icons.palette_outlined,
        size: 48,
        key: ValueKey('icon'),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutQuad,
      switchOutCurve: Curves.easeInQuad,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(anim),
          child: c,
        ),
      ),
      child: child,
    );
  }

  void _showPicker(BuildContext context) async {
    final state = context.read<GroupFormState>();
    final controller = context.read<GroupFormController>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _BackgroundSheet(
        state: state,
        controller: controller,
        parentContext: context,
      ),
    );
  }
}

class _BackgroundSheet extends StatelessWidget {
  final GroupFormState state;
  final GroupFormController controller;
  final BuildContext parentContext; // per navigazione dopo chiusura sheet
  const _BackgroundSheet({
    required this.state,
    required this.controller,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final picker = ImagePicker();
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(loc.from_gallery),
            onTap: () async {
              final sheetNav = Navigator.of(context); // navigator della sheet
              // Chiudi SUBITO la sheet per migliorare UX
              if (sheetNav.mounted) sheetNav.pop();
              // Usa il navigator del parent
              final parentNav = Navigator.of(parentContext);
              final x = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (x != null) {
                final original = File(x.path);
                // Mostra loader mentre si prepara la pagina di crop
                state.setLoading(true);
                // Attendi un frame (e un piccolo delay) per permettere al loader di apparire prima del push
                await Future.delayed(const Duration(milliseconds: 120));
                final cropped = await parentNav.push<File?>(
                  MaterialPageRoute(
                    builder: (_) => _CropPageWrapper(
                      image: original,
                      onFirstFrame: () => state.setLoading(false),
                    ),
                  ),
                );
                if (cropped != null) {
                  await controller.persistPickedImage(cropped);
                  return;
                }
                // Se annullato assicura che il loader sia nascosto
                state.setLoading(false);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(loc.from_camera),
            onTap: () async {
              final sheetNav = Navigator.of(context);
              if (sheetNav.mounted) sheetNav.pop();
              final parentNav = Navigator.of(parentContext);
              final x = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (x != null) {
                final original = File(x.path);
                state.setLoading(true);
                await Future.delayed(const Duration(milliseconds: 120));
                final cropped = await parentNav.push<File?>(
                  MaterialPageRoute(
                    builder: (_) => _CropPageWrapper(
                      image: original,
                      onFirstFrame: () => state.setLoading(false),
                    ),
                  ),
                );
                if (cropped != null) {
                  await controller.persistPickedImage(cropped);
                  return;
                }
                state.setLoading(false);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(loc.color),
            onTap: () {
              final sheetNav = Navigator.of(context);
              if (sheetNav.mounted) sheetNav.pop();
              showModalBottomSheet(
                context: parentContext,
                builder: (_) => _ColorSheet(state: state),
              );
            },
          ),
          if (state.imagePath != null || state.color != null)
            ListTile(
              leading: const Icon(Icons.clear),
              title: Text(loc.background_remove),
              onTap: () {
                state.setImage(null);
                state.setColor(null);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

/// Wrapper per mostrare loader finché la pagina di crop non ha renderizzato il primo frame.
class _CropPageWrapper extends StatefulWidget {
  final File image;
  final VoidCallback onFirstFrame;
  const _CropPageWrapper({required this.image, required this.onFirstFrame});

  @override
  State<_CropPageWrapper> createState() => _CropPageWrapperState();
}

class _CropPageWrapperState extends State<_CropPageWrapper> {
  bool _firstFrame = false;

  @override
  void initState() {
    super.initState();
    // Programma callback dopo primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFirstFrame();
        setState(() => _firstFrame = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageCropPage(imageFile: widget.image),
        if (!_firstFrame)
          const ColoredBox(
            color: Colors.black26,
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorPaletteRow extends StatelessWidget {
  final GroupFormState state;
  final List<Color> colors;
  const _ColorPaletteRow({required this.state, required this.colors});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors.map((c) {
        final selected = state.color == c.toARGB32();
        return InkWell(
          onTap: () {
            state.setColor(c.toARGB32());
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
      }).toList(),
    );
  }
}

class _ColorSheet extends StatelessWidget {
  final GroupFormState state;
  const _ColorSheet({required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.color_suggested_title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              loc.color_suggested_subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            // 12 colori su due righe
            Builder(
              builder: (ctx) {
                final scheme = Theme.of(ctx).colorScheme;
                final List<Color> palette = [
                  scheme.primary,
                  scheme.tertiary,
                  scheme.secondary,
                  scheme.errorContainer.withValues(alpha: 0.85),
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
                  scheme.primaryFixedDim,
                  scheme.secondaryFixedDim,
                  scheme.tertiaryFixed,
                  scheme.error,
                  scheme.outlineVariant,
                  scheme.inversePrimary,
                ];
                final firstRow = palette.take(6).toList();
                final secondRow = palette.skip(6).take(6).toList();
                return Column(
                  children: [
                    _ColorPaletteRow(state: state, colors: firstRow),
                    const SizedBox(height: 14),
                    _ColorPaletteRow(state: state, colors: secondRow),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              loc.background_random_color,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    loc.color_random_subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                _RandomColorButton(
                  state: state,
                  semanticLabel: loc.background_random_color,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
    final color =
        Colors.primaries[(DateTime.now().microsecondsSinceEpoch) %
            Colors.primaries.length];
    widget.state.setColor(color.toARGB32());
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
