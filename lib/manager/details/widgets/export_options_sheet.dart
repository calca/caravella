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

    return GroupBottomSheetScaffold(
      title: gloc.export_options,
      scrollable: true,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        bottomInset > 0 ? bottomInset : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ExportFormatRow(
            icon: Icons.table_chart_outlined,
            format: 'CSV',
            description: gloc.export_csv_description,
            onShare: onShareCsv,
            onDownload: onDownloadCsv,
            shareTooltip: gloc.share_label,
            downloadTooltip: gloc.save_label,
          ),
          const SizedBox(height: 8),
          _ExportFormatRow(
            icon: Icons.account_balance_outlined,
            format: 'OFX',
            description: gloc.export_ofx_description,
            onShare: onShareOfx,
            onDownload: onDownloadOfx,
            shareTooltip: gloc.share_label,
            downloadTooltip: gloc.save_label,
          ),
          const SizedBox(height: 8),
          _ExportFormatRow(
            icon: Icons.description_outlined,
            format: 'Markdown',
            description: gloc.export_markdown_description,
            onShare: onShareMarkdown,
            onDownload: onDownloadMarkdown,
            shareTooltip: gloc.share_label,
            downloadTooltip: gloc.save_label,
          ),
        ],
      ),
    );
  }
}

class _ExportFormatRow extends StatelessWidget {
  final IconData icon;
  final String format;
  final String description;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final String shareTooltip;
  final String downloadTooltip;

  const _ExportFormatRow({
    required this.icon,
    required this.format,
    required this.description,
    required this.onShare,
    required this.onDownload,
    required this.shareTooltip,
    required this.downloadTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: onShare,
              tooltip: shareTooltip,
              color: colorScheme.onSurfaceVariant,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              onPressed: onDownload,
              tooltip: downloadTooltip,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
