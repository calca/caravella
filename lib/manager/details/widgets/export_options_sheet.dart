import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';

class ExportOptionsSheet extends StatelessWidget {
  final VoidCallback onDownloadCsv;
  final VoidCallback onShareCsv;
  final VoidCallback onDownloadOfx;
  final VoidCallback onShareOfx;

  const ExportOptionsSheet({
    super.key,
    required this.onDownloadCsv,
    required this.onShareCsv,
    required this.onDownloadOfx,
    required this.onShareOfx,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return GroupBottomSheetScaffold(
      title: gloc.export_options,
      scrollable: false, // dynamic height, no internal scroll
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        bottomInset > 0 ? bottomInset : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Share options first
          ListTile(
            leading: Icon(
              Icons.share_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.share_all_csv),
            onTap: onShareCsv,
          ),
          ListTile(
            leading: Icon(
              Icons.share_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.share_all_ofx),
            onTap: onShareOfx,
          ),
          // Download options second
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.download_all_csv),
            onTap: onDownloadCsv,
          ),
          ListTile(
            leading: Icon(
              Icons.file_download_outlined,
              color: Theme.of(context).colorScheme.onPrimaryFixed,
            ),
            title: Text(gloc.download_all_ofx),
            onTap: onDownloadOfx,
          ),
        ],
      ),
    );
  }
}
