import 'package:flutter/material.dart';
import '../../data/expense_details.dart';
import '../../app_localizations.dart';
import '../../state/locale_notifier.dart';
import 'expense_form/amount_input_widget.dart';
import 'expense_form/participant_selector_widget.dart';
import 'expense_form/category_selector_widget.dart';
import 'expense_form/date_selector_widget.dart';
import 'expense_form/note_input_widget.dart';
import 'expense_form/expense_form_actions_widget.dart';
import 'expense_form/category_dialog.dart';

class ExpenseFormComponent extends StatefulWidget {
  final List<String> participants;
  final List<String> categories;
  final void Function(ExpenseDetails) onExpenseAdded;
  final void Function()? onAddCategory;
  final void Function(String)? onCategoryAdded;
  final ExpenseDetails? initialExpense;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final bool
      shouldAutoClose; // Nuovo parametro per gestire la chiusura automatica
  final String? groupTitle; // Titolo del gruppo di spese

  const ExpenseFormComponent({
    super.key,
    required this.participants,
    required this.onExpenseAdded,
    this.categories = const [],
    this.onAddCategory,
    this.onCategoryAdded,
    this.initialExpense,
    this.tripStartDate,
    this.tripEndDate,
    this.shouldAutoClose =
        true, // Di default chiude automaticamente (per i bottom sheet)
    this.groupTitle, // Titolo del gruppo di spese (opzionale)
  });

  @override
  State<ExpenseFormComponent> createState() => _ExpenseFormComponentState();
}

class _ExpenseFormComponentState extends State<ExpenseFormComponent> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double? _amount;
  String? _paidBy;
  DateTime? _date;
  final _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  late List<String> _categories; // Lista locale delle categorie
  
  // Stato per validazione in tempo reale
  bool _amountTouched = false;
  bool _paidByTouched = false;
  bool _categoryTouched = false;
  
  // Getters per stato dei campi
  bool get _isAmountValid => _amount != null && _amount! > 0;
  bool get _isPaidByValid => _paidBy != null;
  bool get _isCategoryValid => _categories.isEmpty || _category != null;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories); // Copia della lista originale
    if (widget.initialExpense != null) {
      _category = widget.initialExpense!.category;
      _amount = widget.initialExpense!.amount;
      _paidBy = widget.initialExpense!.paidBy;
      _date = widget.initialExpense!.date;
      // Se amount è null o 0, lascia il campo vuoto
      _amountController.text = (widget.initialExpense!.amount == 0)
          ? ''
          : widget.initialExpense!.amount.toString();
      _noteController.text = widget.initialExpense!.note ?? '';
    } else {
      _date = DateTime.now();
    }

    // Listener per aggiornare la validazione in tempo reale
    _amountController.addListener(() {
      setState(() {
        _amount = double.tryParse(_amountController.text);
        _amountTouched = true;
      });
    });

    // Focus automatico su importo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
  }

  @override
  void didUpdateWidget(ExpenseFormComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Aggiorna la lista locale se quella del widget è cambiata
    if (oldWidget.categories != widget.categories) {
      setState(() {
        _categories = List.from(widget.categories);
        // Mantieni la selezione corrente se la categoria esiste ancora
        if (_category != null && !_categories.contains(_category!)) {
          _category = null;
        }
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
    bool hasPaidBy = _paidBy != null;

    if (isFormValid && hasCategoryIfRequired && hasPaidBy) {
      final expense = ExpenseDetails(
        category: _category ?? '',
        amount: _amount ?? 0,
        paidBy: _paidBy ?? '',
        date: _date ?? DateTime.now(),
        note:
            widget.initialExpense != null ? _noteController.text.trim() : null,
      );
      widget.onExpenseAdded(expense);

      // Chiude automaticamente solo se richiesto (per i bottom sheet)
      if (widget.shouldAutoClose) {
        Navigator.of(context).pop();
      }
    }
    // Rimuoviamo la SnackBar perché ora mostriamo il messaggio nel widget
  }

  bool _isFormValid() {
    // SET MINIMO DI INFORMAZIONI NECESSARIE per abilitare il pulsante:
    // 1. Importo valido (> 0)
    bool hasValidAmount = _amount != null && _amount! > 0;
    
    // 2. Partecipante selezionato (chi ha pagato)
    bool hasPaidBy = _paidBy != null && _paidBy!.isNotEmpty;
    
    // 3. Categoria selezionata (solo se esistono categorie)
    bool hasCategoryIfRequired = _categories.isEmpty || 
        (_category != null && _category!.isNotEmpty);

    // Il pulsante è abilitato SOLO se tutti i requisiti sono soddisfatti
    return hasValidAmount && hasPaidBy && hasCategoryIfRequired;
  }

  // Widget per indicatori di stato - versione minimalista
  Widget _buildFieldWithStatus(Widget field, bool isValid, bool isTouched) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // Solo sfondo colorato se c'è un errore
        color: isTouched && !isValid 
            ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.08)
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
            // Mostra solo il titolo del gruppo se fornito
            if (widget.groupTitle != null) ...[
              Text(
                widget.groupTitle!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
            ],
            
            // IMPORTO + CURRENCY con status
            _buildFieldWithStatus(
              AmountInputWidget(
                controller: _amountController,
                focusNode: _amountFocus,
                categories: _categories,
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
                participants: widget.participants,
                selectedParticipant: _paidBy,
                onParticipantSelected: (selected) {
                  setState(() {
                    _paidBy = selected;
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
                  final newCategory = await CategoryDialog.show(
                    context: context,
                    loc: loc,
                  );
                  if (newCategory != null && newCategory.isNotEmpty) {
                    // Prima notifica al parent tramite callback
                    if (widget.onCategoryAdded != null) {
                      widget.onCategoryAdded!(newCategory);
                    }

                    // Aggiorna immediatamente la lista locale
                    setState(() {
                      if (!_categories.contains(newCategory)) {
                        _categories.add(newCategory);
                      }
                      _category = newCategory;
                      _categoryTouched = true;
                    });

                    // Aspetta un momento per permettere al parent di elaborare
                    await Future.delayed(const Duration(milliseconds: 100));

                    // Verifica se la categoria è stata aggiunta alla lista del parent
                    if (widget.categories.contains(newCategory)) {
                      // Se sì, aggiorna la lista locale con quella del parent
                      setState(() {
                        _categories = List.from(widget.categories);
                      });
                    }
                  }
                },
                loc: loc,
              ),
              _isCategoryValid,
              _categoryTouched,
            ),
            const SizedBox(height: 16),
            
            // DATA (bottone con data + icona, angoli arrotondati, sfondo grigio coerente col tema)
            if (widget.initialExpense != null ||
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
            if (widget.initialExpense != null) ...[
              NoteInputWidget(
                controller: _noteController,
                loc: loc,
              ),
              const SizedBox(height: 16),
            ],
            
            // Pulsanti di azione
            ExpenseFormActionsWidget(
              onCancel: () => Navigator.of(context).pop(),
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
    _noteController.dispose();
    super.dispose();
  }
}
