import 'package:flutter/material.dart';
import '../../data/expense_category.dart';
import '../../data/expense_details.dart';
import '../../app_localizations.dart';
import '../../data/expense_participant.dart';
import '../../state/locale_notifier.dart';
import 'expense_form/amount_input_widget.dart';
import 'expense_form/participant_selector_widget.dart';
import 'expense_form/category_selector_widget.dart';
import 'expense_form/date_selector_widget.dart';
import 'expense_form/note_input_widget.dart';
import 'expense_form/expense_form_actions_widget.dart';
import 'expense_form/category_dialog.dart';

class ExpenseFormComponent extends StatefulWidget {
  final bool showDateAndNote;
  final ExpenseDetails? initialExpense;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final Function(ExpenseDetails) onExpenseAdded;
  final Function(String) onCategoryAdded;
  final bool shouldAutoClose;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? newlyAddedCategory; // Nuova proprietà

  const ExpenseFormComponent({
    super.key,
    this.initialExpense,
    required this.participants,
    required this.categories,
    required this.onExpenseAdded,
    required this.onCategoryAdded,
    this.shouldAutoClose = true,
    this.tripStartDate,
    this.tripEndDate,
    this.newlyAddedCategory, // Nuova proprietà
    this.showDateAndNote = false,
  });

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  final _formKey = GlobalKey<FormState>();
  ExpenseCategory? _category;
  double? _amount;
  ExpenseParticipant? _paidBy;
  DateTime? _date;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  late List<ExpenseCategory> _categories; // Lista locale delle categorie

  // Stato per validazione in tempo reale
  bool _amountTouched = false;
  bool _paidByTouched = false;
  bool _categoryTouched = false;

  // Getters per stato dei campi
  bool get _isAmountValid => _amount != null && _amount! > 0;
  bool get _isPaidByValid => _paidBy != null;
  bool get _isCategoryValid => _categories.isEmpty || _category != null;

  // Scroll controller callback per CategorySelectorWidget
  void Function()? _scrollToCategoryEnd;

  @override
  void initState() {
    super.initState();
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
      _nameController.text = widget.initialExpense!.name ?? '';
      // Se amount è null o 0, lascia il campo vuoto
      _amountController.text = (widget.initialExpense!.amount == 0)
          ? ''
          : widget.initialExpense!.amount.toString();
      _noteController.text = widget.initialExpense!.note ?? '';
    } else {
      _date = DateTime.now();
      _nameController.text = '';
    }

    // Listener per aggiornare la validazione in tempo reale
    _amountController.addListener(() {
      setState(() {
        _amount = double.tryParse(_amountController.text);
        _amountTouched = true;
      });
    });

    // Focus automatico su nome spesa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });

    // Se c'è una nuova categoria, preselezionala
    if (widget.newlyAddedCategory != null) {
      final found = widget.categories.firstWhere(
        (c) => c.name == widget.newlyAddedCategory,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      _category = found;
    }
  }

