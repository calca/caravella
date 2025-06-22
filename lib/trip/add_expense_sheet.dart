import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<String> participants;
  final List<String> categories;
  final void Function(Expense) onExpenseAdded;
  const AddExpenseSheet({
    super.key,
    required this.participants,
    required this.onExpenseAdded,
    this.categories = const [],
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double? _amount;
  String? _paidBy;
  final DateTime _date = DateTime.now();
  String? _paidByError;

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
            Text(loc.get('add_expense'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (widget.categories.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(loc.get('category'),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _category == cat,
                        onSelected: (selected) {
                          setState(() {
                            _category = selected ? cat : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              TextFormField(
                decoration: InputDecoration(labelText: loc.get('category')),
                validator: (v) =>
                    v == null || v.isEmpty ? loc.get('required') : null,
                onSaved: (v) => _category = v,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              decoration: InputDecoration(labelText: loc.get('amount')),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || double.tryParse(v) == null
                  ? loc.get('invalid_amount')
                  : null,
              onSaved: (v) => _amount = double.tryParse(v ?? ''),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(loc.get('paid_by'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.participants.map((p) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(p),
                            selected: _paidBy == p,
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
              ],
            ),
            if (_paidByError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(_paidByError!, style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
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
                    if ((widget.categories.isNotEmpty
                            ? _category != null
                            : _formKey.currentState!.validate()) &&
                        _paidBy != null) {
                      if (widget.categories.isEmpty) {
                        _formKey.currentState!.save();
                      }
                      final expense = Expense(
                        description: _category ?? '',
                        amount: _amount ?? 0,
                        paidBy: _paidBy ?? '',
                        date: _date,
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
}
