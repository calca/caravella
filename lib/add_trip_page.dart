import 'package:flutter/material.dart';
import 'trips_storage.dart';

class AddTripPage extends StatefulWidget {
  final Trip? trip;
  const AddTripPage({super.key, this.trip});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _participantsController.text = widget.trip!.participants.join(', ');
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate() || _startDate == null || _endDate == null) return;
    final participants = _participantsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (widget.trip != null) {
      // EDIT: update existing trip
      final trips = await TripsStorage.readTrips();
      final idx = trips.indexWhere((v) =>
        v.title == widget.trip!.title &&
        v.startDate == widget.trip!.startDate &&
        v.endDate == widget.trip!.endDate
      );
      if (idx != -1) {
        trips[idx] = Trip(
          title: _titleController.text,
          expenses: trips[idx].expenses, // keep expenses
          participants: participants,
          startDate: _startDate!,
          endDate: _endDate!,
        );
        await TripsStorage.writeTrips(trips);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    }
    // CREATE: add new trip
    final newTrip = Trip(
      title: _titleController.text,
      expenses: [],
      participants: participants,
      startDate: _startDate!,
      endDate: _endDate!,
    );
    final trips = await TripsStorage.readTrips();
    trips.add(newTrip);
    await TripsStorage.writeTrips(trips);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Trip title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _participantsController,
                decoration: const InputDecoration(
                  labelText: 'Participants (comma separated)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter at least one participant' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_startDate == null
                        ? 'Start date not selected'
                        : 'Start: 	${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: const Text('Select start'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_endDate == null
                        ? 'End date not selected'
                        : 'End: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: const Text('Select end'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTrip,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
