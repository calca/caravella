// Simple localization class for EN/ITA, easily extendable
class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static const supportedLocales = ['en', 'it'];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Caravella',
      'trip_history': 'Trip history',
      'no_trips_found': 'Where do you want to go?',
      'expenses': 'Expenses',
      'participants': 'Participants',
      'participants_label': 'Participants',
      'start_date_label': 'Start date',
      'end_date_label': 'End date',
      'about': 'About',
      'settings': 'Settings',
      'settings_title': 'Settings',
      'license': 'License',
      'license_mit': 'MIT License',
      'license_hint': 'This app is released under the MIT license.',
      'license_link': 'View MIT License on GitHub',
      'license_section': 'License',
      'latest_expenses': 'Latest expenses',
      'add_trip': 'Add trip',
      'trip_title': 'Trip title',
      'participants_hint': 'Participants (comma separated)',
      'enter_title': 'Enter a title',
      'enter_participant': 'Enter at least one participant',
      'select_start': 'Select start',
      'select_end': 'Select end',
      'start_date_not_selected': 'Start date not selected',
      'end_date_not_selected': 'End date not selected',
      'save': 'Save',
      'edit_trip': 'Edit trip',
      'delete_trip': 'Delete trip',
      'delete_trip_confirm': 'Are you sure you want to delete this trip?',
      'cancel': 'Cancel',
      'ok': 'OK',
      'from_to': '{start} - {end}',
      'add_expense': 'New expense',
      'edit_expense': 'Edit expense',
      'category': 'Category',
      'amount': 'Amount',
      'paid_by': 'Paid by',
      'today': 'Today',
      'people': 'People',
      'last_week': "Last week",
      'required': 'Required',
      'invalid_amount': 'Invalid amount',
      'no_categories': 'No categories',
      'add_category': 'Add category',
      'category_name': 'Category name',
      'note': 'Note',
      'note_hint': 'Add a note (optional)',
      'select_both_dates': 'Select both start and end date',
      'end_date_after_start': 'End date must be after start date',
      // --- STATISTICS TAB ---
      'expenses_trend_title': 'Expense trend',
      'expenses_trend_desc': 'Track your daily expenses for the last 15 days.',
      'expenses_trend_legend': 'Daily total',
      'expenses_trend_tooltip_amount': '{amount} {currency}',
      'expenses_trend_tooltip_date': '{day}/{month}/{year}',
      'total_last_expenses': 'Total for last {n} days',
      'expenses_by_participant': 'By participant',
      'expenses_by_category': 'By category',
      'uncategorized': 'Uncategorized',
      'amount_with_currency': '{amount} {currency}',
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
      'settings_tab': 'Settings',
      'info_tab': 'Info',
      'select_paid_by': 'Select who paid',
      'select_category': 'Select a category',
      'check_form': 'Check the form data',
      'delete_expense': 'Delete expense',
      'delete_expense_confirm': 'Are you sure you want to delete this expense?',
      'delete': 'Delete',
      'statistics_title': 'Statistics',
      'no_expenses_for_statistics': 'No expenses available for statistics',
      'daily_expenses_chart': 'Daily expenses chart',
      'general_statistics': 'General statistics',
      'total_expenses': 'Total expenses',
      'average_expense': 'Average expense',
      'highest_expense': 'Highest expense',
      'settlement': 'Settlement',
      'all_balanced': 'All accounts are balanced!',
      'owes_to': '{from} owes {to}',
    },
    'it': {
      'app_title': 'Caravella',
      'no_trips_found': 'Dove vuoi andare?',
      'participants_label': 'Partecipanti',
      'participants': 'Partecipanti',
      'start_date_label': 'Data inizio',
      'end_date_label': 'Data fine',
      'about': 'Informazioni',
      'settings': 'Impostazioni',
      'settings_title': 'Configurazioni',
      'license': 'Licenza',
      'license_mit': 'Licenza MIT',
      'license_hint': 'Questa app è distribuita con licenza MIT.',
      'license_link': 'Visualizza licenza MIT',
      'license_section': 'Licenza',
      'latest_expenses': 'Le ultime spese',
      'add_trip': 'Aggiungi un viaggio',
      'trip_title': 'Titolo viaggio',
      'participants_hint': 'Partecipanti (separati da virgola)',
      'enter_title': 'Inserisci un titolo',
      'enter_participant': 'Inserisci almeno un partecipante',
      'select_start': 'Seleziona inizio',
      'select_end': 'Seleziona fine',
      'start_date_not_selected': 'Data inizio non selezionata',
      'end_date_not_selected': 'Data fine non selezionata',
      'save': 'Salva',
      'edit_trip': 'Modifica viaggio',
      'delete_trip': 'Elimina viaggio',
      'delete_trip_confirm': 'Sei sicuro di voler eliminare questo viaggio?',
      'cancel': 'Annulla',
      'ok': 'OK',
      'from_to': '{start} - {end}',
      'add_expense': 'Nuova spesa',
      'edit_expense': 'Modifica spesa',
      'category': 'Categoria',
      'amount': 'Importo',
      'paid_by': 'Pagato da',
      'today': 'Oggi',
      'people': 'Persone',
      'last_week': "L'ultima settimana",
      'required': 'Obbligatorio',
      'invalid_amount': 'Importo non valido',
      'no_categories': 'Nessuna categoria',
      'add_category': 'Aggiungi categoria',
      'category_name': 'Nome categoria',
      'note': 'Note',
      'note_hint': 'Aggiungi una nota (opzionale)',
      'select_both_dates': 'Seleziona sia la data di inizio che di fine',
      'end_date_after_start':
          'La data di fine deve essere successiva a quella di inizio',
      // --- STATISTICS TAB ---
      'expenses_trend_title': 'Andamento spese',
      'expenses_trend_desc':
          'Visualizza le spese giornaliere degli ultimi 15 giorni.',
      'expenses_trend_legend': 'Totale giornaliero',
      'expenses_trend_tooltip_amount': '{amount} {currency}',
      'expenses_trend_tooltip_date': '{day}/{month}/{year}',
      'total_last_expenses': 'Totale ultimi {n} giorni',
      'expenses_by_participant': 'Per partecipante',
      'expenses_by_category': 'Per categoria',
      'uncategorized': 'Senza categoria',
      'amount_with_currency': '{amount} {currency}',
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
      'info_tab': 'Info',
      'select_paid_by': 'Seleziona chi ha pagato',
      'select_category': 'Seleziona una categoria',
      'check_form': 'Controlla i dati inseriti',
      'delete_expense': 'Elimina spesa',
      'delete_expense_confirm': 'Sei sicuro di voler eliminare questa spesa?',
      'delete': 'Elimina',
      'statistics_title': 'Statistiche',
      'no_expenses_for_statistics':
          'Nessuna spesa disponibile per le statistiche',
      'daily_expenses_chart': 'Grafico spese giornaliere',
      'general_statistics': 'Statistiche generali',
      'total_expenses': 'Totale spese',
      'average_expense': 'Spesa media',
      'highest_expense': 'Spesa più alta',
      'settlement': 'Pareggia',
      'all_balanced': 'Tutti i conti sono pari!',
      'owes_to': '{from} deve dare a {to}',
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
