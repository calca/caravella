import 'package:flutter/material.dart';
import '../../data/expense_category.dart';
import '../../data/expense_details.dart';
import '../../app_localizations.dart';
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
  final String? groupTitle; // Titolo del gruppo per la riga azioni

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
    this.groupTitle,
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
  ExpenseLocation? _location;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();
  late List<ExpenseCategory> _categories; // Lista locale delle categorie
  bool _isDirty = false; // traccia modifiche non salvate

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

    // (Eventuali listener per aggiornare validazioni in tempo reale possono essere aggiunti qui)
  }

  Future<bool> _confirmDiscardChanges() async {
    final loc = AppLocalizations(LocaleNotifier.of(context)?.locale ?? 'it');
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(loc.get('discard_changes_title')),
            content: Text(loc.get('discard_changes_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(loc.get('cancel')),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(loc.get('discard')),
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
      amount: _amount ?? double.tryParse(_amountController.text) ?? 0,
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
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final smallStyle = Theme.of(context).textTheme.bodySmall;
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // già gestito
        if (_isDirty) {
          final navigator = Navigator.of(context);
          final discard = await _confirmDiscardChanges();
          if (discard && mounted) {
            _isDirty = false; // evita loop
            if (navigator.canPop()) {
              navigator.pop();
            }
          }
        }
      },
      child: SingleChildScrollView(
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
                  textStyle: smallStyle,
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
                  textStyle: smallStyle,
                ),
                _isAmountValid,
                _amountTouched,
              ),
              const SizedBox(height: 16),

              // PAID BY + CATEGORY dinamici e allineati a sinistra
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildFieldWithStatus(
                      ParticipantSelectorWidget(
                        participants: widget.participants
                            .map((p) => p.name)
                            .toList(),
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
                            _isDirty = true;
                          });
                        },
                        loc: loc,
                        textStyle: smallStyle,
                      ),
                      _isPaidByValid,
                      _paidByTouched,
                    ),
                    _buildFieldWithStatus(
                      CategorySelectorWidget(
                        categories: _categories,
                        selectedCategory: _category,
                        onCategorySelected: (selected) {
                          setState(() {
                            _category = selected;
                            _categoryTouched = true;
                            _isDirty = true;
                          });
                        },
                        onAddCategory: () async {
                          final newCategoryName = await CategoryDialog.show(
                            context: context,
                            loc: loc,
                          );
                          if (newCategoryName != null &&
                              newCategoryName.isNotEmpty) {
                            widget.onCategoryAdded(newCategoryName);
                            final found = widget.categories.firstWhere(
                              (c) => c.name == newCategoryName,
                              orElse: () => widget.categories.isNotEmpty
                                  ? widget.categories.first
                                  : ExpenseCategory(
                                      name: '',
                                      id: '',
                                      createdAt: DateTime(2000),
                                    ),
                            );
                            setState(() {
                              if (!_categories.contains(found)) {
                                _categories.add(found);
                                _category = found;
                                _categoryTouched = true;
                                _isDirty = true;
                              }
                            });
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            final foundAfter = widget.categories.firstWhere(
                              (c) => c.name == newCategoryName,
                              orElse: () => widget.categories.isNotEmpty
                                  ? widget.categories.first
                                  : ExpenseCategory(
                                      name: '',
                                      id: '',
                                      createdAt: DateTime(2000),
                                    ),
                            );
                            setState(() {
                              _categories = List.from(widget.categories);
                              _category = foundAfter;
                              _categoryTouched = true;
                              _isDirty = true;
                            });
                          }
                        },
                        loc: loc,
                        textStyle: smallStyle,
                      ),
                      _isCategoryValid,
                      _categoryTouched,
                    ),
                  ],
                ),
              ),

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
                      _isDirty = true;
                    });
                  },
                  loc: loc,
                  locale: locale,
                  textStyle: smallStyle,
                ),

              // LOCATION (spostato prima di NOTE)
              if (widget.showDateAndNote || widget.initialExpense != null) ...[
                LocationInputWidget(
                  initialLocation: _location,
                  loc: loc,
                  textStyle: smallStyle,
                  onLocationChanged: (location) {
                    setState(() {
                      _location = location;
                      _isDirty = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // NOTE (ora dopo LOCATION)
              if (widget.showDateAndNote || widget.initialExpense != null) ...[
                NoteInputWidget(
                  controller: _noteController,
                  loc: loc,
                  textStyle: smallStyle,
                ),
                const SizedBox(height: 16),
              ],
              Divider(
                height: 24,
                thickness: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),

              // Pulsanti di azione con titolo gruppo a sinistra
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.groupTitle != null)
                    Expanded(
                      child: Text(
                        widget.groupTitle!,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  ExpenseFormActionsWidget(
                    onSave: _isFormValid() ? _saveExpense : null,
                    loc: loc,
                    isEdit: widget.initialExpense != null,
                    textStyle: smallStyle,
                  ),
                ],
              ),
            ],
          ),
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
