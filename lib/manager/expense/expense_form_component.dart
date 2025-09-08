library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/expense_category.dart';
import '../../data/model/expense_details.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../data/model/expense_participant.dart';
import '../../data/model/expense_location.dart';
import '../../state/locale_notifier.dart';
import '../../widgets/material3_dialog.dart';
import 'expense_form/expense_form_basic_section.dart';
import 'expense_form/expense_form_advanced_section.dart';
import 'expense_form/expense_form_state.dart';
import 'expense_form/expense_form_validation.dart';
import 'expense_form/expense_form_actions_widget.dart';
import '../../themes/form_theme.dart';

class ExpenseFormComponent extends StatefulWidget {
  // When true shows date, location and note fields (full edit mode). In edit mode (initialExpense != null) these are always shown.
  final bool fullEdit;
  final ExpenseDetails? initialExpense;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(ExpenseDetails) onExpenseAdded;
  final Function(String) onCategoryAdded;
  final VoidCallback? onDelete; // optional delete action for edit mode
  final bool shouldAutoClose;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? newlyAddedCategory; // Nuova proprietà
  final String? groupTitle; // Titolo del gruppo per la riga azioni
  final String? currency; // Currency del gruppo
  final ScrollController?
  scrollController; // Controller for scrolling to focused fields

  const ExpenseFormComponent({
    super.key,
    this.initialExpense,
    required this.participants,
    required this.categories,
    required this.onExpenseAdded,
    required this.onCategoryAdded,
    this.onDelete,
    this.shouldAutoClose = true,
    this.tripStartDate,
    this.tripEndDate,
    this.newlyAddedCategory, // Nuova proprietà
    this.groupTitle,
    this.currency,
    this.fullEdit = false,
    this.scrollController,
  });

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormState _formState;
  double _lastKeyboardHeight = 0; // Track keyboard height changes

  // Keys for scrolling calculations
  final GlobalKey _amountFieldKey = GlobalKey();
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _locationFieldKey = GlobalKey();
  final GlobalKey _noteFieldKey = GlobalKey();

  // Getter for determining if extended fields should be shown
  bool get _shouldShowExtendedFields =>
      widget.fullEdit || widget.initialExpense != null || _formState.isExpanded;

  /// Scrolls to make the focused field visible when keyboard opens
  void _scrollToFocusedField() {
    if (widget.scrollController == null ||
        !widget.scrollController!.hasClients) {
      return;
    }

    // Delay to allow layout & keyboard metrics update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.scrollController == null ||
          !widget.scrollController!.hasClients) {
        return;
      }

      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final scrollController = widget.scrollController!;
      final focusedKey = _formState.amountFocus.hasFocus
          ? _amountFieldKey
          : _formState.nameFocus.hasFocus
          ? _nameFieldKey
          : _formState.locationFocus.hasFocus
          ? _locationFieldKey
          : _formState.noteFocus.hasFocus
          ? _noteFieldKey
          : _focusedExtendedFieldKey();
      if (focusedKey == null) {
        return;
      }
      final ctx = focusedKey.currentContext;
      if (ctx == null) {
        return;
      }

      try {
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox == null) {
          return;
        }
        final fieldTop = renderBox.localToGlobal(Offset.zero).dy;
        final fieldHeight = renderBox.size.height;
        final fieldBottom = fieldTop + fieldHeight;
        final screenHeight = MediaQuery.of(context).size.height;
        final availableHeight = screenHeight - keyboardHeight;

