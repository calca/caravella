library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
import 'expense_form_config.dart';
import 'expense_form_lifecycle_manager.dart';
import 'expense_form_orchestrator.dart';
import 'expense_form_fields.dart';
import 'expense_form_extended_fields.dart';
import 'expense_form_compact_header.dart';
import '../../../data/services/receipt_scanner_service.dart';

/// Main expense form component - refactored to use config object pattern
///
/// This component now accepts a single ExpenseFormConfig parameter instead
/// of 43 individual parameters, improving maintainability and readability.
class ExpenseFormComponent extends StatefulWidget {
  final ExpenseFormConfig config;

  const ExpenseFormComponent({super.key, required this.config});

  /// Factory constructor for backward compatibility - creating new expense
  factory ExpenseFormComponent.create({
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required String groupId,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    Function(String)? onParticipantAdded,
    required bool autoLocationEnabled,
    String? groupTitle,
    String? currency,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    String? newlyAddedCategory,
    bool fullEdit = false,
    ScrollController? scrollController,
    void Function(ExpenseFormState)? onExpand,
    bool showGroupHeader = true,
    bool showActionsRow = true,
    void Function(bool)? onFormValidityChanged,
    void Function(VoidCallback?)? onSaveCallbackChanged,
    void Function(VoidCallback?)? onVoiceCallbackChanged,
  }) {
    return ExpenseFormComponent(
      config: ExpenseFormConfig.create(
        participants: participants,
        categories: categories,
        groupId: groupId,
        onExpenseAdded: onExpenseAdded,
        onCategoryAdded: onCategoryAdded,
        onParticipantAdded: onParticipantAdded,
        autoLocationEnabled: autoLocationEnabled,
        groupTitle: groupTitle,
        currency: currency,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
        newlyAddedCategory: newlyAddedCategory,
        fullEdit: fullEdit,
        scrollController: scrollController,
        onExpand: onExpand,
        showGroupHeader: showGroupHeader,
        showActionsRow: showActionsRow,
        onFormValidityChanged: onFormValidityChanged,
        onSaveCallbackChanged: onSaveCallbackChanged,
        onVoiceCallbackChanged: onVoiceCallbackChanged,
      ),
    );
  }

  /// Factory constructor for backward compatibility - editing existing expense
  factory ExpenseFormComponent.edit({
    required ExpenseDetails initialExpense,
    required List<ExpenseParticipant> participants,
    required List<ExpenseCategory> categories,
    required String groupId,
    required Function(ExpenseDetails) onExpenseAdded,
    required Function(String) onCategoryAdded,
    Function(String)? onParticipantAdded,
    required bool autoLocationEnabled,
    VoidCallback? onDelete,
    String? groupTitle,
    String? currency,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    bool shouldAutoClose = true,
    ScrollController? scrollController,
  }) {
    return ExpenseFormComponent(
      config: ExpenseFormConfig.edit(
        initialExpense: initialExpense,
        participants: participants,
        categories: categories,
        groupId: groupId,
        onExpenseAdded: onExpenseAdded,
        onCategoryAdded: onCategoryAdded,
        onParticipantAdded: onParticipantAdded,
        autoLocationEnabled: autoLocationEnabled,
        onDelete: onDelete,
        groupTitle: groupTitle,
        currency: currency,
        tripStartDate: tripStartDate,
        tripEndDate: tripEndDate,
        shouldAutoClose: shouldAutoClose,
        scrollController: scrollController,
      ),
    );
  }

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
  /// Minimum negative Y velocity (logical pixels/second) required to trigger
  /// compact-to-full edit expansion. In Flutter coordinates, upward swipes
  /// produce negative vertical velocity values.
  static const double _swipeUpExpandVelocityThreshold = -250;

  final _formKey = GlobalKey<FormState>();
  late ExpenseFormLifecycleManager _lifecycleManager;
  late ExpenseFormOrchestrator _orchestrator;
  late ExpenseFormController _controller;

  // Receipt scanner
  final _receiptScanner = ReceiptScannerService();
  final _imagePicker = ImagePicker();

  // Getter per determinare se mostrare i campi estesi
  bool get _shouldShowExtendedFields =>
      widget.config.fullEdit ||
      widget.config.initialExpense != null ||
      _controller.isExpanded;

  bool get _canSwipeExpandToFullEdit =>
      !widget.config.fullEdit &&
      widget.config.initialExpense == null &&
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

