import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'export_options_sheet.dart';
import '../export/ofx_exporter.dart';
import '../export/csv_exporter.dart';
import '../export/markdown_exporter.dart';

/// Opens the export-options bottom sheet for [trip] (CSV/OFX/Markdown,
/// each with a "download to a chosen directory" and a "share" action),
/// wiring each option to the matching exporter, file IO, and a result toast.
void showExpenseExportOptionsSheet(BuildContext context, ExpenseGroup? trip) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetCtx) => ExportOptionsSheet(
      onDownloadCsv: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context; // capture for toasts
        final csv = CsvExporter.generate(trip, gloc);
        if (csv.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final filename = CsvExporter.buildFilename(trip);
        String? dirPath;
        try {
          dirPath = await FilePicker.getDirectoryPath(
            dialogTitle: gloc.csv_select_directory_title,
          );
        } catch (_) {
          dirPath = null;
        }
        if (dirPath == null) {
          if (!rootContext.mounted) return;
          AppToast.show(
            rootContext,
            gloc.csv_save_cancelled,
            type: ToastType.info,
          );
          return;
        }
        try {
          final file = File('$dirPath/$filename');
          await file.writeAsString(csv);
          if (!rootContext.mounted) return;
          final msg = gloc.csv_saved_in(file.path);
          AppToast.show(rootContext, msg, type: ToastType.success);
          nav.pop();
        } catch (e) {
          if (!rootContext.mounted) return;
          AppToast.show(rootContext, gloc.csv_save_error, type: ToastType.error);
        }
      },
      onShareCsv: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context;
        final csv = CsvExporter.generate(trip, gloc);
        if (csv.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${CsvExporter.buildFilename(trip)}',
        ).create();
        await file.writeAsString(csv);
        if (!rootContext.mounted) return; // ensure still alive before share
        await SharePlus.instance.share(
          ShareParams(text: '${trip!.title} - CSV', files: [XFile(file.path)]),
        );
        if (!rootContext.mounted) return;
        nav.pop();
      },
      onDownloadOfx: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context; // capture for toasts
        final ofx = OfxExporter.generate(trip);
        if (ofx.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final filename = OfxExporter.buildFilename(trip);
        String? dirPath;
        try {
          dirPath = await FilePicker.getDirectoryPath(
            dialogTitle: gloc.ofx_select_directory_title,
          );
        } catch (_) {
          dirPath = null;
        }
        if (dirPath == null) {
          if (!rootContext.mounted) return;
          AppToast.show(
            rootContext,
            gloc.ofx_save_cancelled,
            type: ToastType.info,
          );
          return;
        }
        try {
          final file = File('$dirPath/$filename');
          await file.writeAsString(ofx);
          if (!rootContext.mounted) return;
          final msg = gloc.ofx_saved_in(file.path);
          AppToast.show(rootContext, msg, type: ToastType.success);
          nav.pop();
        } catch (e) {
          if (!rootContext.mounted) return;
          AppToast.show(rootContext, gloc.ofx_save_error, type: ToastType.error);
        }
      },
      onShareOfx: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context;
        final ofx = OfxExporter.generate(trip);
        if (ofx.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${OfxExporter.buildFilename(trip)}',
        ).create();
        await file.writeAsString(ofx);
        if (!rootContext.mounted) return; // ensure still alive before share
        await SharePlus.instance.share(
          ShareParams(text: '${trip!.title} - OFX', files: [XFile(file.path)]),
        );
        if (!rootContext.mounted) return;
        nav.pop();
      },
      onDownloadMarkdown: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context;
        final markdown = MarkdownExporter.generate(trip, gloc);
        if (markdown.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final filename = MarkdownExporter.buildFilename(trip);
        String? dirPath;
        try {
          dirPath = await FilePicker.getDirectoryPath(
            dialogTitle: gloc.markdown_select_directory_title,
          );
        } catch (_) {
          dirPath = null;
        }
        if (dirPath == null) {
          if (!rootContext.mounted) return;
          AppToast.show(
            rootContext,
            gloc.markdown_save_cancelled,
            type: ToastType.info,
          );
          return;
        }
        try {
          final file = File('$dirPath/$filename');
          await file.writeAsString(markdown);
          if (!rootContext.mounted) return;
          final msg = gloc.markdown_saved_in(file.path);
          AppToast.show(rootContext, msg, type: ToastType.success);
          nav.pop();
        } catch (e) {
          if (!rootContext.mounted) return;
          AppToast.show(
            rootContext,
            gloc.markdown_save_error,
            type: ToastType.error,
          );
        }
      },
      onShareMarkdown: () async {
        final gloc = gen.AppLocalizations.of(context);
        final nav = Navigator.of(sheetCtx);
        final rootContext = context;
        final markdown = MarkdownExporter.generate(trip, gloc);
        if (markdown.isEmpty) {
          if (rootContext.mounted) {
            AppToast.show(
              rootContext,
              gloc.no_expenses_to_export,
              type: ToastType.info,
            );
          }
          return;
        }
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/${MarkdownExporter.buildFilename(trip)}',
        ).create();
        await file.writeAsString(markdown);
        if (!rootContext.mounted) return;
        await SharePlus.instance.share(
          ShareParams(
            text: '${trip!.title} - Markdown',
            files: [XFile(file.path)],
          ),
        );
        if (!rootContext.mounted) return;
        nav.pop();
      },
    ),
  );
}
