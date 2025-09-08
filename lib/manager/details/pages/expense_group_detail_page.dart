import '../../group/pages/expenses_group_edit_page.dart';
import '../../group/group_edit_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../../data/model/expense_details.dart';
import '../../../data/model/expense_group.dart';
import '../../../state/expense_group_notifier.dart';
import '../../../data/expense_group_storage_v2.dart';
import '../../../widgets/material3_dialog.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../widgets/app_toast.dart';
import '../widgets/expense_group_app_bar.dart';
import '../widgets/expense_group_header_section.dart';
import '../widgets/expense_group_content_section.dart';
import 'unified_overview_page.dart';
import '../widgets/options_sheet.dart';
import '../widgets/export_options_sheet.dart';
import '../widgets/expense_entry_sheet.dart';
import '../widgets/delete_expense_dialog.dart';
import '../../../widgets/add_fab.dart';
import '../export/ofx_exporter.dart';
import '../export/csv_exporter.dart';

class ExpenseGroupDetailPage extends StatefulWidget {
  final ExpenseGroup trip;
  const ExpenseGroupDetailPage({super.key, required this.trip});

  @override
  State<ExpenseGroupDetailPage> createState() => _ExpenseGroupDetailPageState();
}

class _ExpenseGroupDetailPageState extends State<ExpenseGroupDetailPage> {
  ExpenseGroup? _trip;
  bool _deleted = false;
  ExpenseGroupNotifier? _groupNotifier;
  
