import 'package:flutter/material.dart';
import 'trips_storage.dart';
import 'add_trip_page.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late Trip _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _refreshTrip() async {
    final trips = await TripsStorage.readTrips();
    final idx = trips.indexWhere((v) =>
      v.title == _trip.title &&
      v.startDate == _trip.startDate &&
      v.endDate == _trip.endDate
    );
    if (idx != -1) {
      setState(() {
        _trip = trips[idx];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddTripPage(
                    trip: _trip,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                await _refreshTrip();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period: ${_trip.startDate.day}/${_trip.startDate.month}/${_trip.startDate.year} - ${_trip.endDate.day}/${_trip.endDate.month}/${_trip.endDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Participants: ${_trip.participants.join(", ")}'),
            const SizedBox(height: 16),
            const Text('Expenses:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _trip.expenses.isEmpty
                  ? const Text('No expenses')
                  : ListView.builder(
                      itemCount: _trip.expenses.length,
                      itemBuilder: (context, i) {
                        final expense = _trip.expenses[i];
                        return ListTile(
                          title: Text(expense.description),
                          subtitle: Text('Paid by: ${expense.paidBy}\nDate: ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                          trailing: Text('€ ${expense.amount.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 16,
                      right: 16,
                      top: 24,
                    ),
                    child: AddExpenseSheet(
                      participants: _trip.participants,
                      onExpenseAdded: (expense) async {
                        final trips = await TripsStorage.readTrips();
                        final idx = trips.indexWhere((v) =>
                          v.title == _trip.title &&
                          v.startDate == _trip.startDate &&
                          v.endDate == _trip.endDate
                        );
                        if (idx != -1) {
                          trips[idx].expenses.add(expense);
                          await TripsStorage.writeTrips(trips);
                          await _refreshTrip();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- SHEET FOR ADDING EXPENSE ---
class AddExpenseSheet extends StatefulWidget {
  final List<String> participants;
  final void Function(Expense) onExpenseAdded;
  const AddExpenseSheet({super.key, required this.participants, required this.onExpenseAdded});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _category;
  double? _amount;
  String? _paidBy;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add expense', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              onSaved: (v) => _category = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid amount' : null,
              onSaved: (v) => _amount = double.tryParse(v ?? ''),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Paid by'),
              items: widget.participants.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => _paidBy = v,
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
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
                  child: const Text('Save'),
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
