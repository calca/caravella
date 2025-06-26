import 'package:flutter/material.dart';
import '../data/expense.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';

class AddExpenseComponent extends StatefulWidget {
  final List<String> participants;
  final List<String> categories;
  final void Function(Expense) onExpenseAdded;
  final void Function()? onAddCategory;
  final void Function(String)? onCategoryAdded;
  final Expense? initialExpense;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  const AddExpenseComponent({
    super.key,
    required this.participants,
    required this.onExpenseAdded,
    this.categories = const [],
    this.onAddCategory,
    this.onCategoryAdded,
    this.initialExpense,
    this.tripStartDate,
    this.tripEndDate,
  });

  @override
  State<AddExpenseComponent> createState() => _AddExpenseComponentState();
}

class _AddExpenseComponentState extends State<AddExpenseComponent> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double? _amount;
  String? _paidBy;
  DateTime? _date;
  final _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialExpense != null) {
      _category = widget.initialExpense!.description;
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
    // Focus automatico su importo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocus.requestFocus();
    });
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
            if (widget.initialExpense == null)
              Text(loc.get('add_expense'),
                  style: Theme.of(context).textTheme.titleLarge),
            if (widget.initialExpense == null) const SizedBox(height: 16),
            // IMPORTO + CURRENCY
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: loc.get('amount'),
                      labelStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? loc.get('invalid_amount')
                        : null,
                    onSaved: (v) => _amount = double.tryParse(v ?? ''),
                  ),
                ),
                const SizedBox(width: 8),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    // Mostra la currency del viaggio se disponibile
                    (widget.categories.isNotEmpty &&
                            widget.categories.first.startsWith('€'))
                        ? widget.categories.first
                        : '€',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // PAID BY (chip)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.participants.isNotEmpty
                            ? widget.participants.map((p) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: ChoiceChip(
                                    label: Text(
                                      p,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: _paidBy == p
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                    ),
                                    selected: _paidBy == p,
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    onSelected: (selected) {
                                      setState(() {
                                        _paidBy = selected ? p : null;
                                      });
                                    },
                                  ),
                                );
                              }).toList()
                            : [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(loc.get('participants_label'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // CATEGORIE
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.categories.isNotEmpty
                            ? widget.categories.map((cat) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: ChoiceChip(
                                    label: Text(
                                      cat,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: _category == cat
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                    ),
                                    selected: _category == cat,
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    onSelected: (selected) {
                                      setState(() {
                                        _category = selected ? cat : null;
                                      });
                                    },
                                  ),
                                );
                              }).toList()
                            : [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text(loc.get('no_categories'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.transparent),
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                  ),
                  onPressed: () async {
                    final controller = TextEditingController();
                    final newCategory = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(loc.get('add_category')),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: loc.get('category_name'),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              Navigator.of(context).pop(val.trim());
                            }
                          },
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(loc.get('cancel')),
                          ),
                          TextButton(
                            onPressed: () {
                              final val = controller.text.trim();
                              if (val.isNotEmpty) {
                                Navigator.of(context).pop(val);
                              }
                            },
                            child: Text(loc.get('add')),
                          ),
                        ],
                      ),
                    );
                    if (newCategory != null && newCategory.isNotEmpty) {
                      setState(() {
                        widget.categories.add(newCategory);
                      });
                      if (widget.onCategoryAdded != null) {
                        widget.onCategoryAdded!(newCategory);
                      }
                    }
                  },
                  child: const Icon(Icons.add, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // DATA (bottone con data + icona, angoli arrotondati, sfondo grigio coerente col tema)
            if (widget.initialExpense != null ||
                (ModalRoute.of(context)?.settings.name != null))
              Row(
                children: [
                  Expanded(child: Container()),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Colors.transparent),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date ?? DateTime.now(),
                        firstDate: widget.tripStartDate ?? DateTime(2000),
                        lastDate: widget.tripEndDate ?? DateTime(2100),
                        helpText: loc.get('select_expense_date'),
                        cancelText: loc.get('cancel'),
                        confirmText: loc.get('ok'),
                        locale: Locale(locale),
                      );
                      if (picked != null) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _date != null
                              ? '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}'
                              : loc.get('select_expense_date_short'),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.event,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // NOTE
            if (widget.initialExpense != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(loc.get('note'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                minLines: 2,
                decoration: InputDecoration(
                  hintText: loc.get('note_hint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // ...pulsanti salva/cancella...
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Text(loc.get('cancel')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    // Always save the form to update _amount
                    _formKey.currentState!.save();
                    if ((widget.categories.isNotEmpty
                            ? _category != null
                            : _formKey.currentState!.validate()) &&
                        _paidBy != null) {
                      final expense = Expense(
                        description: _category ?? '',
                        amount: _amount ?? 0,
                        paidBy: _paidBy ?? '',
                        date: _date ?? DateTime.now(),
                        note: widget.initialExpense != null
                            ? _noteController.text.trim()
                            : null,
                      );
                      widget.onExpenseAdded(expense);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(loc.get('save')),
                ),
              ],
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
