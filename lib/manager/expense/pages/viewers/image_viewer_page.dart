import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Standalone image viewer with pinch-to-zoom
class ImageViewerPage extends StatelessWidget {
  final String filePath;

  const ImageViewerPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(filePath),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget(context);
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            gen.AppLocalizations.of(context).attachment_open_error,
            style: AppTextStyles.mediaOverlayMessage,
          ),
        ],
      ),
    );
  }
}
