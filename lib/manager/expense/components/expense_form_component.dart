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
import '../coordination/route_settled.dart';
import 'expense_form_config.dart';
import 'expense_form_lifecycle_manager.dart';
import 'expense_form_orchestrator.dart';
import 'expense_form_fields.dart';
import 'expense_form_extended_fields.dart';
import 'expense_form_compact_header.dart';
import '../../../services/receipt_scanner_service.dart';
import '../widgets/receipt_scan_line.dart';

/// The expense form: amount, name, who paid and category, then the details,
/// as set by [ExpenseFormConfig].
class ExpenseFormComponent extends StatefulWidget {
  final ExpenseFormConfig config;

  const ExpenseFormComponent({super.key, required this.config});

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  bool _amountLocalized = false;
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormLifecycleManager _lifecycleManager;
  late ExpenseFormOrchestrator _orchestrator;
  late ExpenseFormController _controller;

  // Receipt scanner
  final _receiptScanner = ReceiptScannerService();

  /// The receipt scan's line above the fields, while there's one to show.
  ReceiptScanStatus? _scanLine;
  final _imagePicker = ImagePicker();

  /// The quick-add sheet: no details section, just "More details" opening
  /// the full page (and a scanned receipt's photo, if any).
  bool get _isQuickAdd =>
      !widget.config.fullEdit &&
      !widget.config.isEditMode &&
      !_controller.isExpanded &&
      widget.config.onExpand != null;

  /// Editing a saved expense (no voice input or receipt scan then).
  bool get _isEdit => widget.config.initialExpense?.id.isNotEmpty ?? false;

  /// Voice input is offered when adding, not when editing or read-only.
  bool get _showVoice => !_isEdit && !widget.config.isReadOnly;

  String get _decimalSeparator =>
      decimalSeparatorFor(Localizations.localeOf(context));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_amountLocalized) return;
    _amountLocalized = true;
    // The controller fills the field before the locale can be read. Same
    // value for it, so opening an expense doesn't mark the form as changed.
    final amount = _controller.amountController;
    final separator = decimalSeparatorFor(Localizations.localeOf(context));
    if (amount.text.contains('.') && separator != '.') {
      amount.text = amount.text.replaceAll('.', separator);
    }
  }

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
        if (!widget.config.isEditMode && widget.config.autofocusAmount) {
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

    // A focused field scrolls into view once the keyboard has started rising.
    final fields = {
      _controller.amountFocus: _controller.amountFieldKey,
      _controller.nameFocus: _controller.nameFieldKey,
      _controller.locationFocus: _controller.locationFieldKey,
      _controller.noteFocus: _controller.noteFieldKey,
    };
    fields.forEach((focus, key) {
      focus.addListener(() {
        if (!focus.hasFocus) return;
        Future.delayed(const Duration(milliseconds: 200), () {
          scrollCoordinator.scrollToField(key);
        });
      });
    });
  }

  void _notifySaveCallbackWithContext() {
    // Create a proper callback with context access
    final isValid = _controller.isFormValid;
    final callback = isValid ? () => _orchestrator.saveExpense(context) : null;
    widget.config.onSaveCallbackChanged?.call(callback);
  }

  void _notifyVoiceCallback() {
    final callback = _showVoice ? () => _showVoiceCapture(context) : null;
    widget.config.onVoiceCallbackChanged?.call(callback);
  }

  void _notifyScanReceiptCallback() {
    final canScan =
        _receiptScanner.isAvailable && !_isEdit && !widget.config.isReadOnly;
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
    final locale =
        LocaleNotifier.of(context)?.locale ?? LocalePreferences.deviceDefault();

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
            if (_scanLine case final status?)
              ReceiptScanLine(
                status: status,
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
  /// ([ReceiptScanLine]); a good read just fills the fields. A refused
  /// camera or photos permission opens [showPermissionDeniedDialog].
  Future<void> _scanReceipt({required ImageSource source}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null || !mounted) return;

      setState(() => _scanLine = ReceiptScanStatus.reading);

      final imageFile = File(pickedFile.path);
      final result = await _receiptScanner.scanReceipt(imageFile);

      if (!mounted) return;

      final amount = result['amount'] as double?;
      final description = result['description'] as String?;

      if (amount == null && description == null) {
        setState(() => _scanLine = ReceiptScanStatus.noText);
        return;
      }
      setState(() => _scanLine = null);

      _controller.fillAmountAndName(
        amount: amount,
        name: description,
        decimalSeparator: _decimalSeparator,
      );
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
        setState(() => _scanLine = ReceiptScanStatus.failed);
      }
    } catch (e) {
      if (mounted) setState(() => _scanLine = ReceiptScanStatus.failed);
    }
  }

  Widget _buildActionsRow() {
    final canScan =
        _receiptScanner.isAvailable && widget.config.initialExpense == null;
    return ExpenseFormActionsWidget(
      onSave: _controller.isFormValid
          ? () => _orchestrator.saveExpense(context)
          : null,
      isFormValid: _controller.isFormValid,
      isEdit: _isEdit,
      onDelete: widget.config.hasDeleteAction
          ? () => _orchestrator.deleteExpense(context)
          : null,
      showExpandButton: false,
      onExpand: null,
      onScanReceipt: canScan
          ? () => _scanReceipt(source: ImageSource.camera)
          : null,
      onScanReceiptFromGallery: canScan
          ? () => _scanReceipt(source: ImageSource.gallery)
          : null,
      showVoiceButton: _showVoice,
      onVoiceTap: _showVoice ? () => _showVoiceCapture(context) : null,
    );
  }

  Future<void> _showVoiceCapture(BuildContext context) async {
    final locale =
        LocaleNotifier.of(context)?.locale ?? LocalePreferences.deviceDefault();
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
    _controller.fillAmountAndName(
      amount: parsed['amount'] as double?,
      name: parsed['name'] as String?,
      decimalSeparator: _decimalSeparator,
    );
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
