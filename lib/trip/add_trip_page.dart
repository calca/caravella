import 'package:flutter/material.dart';
import '../trips_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../widgets/currency_selector.dart';

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
  final List<String> _participants = [];
  final TextEditingController _participantController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = '€'; // Default euro

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _participants.addAll(widget.trip!.participants);
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _currency = widget.trip!.currency;
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
        _endDate == null) {
      // Mostra un messaggio di errore se le date non sono selezionate
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seleziona sia la data di inizio che di fine'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aggiungi almeno un partecipante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
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
          participants: _participants,
          startDate: _startDate!,
          endDate: _endDate!,
          currency: _currency,
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
      participants: _participants,
      startDate: _startDate!,
      endDate: _endDate!,
      currency: _currency,
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
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      // Sezione date compatta
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.get('from'),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                TextButton.icon(
                                  icon: const Icon(Icons.calendar_today,
                                      size: 18),
                                  label: Text(_startDate == null
                                      ? loc.get('start_date_not_selected',
                                          params: {})
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                                  onPressed: () => _pickDate(context, true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loc.get('to'),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                TextButton.icon(
                                  icon: const Icon(Icons.calendar_today,
                                      size: 18),
                                  label: Text(_endDate == null
                                      ? loc.get('end_date_not_selected',
                                          params: {})
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                                  onPressed: () => _pickDate(context, false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(loc.get('participants'),
                              style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: loc.get('add_participant'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(loc.get('add_participant')),
                                  content: TextField(
                                    controller: _participantController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: loc.get('participant_name'),
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          _participants.add(val.trim());
                                          _participantController.clear();
                                        });
                                        Navigator.of(context).pop();
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
                                        final val = _participantController.text.trim();
                                        if (val.isNotEmpty) {
                                          setState(() {
                                            _participants.add(val);
                                            _participantController.clear();
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: Text(loc.get('add')),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_participants.isEmpty)
                        Text(loc.get('no_participants'),
                            style: Theme.of(context).textTheme.bodySmall),
                      ..._participants.asMap().entries.map((entry) {
                        final i = entry.key;
                        final p = entry.value;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Text(p,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: loc.get('edit'),
                              onPressed: () {
                                final editController =
                                    TextEditingController(text: p);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(loc.get('edit_participant')),
                                    content: TextField(
                                      controller: editController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        labelText: loc.get('participant_name'),
                                      ),
                                      onSubmitted: (val) {
                                        if (val.trim().isNotEmpty) {
                                          setState(() {
                                            _participants[i] = val.trim();
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(loc.get('cancel')),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          final val =
                                              editController.text.trim();
                                          if (val.isNotEmpty) {
                                            setState(() {
                                              _participants[i] = val;
                                            });
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: Text(loc.get('save')),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  _participants.removeAt(i);
                                });
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(loc.get('currency'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: CurrencySelector(
                            value: _currency,
                            onChanged: (val) {
                              if (val != null) setState(() => _currency = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
