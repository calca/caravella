import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../group_form_state.dart';
import '../group_form_controller.dart';
import '../../image_crop_page.dart';
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
        Row(
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
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showPicker(context),
            ),
          ],
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
      child = const Icon(Icons.palette_outlined, size: 48, key: ValueKey('icon'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutQuad,
      switchOutCurve: Curves.easeInQuad,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1).animate(anim), child: c),
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
  const _BackgroundSheet({required this.state, required this.controller, required this.parentContext});

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
            title: Text(loc.background_random_color),
            onTap: () {
              final color =
                  Colors.primaries[(DateTime.now().millisecondsSinceEpoch) %
                      Colors.primaries.length];
              state.setColor(color.toARGB32());
              Navigator.pop(context);
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
