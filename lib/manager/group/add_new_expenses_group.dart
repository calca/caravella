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
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import '../../state/expense_group_notifier.dart';
import '../../widgets/caravella_app_bar.dart';
import '../expense/expense_form/icon_leading_field.dart';
import '../../themes/app_text_styles.dart';
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
  // Removed participant controller (now inline add/edit)

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
  bool _isDirty = false; // traccia modifiche non salvate
  
  // Color handling
  int? _selectedColor;
  // Removed auto bottom sheet prompt flag (inline editing now)
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
      _selectedColor = widget.trip!.color;
      if (_savedImagePath != null) {
        _selectedImageFile = File(_savedImagePath!);
      }
      // Precompila nome, partecipanti e date
      _titleController.text = widget.trip!.title;
      _participants.addAll(widget.trip!.participants);
      _startDate = widget.trip!.startDate;
      _endDate = widget.trip!.endDate;
    }
    _titleController.addListener(() {
      if (!_isDirty) setState(() => _isDirty = true);
    });

    // Apri automaticamente l'editor nome se nuovo gruppo e nome vuoto
    // Nessun bottom sheet automatico: il campo è inline ora
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
    // _participantController removed
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
      setState(() {
        _dateError = gloc.select_both_dates;
      });
      if (!mounted) return;
      AppToast.show(context, gloc.select_both_dates, type: ToastType.error);
      return;
    }

    // Se entrambe le date sono specificate, controlla che l'ordine sia corretto
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      setState(() {
        _dateError = gloc.end_date_after_start;
      });
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
            color: _selectedColor, // save color
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
        color: _selectedColor, // save color
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
      final gl = gen.AppLocalizations.of(context);
      AppToast.show(
        context,
        gl.error_saving_group(e.toString()),
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
          gen.AppLocalizations.of(context).error_selecting_image,
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
          _selectedColor = null; // Clear color when image is set
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          gen.AppLocalizations.of(context).error_saving_image,
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
      // Don't auto-restore color when removing image
    });
  }

  void _selectColor(int color) {
    setState(() {
      _selectedColor = color;
      // Clear image when color is selected (mutual exclusivity)
      if (_selectedImageFile != null || _savedImagePath != null) {
        _selectedImageFile = null;
        _savedImagePath = null;
      }
      _isDirty = true;
    });
  }

  void _removeColor() {
    setState(() {
      _selectedColor = null;
      _isDirty = true;
    });
  }

  // Predefined color palette
  static const List<int> _predefinedColors = [
    0xFFE57373, // Red
    0xFFFFB74D, // Orange  
    0xFFFFF176, // Yellow
    0xFFAED581, // Light Green
    0xFF81C784, // Green
    0xFF4DB6AC, // Teal
    0xFF64B5F6, // Blue
    0xFF9575CD, // Purple
    0xFFF06292, // Pink
    0xFFFF8A65, // Deep Orange
    0xFFDCE775, // Lime
    0xFF4FC3F7, // Light Blue
  ];

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

  // Rimosso _editGroupName (non più necessario)

  // Removed _buildSectionFlat method

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    return GestureDetector(
      onTap: _unfocusAll,
      behavior: HitTestBehavior.translucent,
      child: PopScope(
        canPop: !_isDirty,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_isDirty) {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(gloc.discard_changes_title),
                content: Text(gloc.discard_changes_message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(gloc.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(gloc.discard),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) navigator.pop(false);
            }
          }
        },
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
                      builder: (dialogCtx) => AlertDialog(
                        title: Text(gloc.delete_trip),
                        content: Text(gloc.delete_trip_confirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(false),
                            child: Text(gloc.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogCtx).pop(true),
                            child: Text(gloc.delete),
                          ),
                        ],
                      ),
                    );
                    if (!context.mounted || confirm != true) return;
                    final trips = await ExpenseGroupStorage.getAllGroups();
                    if (!context.mounted) return;
                    trips.removeWhere((v) => v.id == widget.trip!.id);
                    await ExpenseGroupStorage.writeTrips(trips);
                    if (!context.mounted) return;
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(true);
                    }
                    widget.onTripDeleted?.call();
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyMedium,
                child: ListView(
                  children: [
                    // Titolo principale dinamico
                    Text(
                      widget.trip != null ? gloc.edit_group : gloc.new_group,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),

                    // Sezione 1: Informazioni di base
                    SectionFlat(
                      title: '',
                      children: [
                        // Nome gruppo
                        IconLeadingField(
                          icon: const Icon(Icons.title_outlined),
                          semanticsLabel: gloc.group_name,
                          tooltip: gloc.group_name,
                          child: TextField(
                            controller: _titleController,
                            autofocus: true, // focus diretto sul primo campo
                            textInputAction: TextInputAction.next,
                            onChanged: (v) {
                              setState(() {}); // refresh per validazione inline
                            },
                            decoration: InputDecoration(
                              hintText: gloc.group_name,
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        if (_titleController.text.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '* ${gloc.enter_title}',
                              style: AppTextStyles.listItem(context)?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),

                        if (_dateError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _dateError!,
                              style: AppTextStyles.listItem(context)?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sezione 2: Partecipanti
                    ParticipantsSection(
                      participants: _participants,
                      onAddParticipant: (String name) {
                        setState(() {
                          _participants.add(ExpenseParticipant(name: name));
                          _isDirty = true;
                        });
                      },
                      onEditParticipant: (int i, String name) {
                        setState(() {
                          _participants[i] = _participants[i].copyWith(
                            name: name,
                          );
                          _isDirty = true;
                        });
                      },
                      onRemoveParticipant: (int i) {
                        setState(() {
                          _participants.removeAt(i);
                          _isDirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sezione 3: Categorie
                    CategoriesSection(
                      categories: _categories,
                      onAddCategory: (String name) {
                        setState(() {
                          _categories.add(ExpenseCategory(name: name));
                          _isDirty = true;
                        });
                      },
                      onEditCategory: (int i, String name) {
                        setState(() {
                          _categories[i] = _categories[i].copyWith(name: name);
                          _isDirty = true;
                        });
                      },
                      onRemoveCategory: (int i) {
                        setState(() {
                          _categories.removeAt(i);
                          _isDirty = true;
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
                              style: Theme.of(context).textTheme.bodyMedium
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
                              style: Theme.of(context).textTheme.bodyMedium
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
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
                                                child:
                                                    CircularProgressIndicator(
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
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _selectedImageFile == null
                                                ? gloc.select_image
                                                : gloc.change_image,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            gloc.image_requirements,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 24,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
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
                    const SizedBox(height: 24),

                    // Sezione 6: Colore
                    SectionFlat(
                      title: '',
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gloc.color,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              gloc.color_alternative,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            // Color palette
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _predefinedColors.map((colorValue) {
                                final color = Color(colorValue);
                                final isSelected = _selectedColor == colorValue;
                                return GestureDetector(
                                  onTap: () {
                                    if (isSelected) {
                                      _removeColor();
                                    } else {
                                      _selectColor(colorValue);
                                    }
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Theme.of(context).colorScheme.primary,
                                              width: 3,
                                            )
                                          : Border.all(
                                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: color.computeLuminance() > 0.5 
                                                ? Colors.black 
                                                : Colors.white,
                                            size: 24,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_selectedColor != null) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _removeColor,
                                icon: const Icon(Icons.clear),
                                label: Text(gloc.remove_color),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Bottoni di azione
                    Column(
                      children: [
                        // Bottone Salva (mantiene stile button default, non bodyMedium)
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isFormValid() ? _saveTrip : null,
                            child: Text(
                              gloc.save,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Spazio extra per la navigation bar
                    const SizedBox(height: 80),
                  ],
                ), // end ListView
              ), // end DefaultTextStyle.merge
            ),
          ),
        ),
      ),
    );
  }
}
