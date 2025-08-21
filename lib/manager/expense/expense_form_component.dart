library;

import 'package:flutter/material.dart';
import '../../data/expense_category.dart';
import '../../data/expense_details.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../data/expense_participant.dart';
import '../../data/expense_location.dart';
import '../../state/locale_notifier.dart';
import 'expense_form/amount_input_widget.dart';
import 'expense_form/participant_selector_widget.dart';
import 'expense_form/category_selector_widget.dart';
import 'expense_form/date_selector_widget.dart';
import 'expense_form/note_input_widget.dart';
import 'expense_form/location_input_widget.dart';
import 'expense_form/expense_form_actions_widget.dart';
import 'expense_form/category_dialog.dart';

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
  final ScrollController? scrollController; // Controller for scrolling to focused fields

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

class _ExpenseFormComponentState extends State<ExpenseFormComponent> with WidgetsBindingObserver {
  static const double _rowSpacing = 16.0;
  final _formKey = GlobalKey<FormState>();
  ExpenseCategory? _category;
  double? _amount;
  ExpenseParticipant? _paidBy;
  DateTime? _date;
  ExpenseLocation? _location;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  late List<ExpenseCategory> _categories; // Lista locale delle categorie
  bool _isDirty = false; // traccia modifiche non salvate
  bool _initializing = true; // traccia se siamo in fase di inizializzazione
  double _lastKeyboardHeight = 0; // Track keyboard height changes

  // Stato per validazione in tempo reale
  bool _amountTouched = false;
  bool _paidByTouched = false;
  bool _categoryTouched = false;

  // Getters per stato dei campi
  bool get _isAmountValid => _amount != null && _amount! > 0;
  bool get _isPaidByValid => _paidBy != null;
  bool get _isCategoryValid => _categories.isEmpty || _category != null;

  // Scroll controller callback per CategorySelectorWidget
  // Removed _scrollToCategoryEnd: no longer needed with new category selector bottom sheet.

  /// Scrolls to make the focused field visible when keyboard opens
  void _scrollToFocusedField() {
    if (widget.scrollController == null || !widget.scrollController!.hasClients) return;
    
    // Use a short delay to ensure the keyboard animation has started
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || widget.scrollController == null || !widget.scrollController!.hasClients) return;
      
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      if (keyboardHeight == 0) return;
      