  @override
  void didUpdateWidget(covariant ExpenseFormComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se una nuova categoria è stata aggiunta e non è già selezionata, la selezioniamo
    if (widget.newlyAddedCategory != null &&
        (_category == null || widget.newlyAddedCategory != _category!.name)) {
      final found = widget.categories.firstWhere(
        (c) => c.name == widget.newlyAddedCategory,
        orElse: () => widget.categories.isNotEmpty
            ? widget.categories.first
            : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000)),
      );
      setState(() {
        _category = found;
      });
    }
  }

  void _saveExpense() {
    setState(() {});
    // Always save the form to update _amount
    _formKey.currentState!.save();

    // Applica la validazione completa prima di salvare
    bool isFormValid = _formKey.currentState!.validate();
    bool hasCategoryIfRequired =
        _categories.isNotEmpty ? _category != null : true;
    bool hasPaidBy = _paidBy != null && _paidBy!.name.isNotEmpty;

    final nameValue = _nameController.text.trim();
    if (isFormValid &&
        hasCategoryIfRequired &&
        hasPaidBy &&
        nameValue.isNotEmpty) {
      final expense = ExpenseDetails(
        category: _category ??
            (_categories.isNotEmpty
                ? _categories.first
                : ExpenseCategory(name: '', id: '', createdAt: DateTime(2000))),
        amount: _amount ?? 0,
        paidBy: _paidBy ??
            (widget.participants.isNotEmpty
                ? widget.participants.first
                : ExpenseParticipant(name: '')),
        date: _date ?? DateTime.now(),
        note:
            widget.initialExpense != null ? _noteController.text.trim() : null,
        name: nameValue,
      );
      widget.onExpenseAdded(expense);

      // Chiude automaticamente solo se richiesto (per i bottom sheet)
      if (widget.shouldAutoClose && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
    // Rimuoviamo la SnackBar perché ora mostriamo il messaggio nel widget
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
            ? Theme.of(context)
                .colorScheme
                .errorContainer
                .withValues(alpha: 0.08)
            : null,
      ),
      child: field,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CAMPO NOME SPESA (identico a importo, ora AmountInputWidget supporta testo)
            _buildFieldWithStatus(
              AmountInputWidget(
                controller: _nameController,
                focusNode: _nameFocus,
                loc: loc,
                label: loc.get('expense_name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Il nome è obbligatorio'
                    : null,
                onSaved: (v) {},
                onSubmitted: () {},
                isText: true,
              ),
              _nameController.text.trim().isNotEmpty,
              _amountTouched,
            ),
            const SizedBox(height: 16),
            // IMPORTO + CURRENCY con status
            _buildFieldWithStatus(
              AmountInputWidget(
                controller: _amountController,
                focusNode: _amountFocus,
                categories: _categories,
                label: loc.get('amount'),
                loc: loc,
                validator: (v) => v == null || double.tryParse(v) == null
                    ? loc.get('invalid_amount')
                    : null,
                onSaved: (v) {
                  // Non necessario più, viene gestito dal listener
                },
                onSubmitted: _saveExpense,
              ),
              _isAmountValid,
              _amountTouched,
            ),
            const SizedBox(height: 16),

            // PAID BY (chip) con status
            _buildFieldWithStatus(
              ParticipantSelectorWidget(
                participants: widget.participants.map((p) => p.name).toList(),
                selectedParticipant: _paidBy?.name,
                onParticipantSelected: (selectedName) {
                  setState(() {
                    _paidBy = widget.participants.firstWhere(
                      (p) => p.name == selectedName,
                      orElse: () => widget.participants.isNotEmpty
                          ? widget.participants.first
                          : ExpenseParticipant(name: ''),
                    );
                    _paidByTouched = true;
                  });
                },
                loc: loc,
              ),
              _isPaidByValid,
              _paidByTouched,
            ),
            const SizedBox(height: 16),

            // CATEGORIE con status
            _buildFieldWithStatus(
              CategorySelectorWidget(
                categories: _categories,
                selectedCategory: _category,
                onCategorySelected: (selected) {
                  setState(() {
                    _category = selected;
                    _categoryTouched = true;
                  });
                },
                onAddCategory: () async {
                  final newCategoryName = await CategoryDialog.show(
                    context: context,
                    loc: loc,
                  );
                  if (newCategoryName != null && newCategoryName.isNotEmpty) {
                    // Prima notifica al parent tramite callback
                    widget.onCategoryAdded(newCategoryName);

                    // Aggiorna immediatamente la lista locale se la categoria è già presente
                    final found = widget.categories.firstWhere(
                      (c) => c.name == newCategoryName,
                      orElse: () => widget.categories.isNotEmpty
                          ? widget.categories.first
                          : ExpenseCategory(
                              name: '', id: '', createdAt: DateTime(2000)),
                    );
                    setState(() {
                      if (!_categories.contains(found)) {
                        _categories.add(found);
                        _category = found;
                        _categoryTouched = true;
                      }
                    });

                    // Aspetta un momento per permettere al parent di elaborare
                    await Future.delayed(const Duration(milliseconds: 100));

                    // Verifica se la categoria è stata aggiunta alla lista del parent
                    final foundAfter = widget.categories.firstWhere(
                      (c) => c.name == newCategoryName,
                      orElse: () => widget.categories.isNotEmpty
                          ? widget.categories.first
                          : ExpenseCategory(
                              name: '', id: '', createdAt: DateTime(2000)),
                    );
                    setState(() {
                      _categories = List.from(widget.categories);
                      _category = foundAfter;
                      _categoryTouched = true;
                    });

                    // Scroll automatico alla fine
                    if (_scrollToCategoryEnd != null) {
                      _scrollToCategoryEnd!();
                    }
                  }
                },
                loc: loc,
                registerScrollToEnd: (fn) {
                  _scrollToCategoryEnd = fn;
                },
              ),
              _isCategoryValid,
              _categoryTouched,
            ),
            const SizedBox(height: 16),

            // DATA (bottone con data + icona, angoli arrotondati, sfondo grigio coerente col tema)
            if (widget.showDateAndNote ||
                widget.initialExpense != null ||
                (ModalRoute.of(context)?.settings.name != null))
              DateSelectorWidget(
                selectedDate: _date,
                tripStartDate: widget.tripStartDate,
                tripEndDate: widget.tripEndDate,
                onDateSelected: (picked) {
                  setState(() {
                    _date = picked;
                  });
                },
                loc: loc,
                locale: locale,
              ),
            const SizedBox(height: 16),

            // NOTE
            if (widget.showDateAndNote || widget.initialExpense != null) ...[
              NoteInputWidget(
                controller: _noteController,
                loc: loc,
              ),
              const SizedBox(height: 16),
            ],

            // Pulsanti di azione
            ExpenseFormActionsWidget(
              onCancel: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onSave: _isFormValid() ? _saveExpense : null,
              loc: loc,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    _nameFocus.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
