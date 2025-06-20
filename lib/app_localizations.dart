// Simple localization class for EN/ITA, easily extendable
class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);

  static const supportedLocales = ['en', 'it'];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Caravella',
      'trip_history': 'Trip history',
      'no_trips_found': 'No trips found',
      'expenses': 'Expenses',
      'participants': 'Participants',
      'from_to': 'From {start} to {end}',
      'add_trip': 'Add trip',
      'trip_title': 'Trip title',
      'enter_title': 'Enter a title',
      'participants_hint': 'Participants (comma separated)',
      'enter_participant': 'Enter at least one participant',
      'start_date_not_selected': 'Start date not selected',
      'end_date_not_selected': 'End date not selected',
      'select_start': 'Select start',
      'select_end': 'Select end',
      'save': 'Save',
      'no_trip_found': 'No trip found',
      'total_spent': 'Total spent:',
      'add_expense': 'Add expense',
      'history': 'History',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'period': 'Period: {start} - {end}',
      'add': 'Add',
      'paid_by': 'Paid by',
      'date': 'Date',
      'category': 'Category',
      'amount': 'Amount',
      'required': 'Required',
      'invalid_amount': 'Invalid amount',
      'no_expenses': 'No expenses',
    },
    'it': {
      'app_title': 'Caravella',
      'trip_history': 'Storico viaggi',
      'no_trips_found': 'Nessun viaggio trovato',
      'expenses': 'Spese',
      'participants': 'Partecipanti',
      'from_to': 'Dal {start} al {end}',
      'add_trip': 'Aggiungi viaggio',
      'trip_title': 'Titolo viaggio',
      'enter_title': 'Inserisci un titolo',
      'participants_hint': 'Partecipanti (separati da virgola)',
      'enter_participant': 'Inserisci almeno un partecipante',
      'start_date_not_selected': 'Data inizio non selezionata',
      'end_date_not_selected': 'Data fine non selezionata',
      'select_start': 'Seleziona inizio',
      'select_end': 'Seleziona fine',
      'save': 'Salva',
      'no_trip_found': 'Nessun viaggio trovato',
      'total_spent': 'Totale speso:',
      'add_expense': 'Aggiungi spesa',
      'history': 'Storico',
      'cancel': 'Annulla',
      'edit': 'Modifica',
      'period': 'Periodo: {start} - {end}',
      'add': 'Aggiungi',
      'paid_by': 'Pagato da',
      'date': 'Data',
      'category': 'Categoria',
      'amount': 'Importo',
      'required': 'Obbligatorio',
      'invalid_amount': 'Importo non valido',
      'no_expenses': 'Nessuna spesa',
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