        if (fieldBottom > availableHeight) {
          final scrollOffset = fieldBottom - availableHeight + 50; // 50px padding
          final targetScrollPosition = scrollController.offset + scrollOffset;
          final maxScrollExtent = scrollController.position.maxScrollExtent;
          final finalPosition = targetScrollPosition.clamp(0.0, maxScrollExtent);

          scrollController.animateTo(
            finalPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        // Fallback: ignore errors during scroll calculation
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Monitor keyboard height changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final currentKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (currentKeyboardHeight != _lastKeyboardHeight) {
        _lastKeyboardHeight = currentKeyboardHeight;

        // If keyboard is opening and a field has focus, trigger scroll
        if (currentKeyboardHeight > 0 &&
            (_formState.amountFocus.hasFocus ||
                _formState.nameFocus.hasFocus ||
                _formState.locationFocus.hasFocus ||
                _formState.noteFocus.hasFocus)) {
          _scrollToFocusedField();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize the form state
    _formState = ExpenseFormState(
      initialExpense: widget.initialExpense,
      categories: widget.categories,
      participants: widget.participants,
    );

    // Setup focus listeners for scrolling
    _setupFocusListeners();

    // Setup amount controller listener for real-time parsing
    _formState.amountController.addListener(() {
      final parsed = ExpenseFormValidation.parseLocalizedAmount(_formState.amountController.text);
      _formState.setAmount(parsed);
    });

    // Setup name controller listener for dirty tracking
    _formState.nameController.addListener(() {
      _formState.markDirty();
    });

    // Setup note controller listener for dirty tracking
    _formState.noteController.addListener(() {
      _formState.markDirty();
    });

    // Handle newly added category selection
    if (widget.newlyAddedCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectCategoryByName(widget.newlyAddedCategory!);
      });
    }

    // Autofocus on amount after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _formState.amountFocus.requestFocus();
        _scrollToFocusedField();
      }
    });
  }

  void _setupFocusListeners() {
    _formState.amountFocus.addListener(() {
      if (_formState.amountFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });

    _formState.nameFocus.addListener(() {
      if (_formState.nameFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });

    _formState.locationFocus.addListener(() {
      if (_formState.locationFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });

    _formState.noteFocus.addListener(() {
      if (_formState.noteFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });
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
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(gloc.keep_editing),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(gloc.discard),
              ),
            ],
          ),
        ) ??
        false;
  }

  bool _isFormValid() {
    return _formState.isFormValid();
  }

  Future<void> _selectCategoryByName(String categoryName) async {
    // Wait for the category to be added to the list
    await Future.delayed(const Duration(milliseconds: 50));
    final found = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    _formState.setCategory(found);
    
    // Update the state's category list
    _formState.updateCategories(widget.categories);
    
    // Wait again to ensure the state has settled
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    _formState.setCategory(foundAfter);
  }

  void _saveExpense() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      // Mark all fields as touched to show validation errors
      setState(() {
        // This will be handled by the form state
      });
      return;
    }
    if (!_isFormValid()) return;
    
    final nameValue = _formState.nameController.text.trim();
    final expense = ExpenseDetails(
      amount: _formState.amount ?? ExpenseFormValidation.parseLocalizedAmount(_formState.amountController.text) ?? 0,
      paidBy: _formState.paidBy ?? ExpenseParticipant(name: ''),
      category: _formState.category ??
          (_formState.categories.isNotEmpty
              ? _formState.categories.first
              : ExpenseCategory(name: '', id: '', createdAt: DateTime.now())),
      date: _formState.date ?? DateTime.now(),
      note: _formState.noteController.text.trim().isNotEmpty
          ? _formState.noteController.text.trim()
          : null,
      name: nameValue,
      location: _formState.location,
    );
    widget.onExpenseAdded(expense);
    _formState.clearDirty();
    if (widget.shouldAutoClose && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => _buildRoot(context);

  Widget _buildRoot(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final gloc = gen.AppLocalizations.of(context);
    final smallStyle = Theme.of(context).textTheme.bodyMedium;
    
    return ChangeNotifierProvider.value(
      value: _formState,
      child: PopScope(
        canPop: !_formState.isDirty,
        onPopInvokedWithResult: _handlePop,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(),
              ExpenseFormBasicSection(
                participants: widget.participants,
                categories: widget.categories,
                onCategoryAdded: widget.onCategoryAdded,
                currency: widget.currency,
                shouldShowExtendedFields: _shouldShowExtendedFields,
                textStyle: smallStyle,
              ),
              if (_shouldShowExtendedFields)
                ExpenseFormAdvancedSection(
                  tripStartDate: widget.tripStartDate,
                  tripEndDate: widget.tripEndDate,
                  locale: locale,
                  textStyle: smallStyle,
                  locationFieldKey: _locationFieldKey,
                  noteFieldKey: _noteFieldKey,
                ),
              _buildDivider(context),
              _buildActionsRow(gloc, smallStyle),
            ],
          ),
        ),
      ),
    );
  }

  /// Intestazione con il titolo del gruppo (solo quando mostriamo i campi estesi, se presente)
  Widget _buildGroupHeader() {
    if (!(_shouldShowExtendedFields && widget.groupTitle != null)) {
      return const SizedBox.shrink();
    }
    final gloc = gen.AppLocalizations.of(context);
    final title = widget.groupTitle!.trim();
    if (title.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prefixStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    );
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
      overflow: TextOverflow.ellipsis,
    );
    return Semantics(
      container: true,
      header: true,
      label: '${gloc.in_group_prefix} $title',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Tooltip(
                message: title,
                waitDuration: const Duration(milliseconds: 400),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${gloc.in_group_prefix} ',
                        style: prefixStyle,
                      ),
                      TextSpan(text: title, style: titleStyle),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (_formState.isDirty) {
      final navigator = Navigator.of(context);
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && navigator.canPop()) navigator.pop();
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

  Widget _buildActionsRow(gen.AppLocalizations gloc, TextStyle? style) =>
      ExpenseFormActionsWidget(
        onSave: _isFormValid() ? _saveExpense : null,
        isEdit: widget.initialExpense != null,
        onDelete: widget.initialExpense != null ? widget.onDelete : null,
        textStyle: style,
        showExpandButton:
            !(widget.fullEdit || widget.initialExpense != null || _formState.isExpanded),
        onExpand: () {
          _formState.setExpanded(true);
        },
      );

  GlobalKey? _focusedExtendedFieldKey() {
    // Try to detect focus indirectly for location / note using primary focus
    final currentFocus = FocusManager.instance.primaryFocus;
    if (currentFocus == null) return null;
    // Heuristic: match by widget type in context chain
    if (_locationFieldKey.currentContext != null &&
        _locationFieldKey.currentContext!.findRenderObject() != null &&
        _contextContainsFocus(
          _locationFieldKey.currentContext!,
          currentFocus,
        )) {
      return _locationFieldKey;
    }
    if (_noteFieldKey.currentContext != null &&
        _noteFieldKey.currentContext!.findRenderObject() != null &&
        _contextContainsFocus(_noteFieldKey.currentContext!, currentFocus)) {
      return _noteFieldKey;
    }
    return null;
  }

  bool _contextContainsFocus(BuildContext ctx, FocusNode focus) {
    // Walk up the focus ancestors
    FocusNode? node = focus;
    while (node != null) {
      if (node.context == ctx) return true;
      node = node.parent;
    }
    return false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _formState.dispose();
    super.dispose();
  }
}