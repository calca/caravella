// Simple localization class for EN/ITA, easily extendable
class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static const supportedLocales = ['en', 'it'];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Saluti dinamici
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'your_groups': 'Your groups',
      'no_active_groups': 'No active groups',
      'no_active_groups_subtitle':
          'Create your first expense group to get started',
      'create_first_group': 'Create first group',

      'new_expense_group': 'New Expense Group',
      'tap_to_create': 'Tap to create',
      'no_expense_label': 'No expenses found',
      'select_image': 'Select Image',
      'image_preview': 'Image Preview',
      'from_gallery': 'From Gallery',
      'from_camera': 'From Camera',
      'remove_image': 'Remove Image',

      'no_trips_found': 'Where do you want to go?',
      'expenses': 'Expenses',
      'participants': 'Participants',
      'participants_label': 'Participants',
      'last_7_days': '7 days',
      'recent_activity': 'Recent activity',
      'about': 'About',
      'license_hint': 'This app is released under the MIT license.',
      'license_link': 'View MIT License on GitHub',
      'license_section': 'License',
      'add_trip': 'Add group',
      'new_group': 'New Group',
      'group_name': 'Group name',
      'enter_title': 'Enter a name',
      'enter_participant': 'Enter at least one participant',
      'select_start': 'Select start',
      'select_end': 'Select end',
      'start_date_not_selected': 'Select start',
      'end_date_not_selected': 'Select end',
      'save': 'Save',
      'delete_trip': 'Delete trip',
      'delete_trip_confirm': 'Are you sure you want to delete this trip?',
      'cancel': 'Cancel',
      'ok': 'OK',
      'from_to': '{start} - {end}',
      'add_expense': 'Add new expense',
      'category': 'Category',
      'amount': 'Amount',
      'invalid_amount': 'Invalid amount',
      'no_categories': 'No categories',
      'add_category': 'Add category',
      'category_name': 'Category name',
      'note': 'Note',
      'note_hint': 'Add a note (optional)',
      'select_both_dates': 'If you select one date, you must select both',
      'select_both_dates_or_none': 'Select both dates or leave both empty',
      'end_date_after_start': 'End date must be after start date',
      'start_date_optional': 'Start (optional)',
      'end_date_optional': 'End (optional)',
      'expenses_by_participant': 'By participant',
      'expenses_by_category': 'By category',
      'uncategorized': 'Uncategorized',
      'backup': 'Backup',
      'no_trips_to_backup': 'No trips to backup',
      'backup_error': 'Backup failed',
      'backup_share_message': 'Here is your Caravella backup',
      'import': 'Import',
      'import_confirm_title': 'Import data',
      'import_confirm_message':
          'Are you sure you want to overwrite all trips with the file "{file}"? This action cannot be undone.',
      'import_success': 'Import successful! Data reloaded.',
      'import_error': 'Import failed. Check the file format.',
      'categories': 'Categories',
      'from': 'From',
      'to': 'To',
      'add': 'Add',
      'participant_name': 'Participant name',
      'participant_name_hint': 'Enter participant name',
      'edit_participant': 'Edit participant',
      'delete_participant': 'Delete participant',
      'add_participant': 'Add participant',
      'no_participants': 'No participants',
      'category_name_hint': 'Enter category name',
      'edit_category': 'Edit category',
      'delete_category': 'Delete category',
      'participant_name_semantics': 'Participant: {name}',
      'category_name_semantics': 'Category: {name}',
      'currency': 'Currency',
      'settings_tab': 'Settings',
      'basic_info': 'Basic Information',
      'settings': 'Settings',
      'history': 'History',
      'all': 'ALL',
      'options': 'OPTIONS',
      'search_groups': 'Search groups...',
      'no_search_results': 'No groups found for',
      'try_different_search': 'Try searching with different words',
    },
    'it': {
      // Saluti dinamici
      'good_morning': 'Buongiorno',
      'good_afternoon': 'Buon pomeriggio',
      'good_evening': 'Buonasera',
      'your_groups': 'I tuoi gruppi',
      'no_active_groups': 'Nessun gruppo attivo',
      'no_active_groups_subtitle': 'Crea il primo gruppo di spese per iniziare',
      'create_first_group': 'Crea primo gruppo',

      'new_expense_group': 'Nuovo Gruppo di Spese',
      'tap_to_create': 'Tocca per creare',
      'no_expense_label': 'Nessuna spesa trovata',
      'select_image': 'Seleziona Immagine',
      'image_preview': 'Anteprima Immagine',
      'from_gallery': 'Dalla Galleria',
      'from_camera': 'Dalla Fotocamera',
      'remove_image': 'Rimuovi Immagine',

      'no_trips_found': 'Dove vuoi andare?',
      'expenses': 'Spese',
      'participants_label': 'Partecipanti',
      'participants': 'Partecipanti',
      'last_7_days': '7 giorni',
      'recent_activity': 'Attività recente',
      'about': 'Informazioni',
      'license_hint': 'Questa app è distribuita con licenza MIT.',
      'license_link': 'Visualizza licenza MIT',
      'license_section': 'Licenza',
      'add_trip': 'Aggiungi un gruppo',
      'new_group': 'Nuovo Gruppo',
      'group_name': 'Nome gruppo',
      'enter_title': 'Inserisci un nome',
      'enter_participant': 'Inserisci almeno un partecipante',
      'select_start': 'Seleziona inizio',
      'select_end': 'Seleziona fine',
      'start_date_not_selected': 'Seleziona inizio',
      'end_date_not_selected': 'Seleziona fine',
      'save': 'Salva',
      'delete_trip': 'Elimina viaggio',
      'delete_trip_confirm': 'Sei sicuro di voler eliminare questo viaggio?',
      'cancel': 'Annulla',
      'ok': 'OK',
      'from_to': '{start} - {end}',
      'add_expense': 'Aggiungi spesa',
      'category': 'Categoria',
      'amount': 'Importo',
      'invalid_amount': 'Importo non valido',
      'no_categories': 'Nessuna categoria',
      'add_category': 'Aggiungi categoria',
      'category_name': 'Nome categoria',
      'note': 'Note',
      'note_hint': 'Aggiungi una nota (opzionale)',
      'select_both_dates': 'Se selezioni una data, devi selezionare entrambe',
      'select_both_dates_or_none':
          'Seleziona entrambe le date o lascia entrambe vuote',
      'end_date_after_start':
          'La data di fine deve essere successiva a quella di inizio',
      'start_date_optional': 'Inizio (opzionale)',
      'end_date_optional': 'Fine (opzionale)',
      'expenses_by_participant': 'Per partecipante',
      'expenses_by_category': 'Per categoria',
      'uncategorized': 'Senza categoria',
      'backup': 'Backup',
      'no_trips_to_backup': 'Nessun viaggio da salvare',
      'backup_error': 'Backup non riuscito',
      'backup_share_message': 'Ecco il backup di Caravella',
      'import': 'Importa',
      'import_confirm_title': 'Importa dati',
      'import_confirm_message':
          'Sicuro di voler sovrascrivere tutti i viaggi con il file "{file}"? L’operazione non è reversibile.',
      'import_success': 'Import riuscito! Dati ricaricati.',
      'import_error': 'Import fallito. Controlla il formato del file.',
      'categories': 'Categorie',
      'from': 'Dal',
      'to': 'Al',
      'add': 'Aggiungi',
      'participant_name': 'Nome partecipante',
      'participant_name_hint': 'Inserisci il nome del partecipante',
      'edit_participant': 'Modifica partecipante',
      'delete_participant': 'Elimina partecipante',
      'add_participant': 'Aggiungi partecipante',
      'no_participants': 'Nessun partecipante',
      'category_name_hint': 'Inserisci il nome della categoria',
      'edit_category': 'Modifica categoria',
      'delete_category': 'Elimina categoria',
      'participant_name_semantics': 'Partecipante: {name}',
      'category_name_semantics': 'Categoria: {name}',
      'currency': 'Valuta',
      'settings_tab': 'Impostazioni',
      'basic_info': 'Informazioni di base',
      'settings': 'Impostazioni',
      'history': 'Cronologia',
      'all': 'TUTTI',
      'options': 'OPZIONI',
      'info_tab': 'Info',
      'select_paid_by': 'Seleziona chi ha pagato',
      'select_category': 'Seleziona una categoria',
      'check_form': 'Controlla i dati inseriti',
      'delete_expense': 'Elimina spesa',
      'delete_expense_confirm': 'Sei sicuro di voler eliminare questa spesa?',
      'delete': 'Elimina',
      'no_expenses_for_statistics':
          'Nessuna spesa disponibile per le statistiche',
      'daily_expenses_chart': 'Grafico spese giornaliere',
      'general_statistics': 'Statistiche generali',
      'average_expense': 'Spesa media',
      'settlement': 'Pareggia',
      'all_balanced': 'Tutti i conti sono pari!',
      // Welcome section v3 - Clean design
      'welcome_v3_title': 'Le tue\nspese di gruppo,\nin modo semplice',
      'welcome_v3_cta': 'Inizia!',
    },
  };

  String get(String key, {Map<String, String>? params}) {
    String value = _localizedValues[locale]?[key] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        value = value.replaceAll('{$k}', v);
      });
    }
    return value;
  }
}
