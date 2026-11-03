library;

import 'package:io_caravella_egm/services/permission_dialog.dart';
import '../location/location_service.dart';
import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart' hide ImageSource;
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../widgets/expense_form_actions_widget.dart';
import '../widgets/voice_capture_bottom_sheet.dart';
import '../state/expense_form_controller.dart';
import '../state/expense_form_state.dart';
import '../coordination/route_settled.dart';
import 'expense_form_config.dart';
import 'expense_form_lifecycle_manager.dart';
import 'expense_form_orchestrator.dart';
import 'expense_form_fields.dart';
import 'expense_form_extended_fields.dart';
import 'expense_form_compact_header.dart';
import '../../../services/receipt_scanner_service.dart';

/// Main expense form component - refactored to use config object pattern
///
/// This component now accepts a single ExpenseFormConfig parameter instead
/// of 43 individual parameters, improving maintainability and readability.
class ExpenseFormComponent extends StatefulWidget {
  final ExpenseFormConfig config;

  const ExpenseFormComponent({super.key, required this.config});

  // Legacy constructor for backward compatibility
  ExpenseFormComponent.legacy({
    super.key,
    ExpenseDetails? initialExpense,
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    Function(String)? onParticipantAdded,
    VoidCallback? onDelete,
    bool shouldAutoClose = true,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? newlyAddedCategory,
    String? groupTitle,
    required String groupId,
    String? currency,
    required bool autoLocationEnabled,
    bool fullEdit = false,
    bool isReadOnly = false,
    ScrollController? scrollController,
    void Function(ExpenseFormState)? onExpand,
    bool showGroupHeader = true,
    bool showActionsRow = true,
    void Function(bool)? onFormValidityChanged,
    void Function(VoidCallback?)? onSaveCallbackChanged,
    void Function(VoidCallback?)? onVoiceCallbackChanged,
    void Function(VoidCallback?)? onScanReceiptCallbackChanged,
    void Function(VoidCallback?)? onScanReceiptFromGalleryCallbackChanged,
  }) : config = ExpenseFormConfig(
         initialExpense: initialExpense,
         participants: participants,
         categories: categories,
         groupId: groupId,
         onExpenseAdded: onExpenseAdded,
         onCategoryAdded: onCategoryAdded,
         onParticipantAdded: onParticipantAdded,
         onDelete: onDelete,
         shouldAutoClose: shouldAutoClose,
         tripStartDate: tripStartDate,
         tripEndDate: tripEndDate,
         newlyAddedCategory: newlyAddedCategory,
         groupTitle: groupTitle,
         currency: currency,
         autoLocationEnabled: autoLocationEnabled,
         fullEdit: fullEdit,
         scrollController: scrollController,
         onExpand: onExpand,
         showGroupHeader: showGroupHeader,
         showActionsRow: showActionsRow,
         onFormValidityChanged: onFormValidityChanged,
         onSaveCallbackChanged: onSaveCallbackChanged,
         onVoiceCallbackChanged: onVoiceCallbackChanged,
         onScanReceiptCallbackChanged: onScanReceiptCallbackChanged,
         onScanReceiptFromGalleryCallbackChanged:
             onScanReceiptFromGalleryCallbackChanged,
         isReadOnly: isReadOnly,
       );

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormLifecycleManager _lifecycleManager;
  late ExpenseFormOrchestrator _orchestrator;
  late ExpenseFormController _controller;

  // Receipt scanner
  final _receiptScanner = ReceiptScannerService();

  /// The receipt scan's line above the fields, while there's one to show.
  _ScanLine? _scanLine;
  final _imagePicker = ImagePicker();

  /// The quick-add sheet: no details section, just "More details" opening
  /// the full page (and a scanned receipt's photo, if any).
  bool get _isQuickAdd =>
      !widget.config.fullEdit &&
      !widget.config.isEditMode &&
      !_controller.isExpanded &&
      widget.config.onExpand != null;

