// Widget simile a quello incollato per la selezione valuta
import 'package:flutter/material.dart';
import 'widgets/participants_section.dart';
import 'widgets/categories_section.dart';
import 'widgets/section_flat.dart';
import 'widgets/selection_tile.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'image_crop_page.dart';
import '../../data/expense_group.dart';
import '../../data/expense_participant.dart';
import '../../data/expense_category.dart';
import '../../../data/expense_group_storage.dart';
import '../../app_localizations.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../state/expense_group_notifier.dart';
import '../../widgets/caravella_app_bar.dart';
import 'widgets/section_period.dart';
import '../../widgets/app_toast.dart';

class AddNewExpensesGroupPage extends StatefulWidget {
  final ExpenseGroup? trip;
  final VoidCallback? onTripDeleted;
  const AddNewExpensesGroupPage({super.key, this.trip, this.onTripDeleted});

  @override
  State<AddNewExpensesGroupPage> createState() =>
      AddNewExpensesGroupPageState();
}

class AddNewExpensesGroupPageState extends State<AddNewExpensesGroupPage> {
  // Loader state for image
  bool _loadingImage = false;
  // Currency sheet scroll controller
  final ScrollController _currencySheetScrollController = ScrollController();

  void _showCurrencySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
  final gloc = gen.AppLocalizations.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gloc.select_currency,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 320, // reasonable height for modal scroll
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _currencySheetScrollController,
                      child: ListView.builder(
                        controller: _currencySheetScrollController,
                        itemCount: _currencies.length,
                        itemBuilder: (context, index) {
                          final currency = _currencies[index];
                          return ListTile(
                            leading: Text(
                              currency['symbol']!,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            title: Text(
                              '${currency['code']} - ${currency['name']}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing:
                                currency['symbol'] ==
                                    _selectedCurrency['symbol']
                                ? Icon(
                                    Icons.check,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCurrency = currency;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Controllers and focus nodes
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final TextEditingController _participantController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Participants and categories
  final List<ExpenseParticipant> _participants = [];
  final List<ExpenseCategory> _categories = [];

  // Dates
  DateTime? _startDate;
  DateTime? _endDate;
  String? _dateError;

  // Image handling
  File? _selectedImageFile;
  String? _savedImagePath;
  final ImagePicker _imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      final found = _currencies.firstWhere(
        (c) => c['symbol'] == widget.trip!.currency,
        orElse: () => _currencies[0],
      );
      _selectedCurrency = found;
      _categories.addAll(widget.trip!.categories);
      _savedImagePath = widget.trip!.file;
      if (_savedImagePath != null) {
        _selectedImageFile = File(_savedImagePath!);
      }
      // Precompila nome, partecipanti e date
      _titleController.text = widget.trip!.title;
      _participants.addAll(widget.trip!.participants);
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
    }
  }

  // Remove stray constructor declaration
  // List of available currencies (customize as needed)
  final List<Map<String, String>> _currencies = [
    {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
    {'symbol': '\u0024', 'code': 'USD', 'name': 'US Dollar'},
    {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
    {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen'},
    {'symbol': '₽', 'code': 'RUB', 'name': 'Russian Ruble'},
    {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee'},
    {'symbol': '₺', 'code': 'TRY', 'name': 'Turkish Lira'},
    {'symbol': '₩', 'code': 'KRW', 'name': 'South Korean Won'},
    {'symbol': '₪', 'code': 'ILS', 'name': 'Israeli Shekel'},
    {'symbol': '₫', 'code': 'VND', 'name': 'Vietnamese Dong'},
    {'symbol': '₴', 'code': 'UAH', 'name': 'Ukrainian Hryvnia'},
    {'symbol': '₦', 'code': 'NGN', 'name': 'Nigerian Naira'},
    {'symbol': '₲', 'code': 'PYG', 'name': 'Paraguayan Guarani'},
    {'symbol': '₵', 'code': 'GHS', 'name': 'Ghanaian Cedi'},
    {'symbol': '₡', 'code': 'CRC', 'name': 'Costa Rican Colon'},
    {'symbol': '₱', 'code': 'PHP', 'name': 'Philippine Peso'},
    {'symbol': '฿', 'code': 'THB', 'name': 'Thai Baht'},
    {'symbol': '₸', 'code': 'KZT', 'name': 'Kazakhstani Tenge'},
    {'symbol': '₭', 'code': 'LAK', 'name': 'Lao Kip'},
    {'symbol': '₮', 'code': 'MNT', 'name': 'Mongolian Tögrög'},
  ];

  Map<String, String> _selectedCurrency = {
    'symbol': '€',
    'code': 'EUR',
    'name': 'Euro',
  };

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
    _currencySheetScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
  final gloc = gen.AppLocalizations.of(context);
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 5);
    final lastDate = DateTime(now.year + 5);
    DateTime? initialDate = isStart ? (_startDate ?? now) : (_endDate ?? now);
    bool isSelectable(DateTime d) {
      if (isStart && _endDate != null) return !d.isAfter(_endDate!);
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
  helpText: isStart ? gloc.select_from_date : gloc.select_to_date,
  cancelText: gloc.cancel,
  confirmText: gloc.ok,
  locale: Locale(Localizations.localeOf(context).languageCode),
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
  final gloc = gen.AppLocalizations.of(context);
    if (!mounted) return;
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
      if (!mounted) return;
  setState(() { _dateError = gloc.select_both_dates; });
      if (!mounted) return;
  AppToast.show(context, gloc.select_both_dates, type: ToastType.error);
      return;
    }

    // Se entrambe le date sono specificate, controlla che l'ordine sia corretto
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
  setState(() { _dateError = gloc.end_date_after_start; });
  AppToast.show(context, gloc.end_date_after_start, type: ToastType.error);
      return;
    }

    if (_participants.isEmpty) {
  AppToast.show(context, gloc.enter_participant, type: ToastType.error);
      return;
    }

    try {
      if (widget.trip != null) {
        // EDIT: update existing trip
        final trips = await ExpenseGroupStorage.getAllGroups();
        if (!mounted) return;
        final idx = trips.indexWhere((v) => v.id == widget.trip!.id);
        if (idx != -1) {
          // Crea una nuova istanza del gruppo con i dati aggiornati
          final updatedTrip = ExpenseGroup(
            title: _titleController.text.trim(),
            expenses: trips[idx].expenses, // keep expenses
            participants: List.from(
              _participants,
            ), // Copia la lista dei partecipanti
            startDate: _startDate,
            endDate: _endDate,
            currency: _selectedCurrency['symbol']!,
            categories: List.from(
              _categories,
            ), // Copia la lista delle categorie
            timestamp: trips[idx].timestamp, // mantieni il timestamp originale
            id: trips[idx].id, // mantieni l'id originale
            file: _savedImagePath, // save image path
            pinned: trips[idx].pinned, // mantieni lo stato pinned
          );

          trips[idx] = updatedTrip;
          await ExpenseGroupStorage.writeTrips(trips);
          if (!mounted) return;
          // Notifica l'aggiornamento al notifier
          final groupNotifier = context.read<ExpenseGroupNotifier>();
          if (groupNotifier.currentGroup?.id == updatedTrip.id) {
            await groupNotifier.updateGroup(updatedTrip);
          } else {
            // Notifica che questo gruppo è stato aggiornato anche se non è quello corrente
            groupNotifier.notifyGroupUpdated(updatedTrip.id);
          }
          if (!mounted) return;
          Navigator.of(context).pop(true);
          return;
        }
      }

      // CREATE: add new trip
      final newTrip = ExpenseGroup(
        title: _titleController.text.trim(),
        expenses: [],
        participants: List.from(
          _participants,
        ), // Copia la lista dei partecipanti
        startDate: _startDate,
        endDate: _endDate,
        currency: _selectedCurrency['symbol']!,
        categories: List.from(_categories), // Copia la lista delle categorie
        file: _savedImagePath, // save image path
        // timestamp: default a now
      );

      final trips = await ExpenseGroupStorage.getAllGroups();
      if (!mounted) return;
      trips.add(newTrip);
      await ExpenseGroupStorage.writeTrips(trips);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      // Dopo await ExpenseGroupStorage.writeTrips/trips.add, ricontrolla mounted
      AppToast.show(
        context,
        'Errore durante il salvataggio: ${e.toString()}',
        type: ToastType.error,
      );
    }
  }

  // Image handling methods
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _loadingImage = true);
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (!mounted) return;
      if (pickedFile != null) {
        // Naviga alla pagina di crop
        final croppedFile = await Navigator.of(context).push<File?>(
          MaterialPageRoute(
            builder: (context) =>
                ImageCropPage(imageFile: File(pickedFile.path)),
          ),
        );
        if (!mounted) return;
        if (croppedFile != null) {
          await _processAndSaveImage(croppedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Errore durante la selezione dell\'immagine',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  Future<void> _processAndSaveImage(File imageFile) async {
    try {
      setState(() => _loadingImage = true);
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
        AppToast.show(
          context,
          'Errore durante il salvataggio dell\'immagine',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _loadingImage = false);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _savedImagePath = null;
    });
  }

  void _showImagePickerDialog() {
  final gloc = gen.AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(gloc.from_gallery),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(gloc.from_camera),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedImageFile != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text(gloc.remove_image),
                    onTap: () {
                      Navigator.of(context).pop();
                      _removeImage();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
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

  // Removed _buildSectionFlat method

  @override
  Widget build(BuildContext context) {
  final gloc = gen.AppLocalizations.of(context);
  final loc = AppLocalizations(gloc); // bridge instance for children expecting old API
    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: CaravellaAppBar(
          actions: [
            if (widget.trip != null)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: gloc.delete,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(gloc.delete_trip),
                      content: Text(gloc.delete_trip_confirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(gloc.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(gloc.delete),
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
                // Titolo principale dinamico
                Text(
                  widget.trip != null
                      ? gloc.edit_group
                      : gloc.new_group,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Sezione 1: Informazioni di base
                SectionFlat(
                  title: '',
                  children: [
                    // Nome gruppo
                    Row(
                      children: [
                        Text(
                          gloc.group_name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '*',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      autofocus: widget.trip == null,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        labelText: '',
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? gloc.enter_title
                          : null,
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),

                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _dateError!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.error, // Use theme error color
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sezione 2: Partecipanti
                ParticipantsSection(
                  participants: _participants,
                  participantController: _participantController,
                  loc: loc,
                  onAddParticipant: (String name) {
                    setState(() {
                      _participants.add(ExpenseParticipant(name: name));
                    });
                  },
                  onEditParticipant: (int i, String name) {
                    setState(() {
                      _participants[i] = _participants[i].copyWith(name: name);
                    });
                  },
                  onRemoveParticipant: (int i) {
                    setState(() {
                      _participants.removeAt(i);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Sezione 3: Categorie
                CategoriesSection(
                  categories: _categories,
                  loc: loc,
                  onAddCategory: (String name) {
                    setState(() {
                      _categories.add(ExpenseCategory(name: name));
                    });
                  },
                  onEditCategory: (int i, String name) {
                    setState(() {
                      _categories[i] = _categories[i].copyWith(name: name);
                    });
                  },
                  onRemoveCategory: (int i) {
                    setState(() {
                      _categories.removeAt(i);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Sezione 4: Periodo
                SectionPeriod(
                  startDate: _startDate,
                  endDate: _endDate,
                  onPickDate: (isStart) => _pickDate(context, isStart),
                  onClearDates: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  loc: loc,
                ),
                const SizedBox(height: 24),

                // Sezione 5: Impostazioni (label rimossa)
                SectionFlat(
                  title: '',
                  children: [
                    // Currency selector PRIMA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gloc.currency,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SelectionTile(
                          leading: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 32,
                          ),
                          title: _selectedCurrency['name']!,
                          subtitle:
                              '0${_selectedCurrency['symbol']} ${_selectedCurrency['code']}',
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 24,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          onTap: _showCurrencySheet,
                          borderRadius: 8,
                          padding: const EdgeInsets.only(
                            left: 8,
                            top: 8,
                            bottom: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Image selection DOPO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gloc.image,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            _unfocusAll();
                            if (_selectedImageFile != null) {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: Text(gloc.change_image),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _showImagePickerDialog();
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: Text(gloc.remove_image),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _removeImage();
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } else {
                              _showImagePickerDialog();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                // Leading icon or image
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: _loadingImage
                                      ? const Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        )
                                      : (_selectedImageFile == null
                                            ? Icon(
                                                Icons.image_outlined,
                                                size: 32,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  _selectedImageFile!,
                                                  fit: BoxFit.cover,
                                                  width: 48,
                                                  height: 48,
                                                ),
                                              )),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedImageFile == null
                                            ? gloc.select_image
                                            : 'Modifica Immagine',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'PNG, JPG, GIF fino a 10MB',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ...existing code...
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Bottoni di azione
                Column(
                  children: [
                    // Bottone Annulla
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(gloc.cancel),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bottone Salva
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isFormValid() ? _saveTrip : null,
                        child: Text(gloc.save),
                      ),
                    ),
                  ],
                ),
                // Spazio extra per la navigation bar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