        // Autofocus after first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _controller.amountFocus.requestFocus();
            _lifecycleManager.scrollCoordinator?.scrollToField(
              _controller.amountFieldKey,
            );
          }
        });
      },
    );

    // Initialize synchronously - no loader needed!
    _lifecycleManager.initializeSync(context);
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
    final canScan = !isEdit && !widget.config.isReadOnly;
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
            icon: Icon(
              Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            title: Text(gloc.discard_changes_title),
            content: Text(gloc.discard_changes_message),
            actions: [
              Material3DialogActions.cancel(ctx, gloc.cancel),
              Material3DialogActions.destructive(
                ctx,
                gloc.discard,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final gloc = gen.AppLocalizations.of(context);

    return PopScope(
      canPop: !_controller.state.isDirty,
      onPopInvokedWithResult: _handlePop,
      child: Semantics(
        customSemanticsActions: _canSwipeExpandToFullEdit
            ? {
                CustomSemanticsAction(label: gloc.expand_form):
                    _orchestrator.expand,
              }
            : const {},
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragEnd: (details) {
            if (_canSwipeExpandToFullEdit &&
                (details.primaryVelocity ?? 0) <
                    _swipeUpExpandVelocityThreshold) {
              _orchestrator.expand();
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpenseFormCompactHeader(
                  groupTitle: widget.config.groupTitle,
                  showGroupHeader: widget.config.showGroupHeader,
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
                  fullEdit: widget.config.fullEdit,
                  autoLocationEnabled: widget.config.autoLocationEnabled,
                  location: _controller.state.location,
                  isRetrievingLocation: _lifecycleManager.isRetrievingLocation,
                  onClearLocation: _clearLocation,
                  currency: widget.config.currency,
                  onSaveExpense: () => _orchestrator.saveExpense(context),
                  isInitialExpense: widget.config.initialExpense != null,
                  isReadOnly: widget.config.isReadOnly,
                ),
                if (_shouldShowExtendedFields)
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => ExpenseFormExtendedFields(
                      controller: _controller,
                      tripStartDate: widget.config.tripStartDate,
                      tripEndDate: widget.config.tripEndDate,
                      locale: locale,
                      groupId: widget.config.groupId,
                      groupName: widget.config.groupTitle ?? 'Unnamed',
                      autoLocationEnabled: widget.config.autoLocationEnabled,
                      isInitialExpense: widget.config.initialExpense != null,
                      isFormValid: _controller.isFormValid,
                      onSaveExpense: () => _orchestrator.saveExpense(context),
                      isReadOnly: widget.config.isReadOnly,
                    ),
                  ),
                if (widget.config.showActionsRow) ...[
                  _buildDivider(context),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => _buildActionsRow(),
                  ),
                ],
              ],
            ),
          ),
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

  void _clearLocation() {
    _controller.updateLocation(null);
    _controller.setLocationRetrieving(false);
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
  Future<void> _scanReceipt({required ImageSource source}) async {
    final gloc = gen.AppLocalizations.of(context);

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile == null || !mounted) return;

      if (mounted) {
        AppToast.show(
          context,
          gloc.scanning_receipt,
          duration: const Duration(seconds: 2),
        );
      }

      final imageFile = File(pickedFile.path);
      final result = await _receiptScanner.scanReceipt(imageFile);

      if (!mounted) return;

      final amount = result['amount'] as double?;
      final description = result['description'] as String?;

      if (amount == null && description == null) {
        if (mounted) {
          AppToast.show(
            context,
            gloc.no_text_found,
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      if (amount != null) {
        _controller.amountController.text = amount.toString();
      }
      if (description != null && description.isNotEmpty) {
        _controller.nameController.text = description;
      }
      _controller.markDirty();

      if (mounted) {
        AppToast.show(
          context,
          gloc.receipt_scanned,
          type: ToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isPermissionDenied =
          e.code == 'camera_access_denied' || e.code == 'photo_access_denied';
      AppToast.show(
        context,
        isPermissionDenied
            ? gloc.receipt_scan_permission_denied
            : gloc.receipt_scan_error,
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          gloc.receipt_scan_error,
          type: ToastType.error,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Widget _buildDivider(BuildContext context) {
    if (_shouldShowExtendedFields) {
      // In full edit mode: reserve vertical space but no visual divider
      return const SizedBox(height: FormTheme.sectionSpacing);
    }
    return Divider(
      height: FormTheme.sectionSpacing,
      thickness: 1,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
    );
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
      onScanReceipt: widget.config.initialExpense == null
          ? () => _scanReceipt(source: ImageSource.camera)
          : null,
      onScanReceiptFromGallery: widget.config.initialExpense == null
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
      _controller.amountController.text = amount.toString();
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