  @override
  void initState() {
    super.initState();

    // Initialize lifecycle manager
    _lifecycleManager = ExpenseFormLifecycleManager(
      config: widget.config,
      onControllerReady: (controller) {
        _controller = controller;

        // Initialize orchestrator after controller is ready
        _orchestrator = ExpenseFormOrchestrator(
          config: widget.config,
          controller: _controller,
          formKey: _formKey,
        );
        _orchestrator.initialize();

        // Setup save callback wrapper to provide context
        if (widget.config.onSaveCallbackChanged != null) {
          _controller.addListener(_notifySaveCallbackWithContext);
          _notifySaveCallbackWithContext(); // Initial state
        }

        if (widget.config.onVoiceCallbackChanged != null) {
          _notifyVoiceCallback();
        }

        if (widget.config.onScanReceiptCallbackChanged != null ||
            widget.config.onScanReceiptFromGalleryCallbackChanged != null) {
          _notifyScanReceiptCallback();
        }

        // Setup focus listeners for scroll coordination
        _setupFocusListeners();

        // Autofocus the amount when adding, once the sheet (or page) has
        // slid in: the keyboard rising during the slide made it jerky. When
        // editing, show the whole expense instead of the keyboard.
        if (!widget.config.isEditMode) {
          routeSettled(context).then((_) {
            if (mounted) _controller.amountFocus.requestFocus();
          });
        }
      },
    );

    // Initialize synchronously - no loader needed!
    _lifecycleManager.initializeSync(context);
    _nameBarePlace();
  }

  /// An expense saved before places kept their details (2.3.0) has only
  /// coordinates: look up their name in the background, show it, and keep
  /// it for next time — not as an edit (no "discard changes?", no "modified
  /// by", nothing to sync), see [ExpenseGroupStorageV2.fillExpenseLocation].
  Future<void> _nameBarePlace() async {
    final expense = widget.config.initialExpense;
    final bare = expense?.location;
    if (expense == null || expense.id.isEmpty || bare == null) return;
    if (!bare.isBareCoordinates) return;
    final named = await LocationService.name(bare);
    if (named == null || !mounted) return;
    // The user may have changed or removed the place meanwhile.
    if (_controller.state.location != bare) return;
    _controller.updateLocation(named, byUser: false);
    await ExpenseGroupStorageV2.fillExpenseLocation(
      widget.config.groupId,
      expense.id,
      named,
    );
  }