      try {
        // Scroll to ensure focused field is visible above keyboard
        final currentScrollOffset = widget.scrollController!.offset;
        final maxScrollExtent = widget.scrollController!.position.maxScrollExtent;
        
        // Calculate required scroll to bring focused field into view
        // We want to position focused field in the upper part of visible area
        const fieldBuffer = 120.0; // Extra space above focused field for better visibility
        final targetScrollOffset = (currentScrollOffset + fieldBuffer).clamp(0.0, maxScrollExtent);
        
        // Only scroll if there's a meaningful change
        if ((targetScrollOffset - currentScrollOffset).abs() > 10.0) {
          widget.scrollController!.animateTo(
            targetScrollOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } catch (e) {
        // Gracefully handle any scrolling errors
        debugPrint('Error during scroll-to-focus: $e');
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
        if (currentKeyboardHeight > 0 && (_amountFocus.hasFocus || _nameFocus.hasFocus)) {
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
    if (widget.initialExpense != null) {
      _category = widget.categories.firstWhere(
        (c) => c.id == widget.initialExpense!.category.id,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      _amount = widget.initialExpense!.amount;
      _paidBy = widget.initialExpense!.paidBy;
      _date = widget.initialExpense!.date;
      _location = widget.initialExpense!.location;
      _nameController.text = widget.initialExpense!.name ?? '';
      // Se amount è null o 0, lascia il campo vuoto
      _amountController.text = (widget.initialExpense!.amount == 0)
          ? ''
          : widget.initialExpense!.amount.toString();
      _noteController.text = widget.initialExpense!.note ?? '';
    } else {
      _date = DateTime.now();
      _nameController.text = '';
      _location = null;
      // Preseleziona il primo elemento di paidBy e category se disponibili
      _paidBy = widget.participants.isNotEmpty
          ? widget.participants.first
          : ExpenseParticipant(name: '');
      _category = widget.categories.isNotEmpty
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
    // Listener per aggiornare _amount in tempo reale (mantiene valore anche quando perde focus)
    _amountController.addListener(() {
      final parsed = _parseLocalizedAmount(_amountController.text);
      if (parsed != _amount) {
        setState(() {
          _amount = parsed;
          _amountTouched = true;
          if (!_initializing) {
            _isDirty = true;
          }
        });
      }
    });

    // Listener per aggiornare lo stato quando il nome cambia
    _nameController.addListener(() {
      if (!_initializing) {
        setState(() {
          _isDirty = true;
        });
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
          builder: (ctx) => AlertDialog(
            title: Text(gloc.discard_changes_title),
            content: Text(gloc.discard_changes_message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(gloc.cancel),
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
    // SET MINIMO DI INFORMAZIONI NECESSARIE per abilitare il pulsante:
    // 1. Importo valido (> 0)
    bool hasPaidBy = _paidBy != null && _paidBy!.name.isNotEmpty;

    // 2. Categoria selezionata (solo se esistono categorie)
    bool hasCategoryIfRequired = _categories.isEmpty || _category != null;

    // Il pulsante è abilitato SOLO se tutti i requisiti sono soddisfatti
    final nameValue = _nameController.text.trim();
    return _isAmountValid &&
        hasPaidBy &&
        hasCategoryIfRequired &&
        nameValue.isNotEmpty;
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
      setState(() {
        _amountTouched = true;
        _paidByTouched = true;
        _categoryTouched = true;
      });
      return;
    }
    if (!_isFormValid()) return;
    final nameValue = _nameController.text.trim();
    final expense = ExpenseDetails(
      amount: _amount ?? _parseLocalizedAmount(_amountController.text) ?? 0,
      paidBy: _paidBy ?? ExpenseParticipant(name: ''),
      category:
          _category ??
          (_categories.isNotEmpty
              ? _categories.first
              : ExpenseCategory(name: '', id: '', createdAt: DateTime.now())),
      date: _date ?? DateTime.now(),
      note: _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null,
      name: nameValue,
      location: _location,
    );
    widget.onExpenseAdded(expense);
    _isDirty = false;
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
      canPop: !_isDirty,
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

  /// Intestazione con il titolo del gruppo (solo in fullEdit, se presente)
  Widget _buildGroupHeader() {
    if (!(widget.fullEdit && widget.groupTitle != null)) {
      return const SizedBox.shrink();
    }
    final gloc = gen.AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        '${gloc.in_group_prefix} ${widget.groupTitle}',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Future<void> _handlePop(bool didPop, Object? result) async {
    if (didPop) return;
    if (_isDirty) {
      final navigator = Navigator.of(context);
      final discard = await _confirmDiscardChanges();
      if (discard && mounted && navigator.canPop()) navigator.pop();
    }
  }

  Widget _spacer() => const SizedBox(height: _rowSpacing);

  Widget _buildAmountField(gen.AppLocalizations gloc, TextStyle? style) =>
      _buildFieldWithStatus(
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
        _isAmountValid,
        _amountTouched,
      );

  Widget _buildNameField(gen.AppLocalizations gloc, TextStyle? style) =>
      _buildFieldWithStatus(
        AmountInputWidget(
          controller: _nameController,
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
        _nameController.text.trim().isNotEmpty,
        _amountTouched,
      );

  Widget _buildParticipantCategorySection(TextStyle? style) {
    if (widget.fullEdit) {
      return Column(
        children: [
          _buildFieldWithStatus(
            ParticipantSelectorWidget(
              participants: widget.participants.map((p) => p.name).toList(),
              selectedParticipant: _paidBy?.name,
              onParticipantSelected: _onParticipantSelected,
              textStyle: style,
              fullEdit: true,
            ),
            _isPaidByValid,
            _paidByTouched,
          ),
          _spacer(),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: _categories,
              selectedCategory: _category,
              onCategorySelected: _onCategorySelected,
              onAddCategory: _onAddCategory,
              textStyle: style,
              fullEdit: true,
            ),
            _isCategoryValid,
            _categoryTouched,
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
              selectedParticipant: _paidBy?.name,
              onParticipantSelected: _onParticipantSelected,
              textStyle: style,
              fullEdit: false,
            ),
            _isPaidByValid,
            _paidByTouched,
          ),
          _buildFieldWithStatus(
            CategorySelectorWidget(
              categories: _categories,
              selectedCategory: _category,
              onCategorySelected: _onCategorySelected,
              onAddCategory: _onAddCategory,
              textStyle: style,
              fullEdit: false,
            ),
            _isCategoryValid,
            _categoryTouched,
          ),
        ],
      ),
    );
  }

  void _onParticipantSelected(String selectedName) {
    setState(() {
      _paidBy = widget.participants.firstWhere(
        (p) => p.name == selectedName,
        orElse: () => widget.participants.isNotEmpty
            ? widget.participants.first
            : ExpenseParticipant(name: ''),
      );
      _paidByTouched = true;
      if (!_initializing) {
        _isDirty = true;
      }
    });
  }

  void _onCategorySelected(ExpenseCategory? selected) {
    setState(() {
      _category = selected;
      _categoryTouched = true;
      if (!_initializing) {
        _isDirty = true;
      }
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
          _category = found;
          _categoryTouched = true;
          if (!_initializing) {
            _isDirty = true;
          }
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
        _category = foundAfter;
        _categoryTouched = true;
        if (!_initializing) {
          _isDirty = true;
        }
      });
    }
  }

  Widget _buildExtendedFields(String locale, TextStyle? style) {
    final shouldShow =
        widget.fullEdit ||
        widget.initialExpense != null ||
        (ModalRoute.of(context)?.settings.name != null);
    if (!shouldShow) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _spacer(),
        DateSelectorWidget(
          selectedDate: _date,
          tripStartDate: widget.tripStartDate,
          tripEndDate: widget.tripEndDate,
          onDateSelected: (picked) => setState(() {
            _date = picked;
            if (!_initializing) {
              _isDirty = true;
            }
          }),
          locale: locale,
          textStyle: style,
        ),
        _spacer(),
        LocationInputWidget(
          initialLocation: _location,
          textStyle: style,
          onLocationChanged: (location) => setState(() {
            _location = location;
            if (!_initializing) {
              _isDirty = true;
            }
          }),
        ),
        _spacer(),
        NoteInputWidget(controller: _noteController, textStyle: style),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    if (widget.fullEdit) {
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

  Widget _buildActionsRow(gen.AppLocalizations gloc, TextStyle? style) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (widget.groupTitle != null && !widget.fullEdit)
        Expanded(
          child: Text(
            widget.groupTitle!,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
      else
        const Spacer(),
      ExpenseFormActionsWidget(
        onSave: _isFormValid() ? _saveExpense : null,
        isEdit: widget.initialExpense != null,
        onDelete: widget.initialExpense != null ? widget.onDelete : null,
        textStyle: style,
      ),
    ],
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    _amountFocus.dispose();
    _nameController.dispose();
    _nameFocus.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
