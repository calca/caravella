import 'package:flutter/material.dart';
import 'trips_storage.dart';
import 'app_localizations.dart';
import 'state/locale_notifier.dart';

class AddTripPage extends StatefulWidget {
  final Trip? trip;
  final VoidCallback? onTripDeleted;
  const AddTripPage({super.key, this.trip, this.onTripDeleted});

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Forza rebuild su cambio locale
    if (mounted) setState(() {});
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: isStart ? loc.get('select_start') : loc.get('select_end'),
      cancelText: loc.get('cancel'),
      confirmText: loc.get('ok'),
      locale: Locale(locale),
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
    if (!_formKey.currentState!.validate() ||
        _startDate == null ||
        _endDate == null) return;
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
          v.endDate == widget.trip!.endDate);
      if (idx != -1) {
        trips[idx] = Trip(
          title: _titleController.text,
          expenses: trips[idx].expenses, // keep expenses
          participants: participants,
          startDate: _startDate!,
          endDate: _endDate!,
        );
        await TripsStorage.writeTrips(trips);
        if (!mounted) return;
        Navigator.of(context).pop(true);
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
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    // For debug: print all keys for this locale
    // print(AppLocalizations._localizedValues[locale]?.keys);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trip == null ? loc.get('add_trip') : loc.get('edit_trip'),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          if (widget.trip != null)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: loc.get('delete'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(loc.get('delete_trip')),
                    content: Text(loc.get('delete_trip_confirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(loc.get('cancel')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(loc.get('delete')),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  final trips = await TripsStorage.readTrips();
                  trips.removeWhere((v) =>
                      v.title == widget.trip!.title &&
                      v.startDate == widget.trip!.startDate &&
                      v.endDate == widget.trip!.endDate);
                  await TripsStorage.writeTrips(trips);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(true);
                  if (widget.onTripDeleted != null) {
                    widget.onTripDeleted!();
                  }
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    labelText: loc.get('trip_title', params: {})),
                validator: (v) => v == null || v.isEmpty
                    ? loc.get('enter_title', params: {})
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _participantsController,
                decoration: InputDecoration(
                  labelText: loc.get('participants_hint', params: {}),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? loc.get('enter_participant', params: {})
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_startDate == null
                        ? loc.get('start_date_not_selected', params: {})
                        : '${loc.get('select_start', params: {})}: \\${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: Text(loc.get('select_start', params: {})),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_endDate == null
                        ? loc.get('end_date_not_selected', params: {})
                        : '${loc.get('select_end', params: {})}: \\${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: Text(loc.get('select_end', params: {})),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTrip,
                child: Text(loc.get('save', params: {})),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
