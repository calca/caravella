import 'package:flutter/material.dart';
import '../data/expense_group.dart';
import '../../data/expense_group_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../widgets/currency_selector.dart';
import '../widgets/caravella_app_bar.dart';

class AddNewExpensesGroupPage extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  const AddNewExpensesGroupPage({super.key, this.trip, this.onTripDeleted});

  @override
  State<AddNewExpensesGroupPage> createState() =>
      _AddNewExpensesGroupPageState();
}

class _AddNewExpensesGroupPageState extends State<AddNewExpensesGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _participants = [];
  final TextEditingController _participantController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = '€'; // Default euro
  final List<String> _categories = [];
  String? _dateError;

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      _titleController.text = widget.trip!.title;
      _participants.addAll(widget.trip!.participants);
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _currency = widget.trip!.currency;
      _categories.addAll(widget.trip!.categories);
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
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5);
    DateTime? initialDate = isStart ? (_startDate ?? now) : (_endDate ?? now);
    bool isSelectable(DateTime d) {
      if (isStart && _endDate != null) return !d.isAfter(_endDate!);
      if (!isStart && _startDate != null) return !d.isBefore(_startDate!);
      return true;
    }

    // Se l'initialDate non è selezionabile, trova la prima data valida
    if (!isSelectable(initialDate)) {
      DateTime candidate = isStart ? lastDate : firstDate;
      while (!isSelectable(candidate)) {
        candidate = isStart
            ? candidate.subtract(const Duration(days: 1))
            : candidate.add(const Duration(days: 1));
        if (candidate.isBefore(firstDate) || candidate.isAfter(lastDate)) {
          candidate = now;
          break;
        }
      }
      initialDate = candidate;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStart ? loc.get('select_start') : loc.get('select_end'),
      cancelText: loc.get('cancel'),
      confirmText: loc.get('ok'),
      locale: Locale(locale),
      selectableDayPredicate: isSelectable,
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
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    setState(() {
      _dateError = null;
    });

    // Validazione del form (senza le date)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validazione delle date solo se entrambe sono state selezionate
    if ((_startDate != null && _endDate == null) ||
        (_startDate == null && _endDate != null)) {
      setState(() {
        _dateError = loc.get('select_both_dates');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('select_both_dates')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Se entrambe le date sono specificate, controlla che l'ordine sia corretto
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      setState(() {
        _dateError = loc.get('end_date_after_start');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('end_date_after_start')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('enter_participant')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (widget.trip != null) {
      // EDIT: update existing trip
      final trips = await ExpenseGroupStorage.getAllGroups();
      final idx = trips.indexWhere((v) => v.id == widget.trip!.id);
      if (idx != -1) {
        trips[idx] = ExpenseGroup(
          title: _titleController.text,
          expenses: trips[idx].expenses, // keep expenses
          participants: _participants,
          startDate: _startDate,
          endDate: _endDate,
          currency: _currency,
          categories: _categories,
          timestamp: trips[idx].timestamp, // mantieni il timestamp originale
          id: trips[idx].id, // mantieni l'id originale
        );
        await ExpenseGroupStorage.writeTrips(trips);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }
    }
    // CREATE: add new trip
    final newTrip = ExpenseGroup(
      title: _titleController.text,
      expenses: [],
      participants: _participants,
      startDate: _startDate,
      endDate: _endDate,
      currency: _currency,
      categories: _categories,
      // timestamp: default a now
    );
    final trips = await ExpenseGroupStorage.getAllGroups();
    trips.add(newTrip);
    await ExpenseGroupStorage.writeTrips(trips);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _unfocusAll() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }
  }

  // --- UTILITY: Unfocus after dialog close ---
  void _closeDialogAndUnfocus([dynamic result]) {
    Navigator.of(context).pop(result);
    Future.delayed(const Duration(milliseconds: 10), _unfocusAll);
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: CaravellaAppBar(
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
                    final trips = await ExpenseGroupStorage.getAllGroups();
                    trips.removeWhere((v) => v.id == widget.trip!.id);
                    await ExpenseGroupStorage.writeTrips(trips);
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
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Sezione 1: Informazioni Base
                _buildSectionCard(
                  title: loc.get('basic_info'),
                  children: [
                    // Nome gruppo
                    TextFormField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(),
                      decoration: InputDecoration(
                        labelText: loc.get('group_name'),
                        labelStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? loc.get('enter_title') : null,
                    ),
                    const SizedBox(height: 20),
                    // Sezione date compatta
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.get('start_date_optional'),
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: Text(
                                  _startDate == null
                                      ? loc.get('start_date_not_selected')
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onPressed: () => _pickDate(context, true),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.get('end_date_optional'),
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                icon: const Icon(Icons.calendar_today, size: 18),
                                label: Text(
                                  _endDate == null
                                      ? loc.get('end_date_not_selected')
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onPressed: () => _pickDate(context, false),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _dateError!,
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Sezione 2: Partecipanti
                _buildSectionCard(
                  title: loc.get('participants'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _participants.isEmpty 
                            ? loc.get('no_participants')
                            : '${_participants.length} partecipant${_participants.length == 1 ? 'e' : 'i'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _participants.isEmpty 
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                          ),
                        ),
                        IconButton.outlined(
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
                                    hintText: loc.get('participant_name_hint'),
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      setState(() {
                                        _participants.add(val.trim());
                                        _participantController.clear();
                                      });
                                      _closeDialogAndUnfocus();
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => _closeDialogAndUnfocus(),
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
                                        _closeDialogAndUnfocus();
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
                    if (_participants.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._participants.asMap().entries.map((entry) {
                        final i = entry.key;
                        final p = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    p,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    semanticsLabel: loc.get(
                                        'participant_name_semantics',
                                        params: {'name': p}),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: loc.get('edit_participant'),
                                onPressed: () {
                                  final editController = TextEditingController(text: p);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.get('edit_participant')),
                                      content: TextField(
                                        controller: editController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: loc.get('participant_name'),
                                          hintText: loc.get('participant_name_hint'),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty) {
                                            setState(() {
                                              _participants[i] = val.trim();
                                            });
                                            _closeDialogAndUnfocus();
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => _closeDialogAndUnfocus(),
                                          child: Text(loc.get('cancel')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final val = editController.text.trim();
                                            if (val.isNotEmpty) {
                                              setState(() {
                                                _participants[i] = val;
                                              });
                                              _closeDialogAndUnfocus();
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
                                tooltip: loc.get('delete_participant'),
                                onPressed: () {
                                  setState(() {
                                    _participants.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                
                // Sezione 3: Categorie
                _buildSectionCard(
                  title: loc.get('categories'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _categories.isEmpty 
                            ? loc.get('no_categories')
                            : '${_categories.length} categori${_categories.length == 1 ? 'a' : 'e'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _categories.isEmpty 
                              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                          ),
                        ),
                        IconButton.outlined(
                          icon: const Icon(Icons.add),
                          tooltip: loc.get('add_category'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController categoryController =
                                    TextEditingController();
                                return AlertDialog(
                                  title: Text(loc.get('add_category')),
                                  content: TextField(
                                    controller: categoryController,
                                    autofocus: true,
                                    decoration: InputDecoration(
                                      labelText: loc.get('category_name'),
                                      hintText: loc.get('category_name_hint'),
                                    ),
                                    onSubmitted: (val) {
                                      if (val.trim().isNotEmpty) {
                                        setState(() {
                                          _categories.add(val.trim());
                                        });
                                        _closeDialogAndUnfocus();
                                      }
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => _closeDialogAndUnfocus(),
                                      child: Text(loc.get('cancel')),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final val = categoryController.text.trim();
                                        if (val.isNotEmpty) {
                                          setState(() {
                                            _categories.add(val);
                                          });
                                          _closeDialogAndUnfocus();
                                        }
                                      },
                                      child: Text(loc.get('add')),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    if (_categories.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._categories.asMap().entries.map((entry) {
                        final i = entry.key;
                        final c = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    c,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    semanticsLabel: loc.get('category_name_semantics',
                                        params: {'name': c}),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: loc.get('edit_category'),
                                onPressed: () {
                                  final editController = TextEditingController(text: c);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.get('edit_category')),
                                      content: TextField(
                                        controller: editController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: loc.get('category_name'),
                                          hintText: loc.get('category_name_hint'),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty) {
                                            setState(() {
                                              _categories[i] = val.trim();
                                            });
                                            _closeDialogAndUnfocus();
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => _closeDialogAndUnfocus(),
                                          child: Text(loc.get('cancel')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final val = editController.text.trim();
                                            if (val.isNotEmpty) {
                                              setState(() {
                                                _categories[i] = val;
                                              });
                                              _closeDialogAndUnfocus();
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
                                tooltip: loc.get('delete_category'),
                                onPressed: () {
                                  setState(() {
                                    _categories.removeAt(i);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                
                // Sezione 4: Impostazioni
                _buildSectionCard(
                  title: loc.get('settings'),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.get('currency'),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(width: 16),
                        CurrencySelector(
                          value: _currency,
                          onChanged: (val) {
                            if (val != null) setState(() => _currency = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Bottone di salvataggio
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    onPressed: _saveTrip,
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                      elevation: 2,
                    ),
                    child: Text(loc.get('save')),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
