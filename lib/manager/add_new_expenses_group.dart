import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../data/expense_group.dart';
import '../data/expense_participant.dart';
import '../data/expense_category.dart';
import '../../data/expense_group_storage.dart';
import '../app_localizations.dart';
import '../state/locale_notifier.dart';
import '../widgets/currency_selector.dart';
import '../widgets/caravella_app_bar.dart';
import '../widgets/widgets.dart';

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
  final FocusNode _titleFocusNode = FocusNode();
  final List<ExpenseParticipant> _participants = [];
  final TextEditingController _participantController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = '€'; // Default euro
  final List<ExpenseCategory> _categories = [];
  String? _dateError;

  // Image-related variables
  File? _selectedImageFile;
  String? _savedImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      // Edit mode
      _titleController.text = widget.trip!.title;
      _participants.addAll(widget.trip!.participants);
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
      _currency = widget.trip!.currency;
      _categories.addAll(widget.trip!.categories);
      _savedImagePath = widget.trip!.file;
      if (_savedImagePath != null) {
        _selectedImageFile = File(_savedImagePath!);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Forza rebuild su cambio locale
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    _participantController.dispose();
    super.dispose();
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

  /// Controlla se il form ha i dati minimi per essere salvato
  bool _isFormValid() {
    // Il titolo deve essere non vuoto
    if (_titleController.text.trim().isEmpty) return false;

    // Deve esserci almeno un partecipante
    if (_participants.isEmpty) return false;

    return true;
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
          file: _savedImagePath, // save image path
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
      file: _savedImagePath, // save image path
      // timestamp: default a now
    );
    final trips = await ExpenseGroupStorage.getAllGroups();
    trips.add(newTrip);
    await ExpenseGroupStorage.writeTrips(trips);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // Image handling methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        await _processAndSaveImage(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Errore durante la selezione dell\'immagine')),
        );
      }
    }
  }

  Future<void> _processAndSaveImage(File imageFile) async {
    try {
      // Read the image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        // Resize the image (max 800x600 to keep file size reasonable)
        img.Image resizedImage = img.copyResize(image, width: 800, height: 600);

        // Get the app's documents directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'group_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${appDir.path}/$fileName';

        // Save the resized image as JPEG with 85% quality
        final File savedFile = File(filePath);
        await savedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

        setState(() {
          _selectedImageFile = savedFile;
          _savedImagePath = filePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Errore durante il salvataggio dell\'immagine')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _savedImagePath = null;
    });
  }

  void _showImagePickerDialog() {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(loc.get('from_gallery')),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(loc.get('from_camera')),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Text(loc.get('remove_image')),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
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

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return BaseCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
          ],
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
                // Sezione 1: Nuovo Gruppo
                _buildSectionCard(
                  title: loc.get('new_group'),
                  children: [
                    // Nome gruppo
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      autofocus: widget.trip ==
                          null, // Focus automatico solo in modalità creazione
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(),
                      decoration: InputDecoration(
                        labelText: loc.get('group_name'),
                        labelStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? loc.get('enter_title')
                          : null,
                      onChanged: (value) {
                        setState(
                            () {}); // Aggiorna lo stato per il bottone Salva
                      },
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
                                icon:
                                    const Icon(Icons.calendar_today, size: 18),
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
                                icon:
                                    const Icon(Icons.calendar_today, size: 18),
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
                  title: '', // Titolo vuoto perché lo gestiamo direttamente
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.get('participants'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton.outlined(
                          icon: const Icon(Icons.add),
                          tooltip: loc.get('add'),
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
                                        _participants.add(ExpenseParticipant(
                                            name: val.trim()));
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
                                      final val =
                                          _participantController.text.trim();
                                      if (val.isNotEmpty) {
                                        setState(() {
                                          _participants.add(
                                              ExpenseParticipant(name: val));
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
                    if (_participants.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          loc.get('no_participants'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ),
                    ] else ...[
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
                                    vertical: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          semanticsLabel: loc.get(
                                              'participant_name_semantics',
                                              params: {'name': p.name}),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: loc.get('edit_participant'),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
                                onPressed: () {
                                  final editController =
                                      TextEditingController(text: p.name);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.get('edit_participant')),
                                      content: TextField(
                                        controller: editController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText:
                                              loc.get('participant_name'),
                                          hintText:
                                              loc.get('participant_name_hint'),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty) {
                                            setState(() {
                                              _participants[i] =
                                                  p.copyWith(name: val.trim());
                                            });
                                            _closeDialogAndUnfocus();
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              _closeDialogAndUnfocus(),
                                          child: Text(loc.get('cancel')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final val =
                                                editController.text.trim();
                                            if (val.isNotEmpty) {
                                              setState(() {
                                                _participants[i] =
                                                    p.copyWith(name: val);
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
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                tooltip: loc.get('delete_participant'),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer
                                      .withValues(alpha: 0.1),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
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
                  title: '', // Titolo vuoto perché lo gestiamo direttamente
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.get('categories'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton.outlined(
                          icon: const Icon(Icons.add),
                          tooltip: loc.get('add'),
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
                                          _categories.add(ExpenseCategory(
                                              name: val.trim()));
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
                                        final val =
                                            categoryController.text.trim();
                                        if (val.isNotEmpty) {
                                          setState(() {
                                            _categories.add(
                                                ExpenseCategory(name: val));
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
                    if (_categories.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          loc.get('no_categories'),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ),
                    ] else ...[
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
                                    vertical: 12.0,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.category_outlined,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          semanticsLabel: loc.get(
                                              'category_name_semantics',
                                              params: {'name': c.name}),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: loc.get('edit_category'),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
                                onPressed: () {
                                  final editController =
                                      TextEditingController(text: c.name);
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(loc.get('edit_category')),
                                      content: TextField(
                                        controller: editController,
                                        autofocus: true,
                                        decoration: InputDecoration(
                                          labelText: loc.get('category_name'),
                                          hintText:
                                              loc.get('category_name_hint'),
                                        ),
                                        onSubmitted: (val) {
                                          if (val.trim().isNotEmpty) {
                                            setState(() {
                                              _categories[i] =
                                                  c.copyWith(name: val.trim());
                                            });
                                            _closeDialogAndUnfocus();
                                          }
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              _closeDialogAndUnfocus(),
                                          child: Text(loc.get('cancel')),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final val =
                                                editController.text.trim();
                                            if (val.isNotEmpty) {
                                              setState(() {
                                                _categories[i] =
                                                    c.copyWith(name: val);
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
                                icon:
                                    const Icon(Icons.delete_outline, size: 20),
                                tooltip: loc.get('delete_category'),
                                style: IconButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .errorContainer
                                      .withValues(alpha: 0.1),
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                ),
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
                    // Image selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(loc.get('select_image'),
                                style: Theme.of(context).textTheme.titleMedium),
                            IconButton(
                              onPressed: _showImagePickerDialog,
                              icon: const Icon(Icons.add_photo_alternate),
                            ),
                          ],
                        ),
                        if (_selectedImageFile != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImageFile!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete, size: 16),
                              label: Text(loc.get('remove_image')),
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Currency selector
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
                SizedBox(
                  width: double.infinity,
                  child: ThemedOutlinedButton(
                    onPressed: _isFormValid() ? _saveTrip : null,
                    isPrimary: true,
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
