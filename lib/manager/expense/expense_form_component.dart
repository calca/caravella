library;

import 'package:flutter/material.dart';
import '../../data/model/expense_category.dart';
import '../../data/model/expense_details.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../data/model/expense_participant.dart';
import '../../data/model/expense_location.dart';
import '../../state/locale_notifier.dart';
import '../../widgets/material3_dialog.dart';
import 'expense_form/amount_input_widget.dart';
import 'expense_form/participant_selector_widget.dart';
import 'expense_form/category_selector_widget.dart';
import 'expense_form/date_selector_widget.dart';
import 'expense_form/note_input_widget.dart';
import 'expense_form/location_input_widget.dart';
import 'expense_form/expense_form_actions_widget.dart';
import 'expense_form/category_dialog.dart';
import 'expense_form_state.dart';

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
  static const double _rowSpacing = 16.0;
  final _formKey = GlobalKey<FormState>();
  late ExpenseFormState _formState;
  final _amountController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  late List<ExpenseCategory> _categories; // Lista locale delle categorie
  bool _initializing = true; // traccia se siamo in fase di inizializzazione
  double _lastKeyboardHeight = 0; // Track keyboard height changes

  // Keys for scrolling calculations
  final GlobalKey _amountFieldKey = GlobalKey();
  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _locationFieldKey = GlobalKey();
  final GlobalKey _noteFieldKey = GlobalKey();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();

  // Stato per espansione del form (solo quando fullEdit è false inizialmente)
  bool _isExpanded = false;

  // Getter per determinare se mostrare i campi estesi
  bool get _shouldShowExtendedFields =>
      widget.fullEdit || widget.initialExpense != null || _isExpanded;
  // Scroll controller callback per CategorySelectorWidget
  // Removed _scrollToCategoryEnd: no longer needed with new category selector bottom sheet.

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
      final focusedKey = _amountFocus.hasFocus
          ? _amountFieldKey
          : _nameFocus.hasFocus
          ? _nameFieldKey
          : _locationFocus.hasFocus
          ? _locationFieldKey
          : _noteFocus.hasFocus
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
        final availableBottom = screenHeight - keyboardHeight - 12; // padding
        double scrollDelta = 0;

        // If bottom obscured by keyboard -> scroll down just enough
        if (keyboardHeight > 0 && fieldBottom > availableBottom) {
          scrollDelta = fieldBottom - availableBottom + 8; // extra offset
        }
        // If top too high (negative) -> scroll up
        const topMargin = 24.0; // desired margin from top when focusing
        if (fieldTop < topMargin) {
          scrollDelta = fieldTop - topMargin; // negative value scrolls up
        }

        if (scrollDelta.abs() > 4) {
          // threshold
          final target = (scrollController.offset + scrollDelta).clamp(
            0.0,
            scrollController.position.maxScrollExtent,
          );
          if ((target - scrollController.offset).abs() > 2) {
            scrollController.animateTo(
              target,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        }
      } catch (e) {
        debugPrint('Scroll adjust error: $e');
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
            (_amountFocus.hasFocus ||
                _nameFocus.hasFocus ||
                _locationFocus.hasFocus ||
                _noteFocus.hasFocus)) {
          _scrollToFocusedField();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _categories = List.from(widget.categories); // Copia della lista originale
    _formState = ExpenseFormState(categories: _categories);
    
    if (widget.initialExpense != null) {
      _formState.initializeFromExpense(widget.initialExpense!);
      // Se amount è null o 0, lascia il campo vuoto
      _amountController.text = (widget.initialExpense!.amount == 0)
          ? ''
          : widget.initialExpense!.amount.toString();
    } else {
      _formState.initializeForNewExpense();
      // Preseleziona il primo elemento di paidBy e category se disponibili
      _formState.paidBy = widget.participants.isNotEmpty
          ? widget.participants.first
          : ExpenseParticipant(name: '');
      _formState.category = widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000));
    }

    // Autofocus su amount dopo primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountFocus.requestFocus();
        _scrollToFocusedField();
      }
    });

    // Add focus listeners to trigger scrolling when fields receive focus
    _amountFocus.addListener(() {
      if (_amountFocus.hasFocus) {
        // Delay to ensure keyboard is starting to appear
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });

    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        // Delay to ensure keyboard is starting to appear
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });
    _locationFocus.addListener(() {
      if (_locationFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });
    _noteFocus.addListener(() {
      if (_noteFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToFocusedField();
        });
      }
    });
    // Listener per aggiornare _amount in tempo reale (mantiene valore anche quando perde focus)
    _amountController.addListener(() {
      final parsed = _parseLocalizedAmount(_amountController.text);
      if (parsed != _formState.amount) {
        setState(() {
          _formState.amount = parsed;
          _formState.amountTouched = true;
        });
      }
    });

    // Listener per aggiornare lo stato quando il nome cambia
    _formState.nameController.addListener(() {
      if (!_initializing) {
        setState(() {});
      }
    });

    // Mark initialization as complete after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializing = false;
    });
  }

  double? _parseLocalizedAmount(String input) {
    if (input.isEmpty) return null;
    final cleaned = input.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleaned);
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

  bool _isFormValid() {
    return _formState.isFormValid();
  }

  // Widget per indicatori di stato - versione minimalista
  Widget _buildFieldWithStatus(Widget field, bool isValid, bool isTouched) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // Solo sfondo colorato se c'è un errore
        color: isTouched && !isValid
            ? Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: 0.08)
            : null,
      ),
      child: field,
    );
  }

  void _saveExpense() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      _formState.markAllFieldsTouched();
      setState(() {});
      return;
    }
    if (!_isFormValid()) return;
    final nameValue = _formState.nameController.text.trim();
    final expense = ExpenseDetails(
      amount: _formState.amount ?? _parseLocalizedAmount(_amountController.text) ?? 0,
      paidBy: _formState.paidBy ?? ExpenseParticipant(name: ''),
      category:
          _formState.category ??
          (_categories.isNotEmpty
              ? _categories.first
              : ExpenseCategory(name: '', id: '', createdAt: DateTime.now())),
      date: _formState.date ?? DateTime.now(),
      note: _formState.noteController.text.trim().isNotEmpty
          ? _formState.noteController.text.trim()
          : null,
      name: nameValue,
      location: _formState.location,
    );
    widget.onExpenseAdded(expense);
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
    return PopScope(
      canPop: !_formState.hasActualChanges,
      onPopInvokedWithResult: _handlePop,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(),
            _buildAmountField(gloc, smallStyle),
            _spacer(),
            _buildNameField(gloc, smallStyle),
            _spacer(),
            _buildParticipantCategorySection(smallStyle),
            _buildExtendedFields(locale, smallStyle),
            _buildDivider(context),
            _buildActionsRow(gloc, smallStyle),
          ],
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
    if (_formState.hasActualChanges) {
      final navigator = Navigator.of(context);
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && navigator.canPop()) navigator.pop();
    }
  }

  Widget _spacer() => const SizedBox(height: _rowSpacing);

  Widget _buildAmountField(gen.AppLocalizations gloc, TextStyle? style) =>
      KeyedSubtree(
        key: _amountFieldKey,
        child: _buildFieldWithStatus(
          AmountInputWidget(
            controller: _amountController,
            focusNode: _amountFocus,
            categories: _categories,
            label: gloc.amount,
            currency: widget.currency,
            validator: (v) {
              final parsed = _parseLocalizedAmount(v ?? '');
              if (parsed == null || parsed <= 0) return gloc.invalid_amount;
              return null;
            },
            onSaved: (v) {},
            onSubmitted: _saveExpense,
            textStyle: style,
          ),
          _formState.isAmountValid,
          _formState.amountTouched,
        ),
      );

  Widget _buildNameField(gen.AppLocalizations gloc, TextStyle? style) =>
      KeyedSubtree(
        key: _nameFieldKey,
        child: _buildFieldWithStatus(
          AmountInputWidget(
            controller: _formState.nameController,
            focusNode: _nameFocus,
            label: gloc.expense_name,
            leading: Icon(
              Icons.description_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? gloc.enter_title : null,
            onSaved: (v) {},
            onSubmitted: () {},
            isText: true,
            textStyle: style,
          ),
          _formState.nameController.text.trim().isNotEmpty,
          _formState.amountTouched,
        ),
      );

  Widget _buildParticipantCategorySection(TextStyle? style) {
    if (_shouldShowExtendedFields) {
      return Column(
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: widget.participants.map((p) => p.name).toList(),
              selectedParticipant: _formState.paidBy?.name,
              onParticipantSelected: _onParticipantSelected,
              textStyle: style,
              fullEdit: true,
            ),
            _formState.isPaidByValid,
            _formState.paidByTouched,
          ),
          _spacer(),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: _categories,
              selectedCategory: _formState.category,
              onCategorySelected: _onCategorySelected,
              onAddCategory: _onAddCategory,
              onAddCategoryInline: _onAddCategoryInline,
              textStyle: style,
              fullEdit: true,
            ),
            _formState.isCategoryValid,
            _formState.categoryTouched,
          ),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: widget.participants.map((p) => p.name).toList(),
              selectedParticipant: _formState.paidBy?.name,
              onParticipantSelected: _onParticipantSelected,
              textStyle: style,
              fullEdit: false,
            ),
            _formState.isPaidByValid,
            _formState.paidByTouched,
          ),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: _categories,
              selectedCategory: _formState.category,
              onCategorySelected: _onCategorySelected,
              onAddCategory: _onAddCategory,
              onAddCategoryInline: _onAddCategoryInline,
              textStyle: style,
              fullEdit: false,
            ),
            _formState.isCategoryValid,
            _formState.categoryTouched,
          ),
        ],
      ),
    );
  }

  // (Expand button moved into ExpenseFormActionsWidget)

  void _onParticipantSelected(String selectedName) {
    setState(() {
      _formState.paidBy = widget.participants.firstWhere(
        (p) => p.name == selectedName,
        orElse: () => widget.participants.isNotEmpty
            ? widget.participants.first
            : ExpenseParticipant(name: ''),
      );
      _formState.paidByTouched = true;
    });
  }

  void _onCategorySelected(ExpenseCategory? selected) {
    setState(() {
      _formState.category = selected;
      _formState.categoryTouched = true;
    });
  }

  Future<void> _onAddCategory() async {
    final newCategoryName = await CategoryDialog.show(context: context);
    if (newCategoryName != null && newCategoryName.isNotEmpty) {
      widget.onCategoryAdded(newCategoryName);
      final found = widget.categories.firstWhere(
        (c) => c.name == newCategoryName,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      setState(() {
        if (!_categories.contains(found)) {
          _categories.add(found);
          _formState.category = found;
          _formState.categoryTouched = true;
        }
      });
      await Future.delayed(const Duration(milliseconds: 100));
      final foundAfter = widget.categories.firstWhere(
        (c) => c.name == newCategoryName,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      setState(() {
        _categories = List.from(widget.categories);
        _formState.category = foundAfter;
        _formState.categoryTouched = true;
      });
    }
  }

  Future<void> _onAddCategoryInline(String categoryName) async {
    widget.onCategoryAdded(categoryName);
    // Wait a bit for the category to be added to the widget.categories list
    await Future.delayed(const Duration(milliseconds: 100));
    final found = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    setState(() {
      if (!_categories.contains(found)) {
        _categories.add(found);
      }
      _formState.category = found;
      _formState.categoryTouched = true;
    });
    // Wait again to ensure the state has settled
    await Future.delayed(const Duration(milliseconds: 100));
    final foundAfter = widget.categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
    );
    setState(() {
      _categories = List.from(widget.categories);
      _formState.category = foundAfter;
      _formState.categoryTouched = true;
    });
  }

  Widget _buildExtendedFields(String locale, TextStyle? style) {
    if (!_shouldShowExtendedFields) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacer(),
        DateSelectorWidget(
          selectedDate: _formState.date,
          tripStartDate: widget.tripStartDate,
          tripEndDate: widget.tripEndDate,
          onDateSelected: (picked) => setState(() {
            _formState.date = picked;
          }),
          locale: locale,
          textStyle: style,
        ),
        _spacer(),
        KeyedSubtree(
          key: _locationFieldKey,
          child: LocationInputWidget(
            initialLocation: _formState.location,
            textStyle: style,
            onLocationChanged: (location) => setState(() {
              _formState.location = location;
            }),
            externalFocusNode: _locationFocus,
          ),
        ),
        _spacer(),
        KeyedSubtree(
          key: _noteFieldKey,
          child: NoteInputWidget(
            controller: _formState.noteController,
            textStyle: style,
            focusNode: _noteFocus,
          ),
        ),
      ],
    );
  }

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

  Widget _buildDivider(BuildContext context) {
    if (_shouldShowExtendedFields) {
      // In full edit mode: reserve vertical space but no visual divider
      return const SizedBox(height: 24);
    }
    return Divider(
      height: 24,
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
            !(widget.fullEdit || widget.initialExpense != null || _isExpanded),
        onExpand: () {
          setState(() {
            _isExpanded = true;
          });
        },
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _amountFocus.dispose();
    _nameFocus.dispose();
    _formState.dispose();
    _locationFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }
}
