import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:pdfx/pdfx.dart';

/// Standalone PDF viewer with document rendering and scrolling
class PdfViewerPage extends StatefulWidget {
  final String filePath;

  const PdfViewerPage({super.key, required this.filePath});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _pdfController = PdfController(
          document: PdfDocument.openFile(widget.filePath),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null || _pdfController == null) {
      return _buildErrorWidget(context);
    }

    return PdfView(controller: _pdfController!, scrollDirection: Axis.vertical);
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Error loading PDF',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            path.basename(widget.filePath),
            style: const TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
