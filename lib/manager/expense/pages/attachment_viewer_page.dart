import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:path/path.dart' as path;
import 'viewers/attachment_viewer_controller.dart';
import 'viewers/pdf_viewer_page.dart';
import 'viewers/video_player_page.dart';
import 'viewers/image_viewer_page.dart';

class AttachmentViewerPage extends StatefulWidget {
  final List<String> attachments;
  final int initialIndex;
  final Function(int)? onDelete;

  const AttachmentViewerPage({
    super.key,
    required this.attachments,
    this.initialIndex = 0,
    this.onDelete,
  });

  @override
  State<AttachmentViewerPage> createState() => _AttachmentViewerPageState();
}

class _AttachmentViewerPageState extends State<AttachmentViewerPage> {
  late PageController _pageController;
  late AttachmentViewerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AttachmentViewerController(
      attachments: widget.attachments,
      initialIndex: widget.initialIndex,
    );
    _pageController = PageController(initialPage: widget.initialIndex);
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (_controller.isEmpty && mounted) {
      Navigator.of(context).pop();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_controller.currentIndex + 1} / ${_controller.totalCount}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareAttachment,
            tooltip: loc.share_attachment,
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
              tooltip: loc.delete_attachment,
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _controller.totalCount,
        onPageChanged: _controller.setCurrentIndex,
        itemBuilder: (context, index) {
          return _buildViewerForAttachment(_controller.attachments[index]);
        },
      ),
    );
  }

  Widget _buildViewerForAttachment(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      return ImageViewerPage(filePath: filePath);
    } else if (extension == '.pdf') {
      return PdfViewerPage(filePath: filePath);
    } else if (['.mp4', '.mov'].contains(extension)) {
      return VideoPlayerPage(filePath: filePath);
    } else {
      return _buildUnsupportedFileView(filePath);
    }
  }

  Widget _buildUnsupportedFileView(String filePath) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insert_drive_file, size: 120, color: Colors.white70),
          const SizedBox(height: 16),
          const Text(
            'File',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            path.basename(filePath),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _shareAttachment() async {
    try {
      final filePath = _controller.currentAttachment;
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(filePath)],
        fileNameOverrides: [path.basename(filePath)],
      );
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final loc = gen.AppLocalizations.of(context);
    final navigator = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material3Dialog(
        icon: Icon(
          Icons.warning_amber_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: Text(loc.delete_attachment_confirm_title),
        content: Text(loc.delete_attachment_confirm_message),
        actions: [
          Material3DialogActions.cancel(ctx, loc.cancel),
          Material3DialogActions.destructive(
            ctx,
            loc.delete,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      widget.onDelete?.call(_controller.currentIndex);
      navigator.pop();
    }
  }
}
