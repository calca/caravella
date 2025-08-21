import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../group_form_state.dart';
import '../group_form_controller.dart';

class BackgroundPicker extends StatelessWidget {
  const BackgroundPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFormState>();
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
                        ? 'Cambia immagine'
                        : state.color != null
                        ? 'Colore selezionato'
                        : 'Sfondo',
                  ),
                  Text(
                    state.imagePath != null
                        ? 'Tap per sostituire'
                        : state.color != null
                        ? 'Tap per cambiare'
                        : 'Seleziona immagine o colore',
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
    showModalBottomSheet(context: context, builder: (ctx) => const _Sheet());
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    final state = context.read<GroupFormState>();
    final controller = context.read<GroupFormController>();
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galleria'),
            onTap: () async {
              final x = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (x != null) {
                await controller.persistPickedImage(File(x.path));
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Fotocamera'),
            onTap: () async {
              final x = await picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 85,
              );
              if (x != null) {
                await controller.persistPickedImage(File(x.path));
              }
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Colore casuale'),
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
              title: const Text('Rimuovi sfondo'),
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
