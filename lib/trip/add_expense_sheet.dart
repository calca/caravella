import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<String> participants;
  final void Function(Expense) onExpenseAdded;
  const AddExpenseSheet({
    super.key,
    required this.participants,
    required this.onExpenseAdded,
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
            TextFormField(
              decoration: InputDecoration(labelText: loc.get('category')),
              validator: (v) =>
                  v == null || v.isEmpty ? loc.get('required') : null,
              onSaved: (v) => _category = v,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: loc.get('amount')),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || double.tryParse(v) == null
                  ? loc.get('invalid_amount')
                  : null,
              onSaved: (v) => _amount = double.tryParse(v ?? ''),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: loc.get('paid_by')),
              items: widget.participants
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => _paidBy = v,
              validator: (v) => v == null ? loc.get('required') : null,
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
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
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
