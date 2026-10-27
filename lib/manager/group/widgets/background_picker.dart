import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/unsplash/unsplash_service.dart';
import '../data/group_form_state.dart';
import '../group_form_controller.dart';
import '../pages/unsplash_search_page.dart';
import 'background_color_sheet.dart';
import 'crop_page_wrapper.dart';

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
            padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
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
                // Explicit color: on this page the icon otherwise rendered
                // with Flutter's fallback icon color (near-black) in the dark
                // theme (#527).
                Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _preview(GroupFormState state) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
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
              // Decode a thumbnail, not the whole photo.
              cacheWidth: 180,
              // The photo file may be gone (deleted, restored backup):
              // show a placeholder instead of Flutter's error box.
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: scheme.onSurface.withValues(alpha: 0.06),
                child: Icon(
                  Icons.broken_image_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        } else if (state.color != null) {
          // Resolve color from palette index or use legacy color value
          Color displayColor;
          if (ExpenseGroupColorPalette.isLegacyColorValue(state.color)) {
            // Legacy ARGB value - use as-is
            displayColor = Color(state.color!);
          } else {
            // New palette index - resolve to theme-aware color
            displayColor =
                ExpenseGroupColorPalette.resolveColor(state.color, scheme) ??
                scheme.primary;
          }
          child = Container(
            key: ValueKey(state.color),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: displayColor,
              shape: BoxShape.circle,
            ),
          );
        } else {
          child = Icon(
            Icons.palette_outlined,
            size: 48,
            color: scheme.onSurfaceVariant,
            key: const ValueKey('icon'),
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
      },
    );
  }

  void _showPicker(BuildContext context) => showBackgroundPickerSheet(context);
}

/// Opens the background sheet (gallery, camera, Unsplash, color, remove) for
/// the [GroupFormState] above [context]; also used by the group settings'
/// avatar shortcut.
void showBackgroundPickerSheet(BuildContext context) {
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
    final imagePicker = picker.ImagePicker();
    final tiles = [
      SettingsTile(
        icon: Icons.photo_library_outlined,
        title: loc.from_gallery,
        chevron: false,
        onTap: () async {
          final sheetNav = Navigator.of(context); // navigator della sheet
          // Chiudi SUBITO la sheet per migliorare UX
          if (sheetNav.mounted) sheetNav.pop();
          // Usa il navigator del parent
          final parentNav = Navigator.of(parentContext);
          final x = await imagePicker.pickImage(
            source: picker.ImageSource.gallery,
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
                builder: (_) => CropPageWrapper(
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
      SettingsTile(
        icon: Icons.photo_camera_outlined,
        title: loc.from_camera,
        chevron: false,
        onTap: () async {
          final sheetNav = Navigator.of(context);
          if (sheetNav.mounted) sheetNav.pop();
          final parentNav = Navigator.of(parentContext);
          final x = await imagePicker.pickImage(
            source: picker.ImageSource.camera,
            imageQuality: 85,
            preferredCameraDevice: picker.CameraDevice.rear,
          );
          if (x != null) {
            final original = File(x.path);
            state.setLoading(true);
            await Future.delayed(const Duration(milliseconds: 120));
            final cropped = await parentNav.push<File?>(
              MaterialPageRoute(
                builder: (_) => CropPageWrapper(
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
      if (UnsplashService.isAvailable)
        SettingsTile(
          icon: Icons.image_search_outlined,
          title: loc.from_unsplash,
          chevron: false,
          onTap: () async {
            final sheetNav = Navigator.of(context);
            if (sheetNav.mounted) sheetNav.pop();
            final parentNav = Navigator.of(parentContext);
            final downloaded = await UnsplashSearchPage.show(
              parentContext,
              initialQuery: state.title.trim().isNotEmpty
                  ? state.title.trim()
                  : null,
            );
            if (downloaded != null) {
              state.setLoading(true);
              await Future.delayed(const Duration(milliseconds: 120));
              final cropped = await parentNav.push<File?>(
                MaterialPageRoute(
                  builder: (_) => CropPageWrapper(
                    image: downloaded,
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
      SettingsTile(
        icon: Icons.color_lens_outlined,
        title: loc.color,
        chevron: false,
        onTap: () {
          final sheetNav = Navigator.of(context);
          if (sheetNav.mounted) sheetNav.pop();
          showModalBottomSheet(
            context: parentContext,
            builder: (_) => ColorSheet(state: state),
          );
        },
      ),
    ];
    final remove = [
      if (state.imagePath != null || state.color != null)
        SettingsTile(
          icon: Icons.hide_image_outlined,
          destructive: true,
          title: loc.background_remove,
          chevron: false,
          onTap: () async {
            // Capture the sheet navigator before the async gap to avoid
            // using BuildContext across await (use_build_context_synchronously).
            final sheetNav = Navigator.of(context);
            // Use controller to remove background (image file and/or color)
            try {
              await controller.removeImage();
            } catch (_) {
              // ignore errors here; controller handles logging
            }
            if (sheetNav.mounted) sheetNav.pop();
          },
        ),
    ];
    return CaravellaBottomSheetScaffold(
      title: loc.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(topSpacing: 0, children: tiles),
          if (remove.isNotEmpty)
            SettingsGroup(topSpacing: 12, children: remove),
        ],
      ),
    );
  }
}