  void _setupFocusListeners() {
    final scrollCoordinator = _lifecycleManager.scrollCoordinator;
    if (scrollCoordinator == null) return;

    _controller.amountFocus.addListener(() {
      if (_controller.amountFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.amountFieldKey);
        });
      }
    });

    _controller.nameFocus.addListener(() {
      if (_controller.nameFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.nameFieldKey);
        });
      }
    });

    _controller.locationFocus.addListener(() {
      if (_controller.locationFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.locationFieldKey);
        });
      }
    });

    _controller.noteFocus.addListener(() {
      if (_controller.noteFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(_controller.noteFieldKey);
        });
      }
    });
  }

  void _notifySaveCallbackWithContext() {
    // Create a proper callback with context access
    final isValid = _controller.isFormValid;
    final callback = isValid ? () => _orchestrator.saveExpense(context) : null;
    widget.config.onSaveCallbackChanged?.call(callback);
  }

  void _notifyVoiceCallback() {
    final isEdit =
        widget.config.initialExpense?.id != null &&
        widget.config.initialExpense!.id.isNotEmpty;
    final showVoice = !isEdit && !widget.config.isReadOnly;
    final callback = showVoice ? () => _showVoiceCapture(context) : null;
    widget.config.onVoiceCallbackChanged?.call(callback);
  }

  void _notifyScanReceiptCallback() {
    final isEdit =
        widget.config.initialExpense?.id != null &&
        widget.config.initialExpense!.id.isNotEmpty;
    final canScan =
        _receiptScanner.isAvailable && !isEdit && !widget.config.isReadOnly;
    widget.config.onScanReceiptCallbackChanged?.call(
      canScan ? () => _scanReceipt(source: ImageSource.camera) : null,
    );
    widget.config.onScanReceiptFromGalleryCallbackChanged?.call(
      canScan ? () => _scanReceipt(source: ImageSource.gallery) : null,
    );
  }

  Future<bool> _confirmDiscardChanges() async {
    final gloc = gen.AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => Material3Dialog(
            title: Text(gloc.discard_changes_title),
            content: Text(gloc.discard_changes_message),
            // Leaving is a choice, not a danger: the safe action is the
            // filled one, Discard is red text (no warning icon).
            actions: [
              Material3DialogActions.destructiveText(
                ctx,
                gloc.discard,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              Material3DialogActions.primary(
                ctx,
                gloc.keep_editing,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';

    return PopScope(
      canPop: !_controller.state.isDirty,
      onPopInvokedWithResult: _handlePop,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpenseFormCompactHeader(
              groupTitle: widget.config.groupTitle,
              showGroupHeader: widget.config.showGroupHeader,
            ),
            if (_scanLine != null)
              _ReceiptScanLine(
                line: _scanLine!,
                onClose: () => setState(() => _scanLine = null),
              ),
            ExpenseFormFields(
              controller: _controller,
              participants: _lifecycleManager.participants,
              categories: _lifecycleManager.categories,
              onCategoryAdded: _onCategoryAdded,
              onParticipantAdded: widget.config.onParticipantAdded != null
                  ? _onParticipantAdded
                  : null,
              onCategoriesUpdated: (newCategories) {
                _lifecycleManager.updateCategories(newCategories);
                setState(() {});
              },
              onParticipantsUpdated: (newParticipants) {
                _lifecycleManager.updateParticipants(newParticipants);
                setState(() {});
              },
              currency: widget.config.currency,
              onSaveExpense: () => _orchestrator.saveExpense(context),
              isReadOnly: widget.config.isReadOnly,
              // The sheets stay short: one line of pills each.
              compactPills: !widget.config.fullEdit && !_controller.isExpanded,
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => ExpenseFormExtendedFields(
                controller: _controller,
                tripStartDate: widget.config.tripStartDate,
                tripEndDate: widget.config.tripEndDate,
                locale: locale,
                groupId: widget.config.groupId,
                groupName: widget.config.groupTitle ?? 'Unnamed',
                isFormValid: _controller.isFormValid,
                onSaveExpense: () => _orchestrator.saveExpense(context),
                isReadOnly: widget.config.isReadOnly,
                onMoreDetails: _isQuickAdd ? _orchestrator.expand : null,
              ),
            ),
            if (widget.config.showActionsRow) ...[
              const SizedBox(height: FormTheme.sectionSpacing),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _buildActionsRow(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (_controller.state.isDirty) {
      final navigator = Navigator.of(context);
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && navigator.canPop()) navigator.pop();
    }
  }

  Future<void> _onCategoryAdded(String categoryName) async {
    widget.config.onCategoryAdded(categoryName);
    // Brief delay to allow the notifier to update and persist the new category
    await Future.delayed(const Duration(milliseconds: 100));

    final categories = widget.config.categories;
    final found = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );

    final currentCategories = _lifecycleManager.categories;
    if (!currentCategories.contains(found)) {
      _lifecycleManager.updateCategories(List.from(categories));
      _controller.addCategory(found);
      setState(() {});
    }

    // Additional delay to ensure category list is fully updated before selection
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.isNotEmpty
          ? categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );

    _lifecycleManager.updateCategories(List.from(categories));
    _controller.updateCategory(foundAfter);
    setState(() {});
  }

  Future<void> _onParticipantAdded(String participantName) async {
    if (widget.config.onParticipantAdded == null) return;

    LoggerService.info(
      'Adding participant: "$participantName"',
      name: 'expense.participant',
    );

    // Fire the callback which adds the participant to the data store (notifier).
    // We do NOT await this — the callback itself is async and calls addParticipant,
    // which updates _currentGroup synchronously (before its own I/O await).
    widget.config.onParticipantAdded!(participantName);

    // Yield control so the microtask scheduled by the fire-and-forget callback
    // above can run.  Even though the notifier's _currentGroup update is
    // synchronous inside addParticipant, the callback's async function starts
    // as a new microtask/event, so we must suspend here at least once to let it
    // execute.  A short timer is used as a safe buffer against platform-specific
    // async scheduling subtleties.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Read the updated participants directly from the notifier (already updated in memory).
    final notifier = context.read<ExpenseGroupNotifier?>();
    final notifierParticipants = notifier?.currentGroup?.participants;

    List<ExpenseParticipant> updatedParticipants;
    if (notifierParticipants != null &&
        notifierParticipants.any((p) => p.name == participantName)) {
      updatedParticipants = notifierParticipants;
    } else {
      // Fallback for flows where the notifier is not used (e.g. notification sheet).
      updatedParticipants = widget.config.participants;
    }

    _lifecycleManager.updateParticipants(List.from(updatedParticipants));

    // Auto-select the newly added participant as the paidBy field.
    final newParticipant = updatedParticipants
        .where((p) => p.name == participantName)
        .firstOrNull;
    if (newParticipant != null) {
      LoggerService.info(
        'Auto-selecting newly added participant: "${newParticipant.name}"',
        name: 'expense.participant',
      );
      _controller.updatePaidBy(newParticipant);
    }

    setState(() {});

    LoggerService.info(
      'Participant add process completed for: "$participantName"',
      name: 'expense.participant',
    );
  }

  /// Scans a receipt with OCR. [source] is chosen by the caller — tapping
  /// the scan button goes straight to the camera (the common case right
  /// after paying), long-pressing it (or the "from gallery" accessibility
  /// action) picks an existing photo instead. No intermediate chooser sheet.
  ///
  /// Progress and problems show in a line above the fields
  /// ([_ReceiptScanLine]); a good read just fills the fields. A refused
  /// camera or photos permission opens [showPermissionDeniedDialog].
  Future<void> _scanReceipt({required ImageSource source}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null || !mounted) return;

      setState(() => _scanLine = _ScanLine.reading);

      final imageFile = File(pickedFile.path);
      final result = await _receiptScanner.scanReceipt(imageFile);

      if (!mounted) return;

      final amount = result['amount'] as double?;
      final description = result['description'] as String?;

      if (amount == null && description == null) {
        setState(() => _scanLine = _ScanLine.noText);
        return;
      }
      setState(() => _scanLine = null);

      if (amount != null) {
        _controller.amountController.text =
            ExpenseFormController.formatAmountForInput(amount);
      }
      if (description != null && description.isNotEmpty) {
        _controller.nameController.text = description;
      }
      _controller.markDirty();
    } on PlatformException catch (e) {
      if (!mounted) return;
      final denied = switch (e.code) {
        'camera_access_denied' => DeniedPermission.camera,
        'photo_access_denied' => DeniedPermission.photos,
        _ => null,
      };
      if (denied != null) {
        setState(() => _scanLine = null);
        await showPermissionDeniedDialog(context, denied);
      } else {
        setState(() => _scanLine = _ScanLine.failed);
      }
    } catch (e) {
      if (mounted) setState(() => _scanLine = _ScanLine.failed);
    }
  }

  Widget _buildActionsRow() {
    final isEdit =
        widget.config.initialExpense?.id != null &&
        widget.config.initialExpense!.id.isNotEmpty;
    final showVoice = !isEdit && !widget.config.isReadOnly;

    return ExpenseFormActionsWidget(
      onSave: _controller.isFormValid
          ? () => _orchestrator.saveExpense(context)
          : null,
      isFormValid: _controller.isFormValid,
      isEdit: isEdit,
      onDelete: widget.config.hasDeleteAction
          ? () => _orchestrator.deleteExpense(context)
          : null,
      showExpandButton: false,
      onExpand: null,
      onScanReceipt:
          _receiptScanner.isAvailable && widget.config.initialExpense == null
          ? () => _scanReceipt(source: ImageSource.camera)
          : null,
      onScanReceiptFromGallery:
          _receiptScanner.isAvailable && widget.config.initialExpense == null
          ? () => _scanReceipt(source: ImageSource.gallery)
          : null,
      showVoiceButton: showVoice,
      onVoiceTap: showVoice ? () => _showVoiceCapture(context) : null,
    );
  }

  Future<void> _showVoiceCapture(BuildContext context) async {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final localeId = '${locale}_${locale.toUpperCase()}';
    final participantNames = _lifecycleManager.participants
        .map((p) => p.name)
        .toList();

    await VoiceCaptureBottomSheet.show(
      context: context,
      participantNames: participantNames,
      localeId: localeId,
      onVoiceResult: (parsed) => _applyVoiceResult(parsed),
    );
  }

  void _applyVoiceResult(Map<String, dynamic> parsed) {
    final amount = parsed['amount'] as double?;
    if (amount != null && amount > 0) {
      _controller.amountController.text =
          ExpenseFormController.formatAmountForInput(amount);
    }
    final name = parsed['name'] as String?;
    if (name != null && name.isNotEmpty) {
      _controller.nameController.text = name;
    }
    final categoryKeyword = parsed['category'] as String?;
    if (categoryKeyword != null && _lifecycleManager.categories.isNotEmpty) {
      final match = _lifecycleManager.categories.firstWhere(
        (c) => c.name.toLowerCase() == categoryKeyword.toLowerCase(),
        orElse: () => _lifecycleManager.categories.first,
      );
      _controller.updateCategory(match);
    }
    final paidByName = parsed['paidBy'] as String?;
    if (paidByName != null && _lifecycleManager.participants.isNotEmpty) {
      final match = _lifecycleManager.participants.firstWhere(
        (p) => p.name.toLowerCase() == paidByName.toLowerCase(),
        orElse: () => _lifecycleManager.participants.first,
      );
      _controller.updatePaidBy(match);
    }
    final date = parsed['date'] as DateTime?;
    if (date != null) {
      _controller.updateDate(date);
    }
  }

  @override
  void dispose() {
    if (widget.config.onSaveCallbackChanged != null) {
      _controller.removeListener(_notifySaveCallbackWithContext);
    }
    widget.config.onVoiceCallbackChanged?.call(null);
    widget.config.onScanReceiptCallbackChanged?.call(null);
    widget.config.onScanReceiptFromGalleryCallbackChanged?.call(null);
    _orchestrator.dispose();
    _lifecycleManager.dispose();
    super.dispose();
  }
}

/// Where a receipt scan is: reading, nothing found, or failed.
enum _ScanLine { reading, noText, failed }

/// The receipt scan's line above the form's fields: a spinner while the
/// photo is read, then what went wrong (with × to close) if nothing could
/// be filled in. A good read leaves no line: the filled fields say it.
class _ReceiptScanLine extends StatelessWidget {
  final _ScanLine line;
  final VoidCallback onClose;

  const _ReceiptScanLine({required this.line, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final reading = line == _ScanLine.reading;
    final text = switch (line) {
      _ScanLine.reading => gloc.scanning_receipt,
      _ScanLine.noText => gloc.no_text_found,
      _ScanLine.failed => gloc.receipt_scan_error,
    };
    final color = line == _ScanLine.failed ? s.error : s.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 20,
              child: reading
                  ? CircularProgressIndicator(strokeWidth: 2, color: s.primary)
                  : Icon(
                      line == _ScanLine.failed
                          ? Icons.error_outline_rounded
                          : Icons.receipt_long_outlined,
                      size: 20,
                      color: color,
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ),
            if (!reading)
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close_rounded, size: 20),
                color: s.onSurfaceVariant,
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }
}
