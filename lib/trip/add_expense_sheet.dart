import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<String> participants;
  final List<String> categories;
  final void Function(Expense) onExpenseAdded;
  final void Function()? onAddCategory;
  final void Function(String)? onCategoryAdded;
  final Expense? initialExpense;
  const AddExpenseSheet({
    super.key,
    required this.participants,
    required this.onExpenseAdded,
    this.categories = const [],
    this.onAddCategory,
    this.onCategoryAdded,
    this.initialExpense,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double? _amount;
  String? _paidBy;
  DateTime? _date;
  String? _paidByError;
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
      _amountController.text = widget.initialExpense!.amount.toString();
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
            // PAID BY
            Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: widget.participants.map((p) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(p,
                            style: Theme.of(context).textTheme.bodyLarge),
                        selected: _paidBy == p,
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        onSelected: (selected) {
                          setState(() {
                            _paidBy = selected ? p : null;
                            _paidByError = null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (_paidByError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(_paidByError!, style: TextStyle(color: Colors.red)),
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
                                    label: Text(cat,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
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
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: loc.get('add_category'),
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
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(loc.get('cancel')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _paidByError =
                          _paidBy == null ? loc.get('required') : null;
                    });
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
