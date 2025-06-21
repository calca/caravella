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
      'license': 'License',
      'license_mit': 'MIT License',
      'license_hint': 'This app is released under the MIT license.',
      'license_link': 'View MIT License on GitHub',
      'license_section': 'License',
      'latest_expenses': 'Latest expenses',
    },
    'it': {
      'app_title': 'Caravella',
      'trip_history': 'Storico viaggi',
      'no_trips_found': 'Dove vuoi andare?',
      'expenses': 'Spese',
      'participants': 'Partecipanti',
      'participants_label': 'Partecipanti',
      'start_date_label': 'Data inizio',
      'end_date_label': 'Data fine',
      'about': 'Info',
      'settings': 'Impostazioni',
      'license': 'Licenza',
      'license_mit': 'Licenza MIT',
      'license_hint': 'Questa app è distribuita con licenza MIT.',
      'license_link': 'Visualizza licenza MIT',
      'license_section': 'Licenza',
      'latest_expenses': 'Le ultime spese',
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
