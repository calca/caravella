import 'dart:io';
import 'package:material_ui/material_ui.dart';
import '../pages/image_crop_page.dart';

/// Shows a loader until the crop page has drawn its first frame.
class CropPageWrapper extends StatefulWidget {
  final File image;
  final VoidCallback onFirstFrame;
  const CropPageWrapper({
    super.key,
    required this.image,
    required this.onFirstFrame,
  });

  @override
  State<CropPageWrapper> createState() => _CropPageWrapperState();
}

class _CropPageWrapperState extends State<CropPageWrapper> {
  bool _firstFrame = false;

  @override
  void initState() {
    super.initState();
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
