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
    if (state.loadingImage) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(strokeWidth: 3),
      );
    }
    if (state.imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(state.imagePath!),
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      );
    }
    if (state.color != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(state.color!),
          shape: BoxShape.circle,
        ),
      );
    }
    return const Icon(Icons.palette_outlined, size: 48);
  }

  void _showPicker(BuildContext context) async {
    final state = context.read<GroupFormState>();
    final controller = context.read<GroupFormController>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _BackgroundSheet(
        state: state,
        controller: controller,
      ),
    );
  }
}

class _BackgroundSheet extends StatelessWidget {
  final GroupFormState state;
  final GroupFormController controller;
  const _BackgroundSheet({required this.state, required this.controller});

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
              final nav = Navigator.of(context); // capture before await
              final x = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (x != null) {
                final original = File(x.path);
                // Apri pagina di crop, ritorna file ritagliato (o null se annullato)
                final cropped = await nav.push<File?>(
                  MaterialPageRoute(
                    builder: (_) => ImageCropPage(imageFile: original),
                  ),
                );
                if (cropped != null) {
                  await controller.persistPickedImage(cropped);
                }
              }
              if (nav.mounted) nav.pop(); // chiudi sheet
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(loc.from_camera),
            onTap: () async {
              final nav = Navigator.of(context); // capture before await
              final x = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (x != null) {
                final original = File(x.path);
                final cropped = await nav.push<File?>(
                  MaterialPageRoute(
                    builder: (_) => ImageCropPage(imageFile: original),
                  ),
                );
                if (cropped != null) {
                  await controller.persistPickedImage(cropped);
                }
              }
              if (nav.mounted) nav.pop();
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