  // Scroll and UI state
  late ScrollController _scrollController;
  bool _hideHeader = false;
  bool _collapsedTitleVisible = false;
  bool _fabVisible = true;
  Timer? _fabIdleTimer;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Setup group notifier for live updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupNotifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
      _groupNotifier?.addListener(_onGroupChanged);
    });
  }

  @override
  void dispose() {
    _groupNotifier?.removeListener(_onGroupChanged);
    _groupNotifier = null;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabIdleTimer?.cancel();
    super.dispose();
  }

  void _onGroupChanged() {
    final currentGroup = _groupNotifier?.currentGroup;
    if (currentGroup != null && _trip != null && currentGroup.id == _trip!.id) {
      if (mounted) {
        setState(() {
          _trip = currentGroup;
        });
      }
    }
  }

  Future<void> _loadTrip() async {
    final trip = await ExpenseGroupStorageV2.getTripById(widget.trip.id);
    if (!mounted) return;
    setState(() {
      _trip = trip;
      _deleted = trip == null;
    });
    if (_deleted && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _refreshGroup() async {
    if (_trip == null) return;
    final refreshed = await ExpenseGroupStorageV2.getTripById(_trip!.id);
    if (!mounted || refreshed == null) return;
    setState(() => _trip = refreshed);
    _groupNotifier?.setCurrentGroup(refreshed);
  }

  void _openUnifiedOverviewPage() {
    if (_trip == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UnifiedOverviewPage(trip: _trip!)),
    );
  }

  void _showExportOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => ExportOptionsSheet(
        onDownloadCsv: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final csv = CsvExporter.generate(_trip, gloc);
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
          final filename = CsvExporter.buildFilename(_trip);
          String? dirPath;
          try {
            dirPath = await FilePicker.platform.getDirectoryPath(
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
            AppToast.show(
              rootContext,
              gloc.csv_save_error,
              type: ToastType.error,
            );
          }
        },
        onShareCsv: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final csv = CsvExporter.generate(_trip, gloc);
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
          try {
            final tempDir = await getTemporaryDirectory();
            final filename = CsvExporter.buildFilename(_trip);
            final file = File('${tempDir.path}/$filename');
            await file.writeAsString(csv);
            await Share.shareXFiles(
              [XFile(file.path)],
              text: gloc.expenses_from(_trip?.title ?? ''),
            );
            nav.pop();
          } catch (e) {
            if (!rootContext.mounted) return;
            AppToast.show(
              rootContext,
              gloc.csv_share_error,
              type: ToastType.error,
            );
          }
        },
        onDownloadOfx: () async {
          final gloc = gen.AppLocalizations.of(context);
          final nav = Navigator.of(sheetCtx);
          final rootContext = context;
          final ofx = OfxExporter.generate(_trip, gloc);
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
          final filename = OfxExporter.buildFilename(_trip);
          String? dirPath;
          try {
            dirPath = await FilePicker.platform.getDirectoryPath(
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
            AppToast.show(
              rootContext,
              gloc.ofx_save_error,
              type: ToastType.error,
            );
          }
        },
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => OptionsSheet(
        onEdit: () {
          Navigator.of(ctx).pop();
          _editGroup();
        },
        onExport: () {
          Navigator.of(ctx).pop();
          _showExportOptionsSheet();
        },
        onDelete: () {
          Navigator.of(ctx).pop();
          _deleteGroup();
        },
      ),
    );
  }

  void _editGroup() {
    if (_trip == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ExpensesGroupEditPage(
          initialTrip: _trip!,
          editMode: GroupEditMode.edit,
        ),
      ),
    ).then((result) async {
      if (result == true) {
        await _refreshGroup();
      }
    });
  }

  Future<void> _deleteGroup() async {
    if (_trip == null) return;
    final gloc = gen.AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => Material3Dialog(
        icon: Icon(
          Icons.delete_outlined,
          color: Theme.of(context).colorScheme.error,
          size: 24,
        ),
        title: Text(gloc.delete_group_title),
        content: Text(gloc.delete_group_message(_trip!.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(gloc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(gloc.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ExpenseGroupStorageV2.deleteTrip(_trip!.id);
        _groupNotifier?.deleteGroup(_trip!.id);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.delete_group_error,
            type: ToastType.error,
          );
        }
      }
    }
  }

  void _openEditExpense(ExpenseDetails expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ExpenseEntrySheet(
        trip: _trip!,
        initialExpense: expense,
        onExpenseUpdated: (updated) => _refreshGroup(),
        onExpenseDeleted: () => _refreshGroup(),
      ),
    );
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => ExpenseEntrySheet(
        trip: _trip!,
        onExpenseUpdated: (expense) => _refreshGroup(),
      ),
    );
  }

  void _onScroll() {
    if (!mounted) return;
    final currentOffset = _scrollController.offset;
    const threshold = 100.0;
    const titleThreshold = 200.0;
    
    // Handle header visibility
    final shouldHideHeader = currentOffset > threshold;
    if (_hideHeader != shouldHideHeader) {
      setState(() => _hideHeader = shouldHideHeader);
    }
    
    // Handle collapsed title visibility
    final shouldShowTitle = currentOffset > titleThreshold;
    if (_collapsedTitleVisible != shouldShowTitle) {
      setState(() => _collapsedTitleVisible = shouldShowTitle);
    }
    
    // Handle FAB visibility with idle timer
    _fabIdleTimer?.cancel();
    if (!_fabVisible) {
      setState(() => _fabVisible = true);
    }
    
    _fabIdleTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _fabVisible = false);
      }
    });
  }

  double _calculateBottomPadding() {
    const fabHeight = 56.0;
    const fabBottomMargin = 16.0;
    const additionalPadding = 16.0;
    return fabHeight + fabBottomMargin + additionalPadding;
  }

  Widget _buildAnimatedFab(ColorScheme colorScheme) {
    return AnimatedScale(
      scale: _fabVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: _fabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: AddFab(
          onPressed: _showAddExpenseSheet,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_deleted) {
      return const SizedBox.shrink();
    }
    final trip = _trip;
    if (trip == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final colorScheme = Theme.of(context).colorScheme;
    final totalExpenses = trip.expenses.fold<double>(
      0,
      (sum, s) => sum + (s.amount ?? 0),
    );
    final showCollapsedTitle = _hideHeader || _collapsedTitleVisible;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ExpenseGroupAppBar(
            groupTitle: trip.title,
            showCollapsedTitle: showCollapsedTitle,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          ExpenseGroupHeaderSection(
            trip: trip,
            hideHeader: _hideHeader,
            totalExpenses: totalExpenses,
            onOverview: _openUnifiedOverviewPage,
            onOptions: _showOptionsSheet,
          ),
          ...ExpenseGroupContentSection(
            trip: trip,
            onExpenseTap: _openEditExpense,
            onFiltersVisibilityChanged: (visible) {
              if (mounted) {
                setState(() => _hideHeader = visible);
              }
            },
            onAddExpense: _showAddExpenseSheet,
            bottomPadding: _calculateBottomPadding(),
          ).buildSlivers(context),
        ],
      ),
      floatingActionButton: _buildAnimatedFab(colorScheme),
    );
  }
}