import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:path/path.dart' as path;

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.attachments.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAttachment(widget.attachments[_currentIndex]),
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
        itemCount: widget.attachments.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return _AttachmentContent(
            filePath: widget.attachments[index],
          );
        },
      ),
    );
  }

  Future<void> _shareAttachment(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final loc = gen.AppLocalizations.of(context);
    
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

    if (confirmed == true && mounted) {
      widget.onDelete?.call(_currentIndex);
      Navigator.of(context).pop();
    }
  }
}

class _AttachmentContent extends StatelessWidget {
  final String filePath;

  const _AttachmentContent({
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final extension = path.extension(filePath).toLowerCase();

    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(context);
            },
          ),
        ),
      );
    } else if (extension == '.pdf') {
      return _buildFilePreview(
        context,
        Icons.picture_as_pdf,
        'PDF',
      );
    } else if (['.mp4', '.mov'].contains(extension)) {
      return _buildFilePreview(
        context,
        Icons.play_circle_outline,
        'Video',
      );
    } else {
      return _buildFilePreview(
        context,
        Icons.insert_drive_file,
        'File',
      );
    }
  }

  Widget _buildFilePreview(BuildContext context, IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 120,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            path.basename(filePath),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white54,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading file',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
