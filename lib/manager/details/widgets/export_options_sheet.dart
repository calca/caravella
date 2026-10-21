import 'package:material_ui/material_ui.dart';
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

    Widget row(
      IconData icon,
      String format,
      String description,
      VoidCallback onShare,
      VoidCallback onDownload,
    ) => SettingsTile(
      icon: icon,
      title: format,
      subtitle: description,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundAction(
            icon: Icons.share_outlined,
            tooltip: '${gloc.share_label} $format',
            onPressed: onShare,
          ),
          const SizedBox(width: 4),
          _RoundAction(
            icon: Icons.download_rounded,
            tooltip: '${gloc.save_label} $format',
            onPressed: onDownload,
          ),
        ],
      ),
    );

    return CaravellaBottomSheetScaffold(
      title: gloc.export_options,
      scrollable: true,
      child: SettingsGroup(
        topSpacing: 0,
        children: [
          row(
            Icons.table_chart_outlined,
            'CSV',
            gloc.export_csv_description,
            onShareCsv,
            onDownloadCsv,
          ),
          row(
            Icons.account_balance_outlined,
            'OFX',
            gloc.export_ofx_description,
            onShareOfx,
            onDownloadOfx,
          ),
          row(
            Icons.description_outlined,
            'Markdown',
            gloc.export_markdown_description,
            onShareMarkdown,
            onDownloadMarkdown,
          ),
        ],
      ),
    );
  }
}

/// Round grey icon button (share, save) at the end of a format's row.
class _RoundAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: s.onSurface,
      style: IconButton.styleFrom(
        backgroundColor: s.onSurface.withValues(alpha: 0.06),
      ),
    );
  }
}
