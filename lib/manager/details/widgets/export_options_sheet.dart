import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class ExportOptionsSheet extends StatelessWidget {
  final VoidCallback onDownloadCsv;
  final VoidCallback onShareCsv;
  final VoidCallback onDownloadOfx;
  final VoidCallback onShareOfx;
  final VoidCallback onDownloadMarkdown;
  final VoidCallback onShareMarkdown;

  const ExportOptionsSheet({
    super.key,
    required this.onDownloadCsv,
    required this.onShareCsv,
    required this.onDownloadOfx,
    required this.onShareOfx,
    required this.onDownloadMarkdown,
    required this.onShareMarkdown,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GroupBottomSheetScaffold(
      title: gloc.export_options,
      scrollable: true,
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        bottomInset > 0 ? bottomInset : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CSV - Spreadsheet format
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'CSV',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share_outlined, color: colorScheme.onSurface),
            title: Text(gloc.share_all_csv),
            onTap: onShareCsv,
          ),
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.download_all_csv),
            onTap: onDownloadCsv,
          ),
          const SizedBox(height: 8),

          // OFX - Banking format
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'OFX',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share_outlined, color: colorScheme.onSurface),
            title: Text(gloc.share_all_ofx),
            onTap: onShareOfx,
          ),
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.download_all_ofx),
            onTap: onDownloadOfx,
          ),
          const SizedBox(height: 8),

          // Markdown - Document format
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'Markdown',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.share_outlined, color: colorScheme.onSurface),
            title: Text(gloc.share_all_markdown),
            onTap: onShareMarkdown,
          ),
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: colorScheme.onSurface,
            ),
            title: Text(gloc.download_all_markdown),
            onTap: onDownloadMarkdown,
          ),
        ],
      ),
    );
  }
}
