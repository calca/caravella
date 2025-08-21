// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get weeklyChartBadge => 'S';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get weeklyExpensesChart => 'Spese settimanali';

  @override
  String get monthlyExpensesChart => 'Spese mensili';

  @override
  String get settings_flag_secure_desc =>
      'Impedisce screenshot e registrazione schermo';

  @override
  String get settings_flag_secure_title => 'Proteggi schermata';

  @override
  String get select_currency => 'Seleziona valuta';

  @override
  String get select_period_hint_short => 'Imposta date';

  @override
  String get select_period_hint => 'Seleziona un intervallo di date';

  @override
  String get in_group_prefix => 'in';

  @override
  String get save_change_expense => 'Salva modifiche';

  @override
  String get group_total => 'Totale';

  @override
  String get download_all_csv => 'Scarica tutto (CSV)';

  @override
  String get share_all_csv => 'Condividi tutto (CSV)';

  @override
  String get welcome_v3_title => 'Organizza.\nCondividi.\nBilancia.\n ';

  @override
  String get good_morning => 'Buongiorno';

  @override
  String get good_afternoon => 'Buon pomeriggio';

  @override
  String get good_evening => 'Buonasera';

  @override
  String get your_groups => 'I tuoi gruppi';

  @override
  String get no_active_groups => 'Nessun gruppo attivo';

  @override
  String get no_active_groups_subtitle =>
      'Crea il primo gruppo di spese per iniziare';

  @override
  String get create_first_group => 'Crea primo gruppo';

  @override
  String get new_expense_group => 'Nuovo Gruppo di Spese';

  @override
  String get tap_to_create => 'Tocca per creare';

  @override
  String get no_expense_label => 'Nessuna spesa trovata';

  @override
  String get image => 'Immagine';

  @override
  String get select_image => 'Seleziona Immagine';

  @override
  String get change_image => 'Cambia Immagine';

  @override
  String get from_gallery => 'Dalla Galleria';

  @override
  String get from_camera => 'Dalla Fotocamera';

  @override
  String get remove_image => 'Rimuovi Immagine';

  @override
  String get color => 'Colore';

  @override
  String get remove_color => 'Rimuovi Colore';

  @override
  String get color_alternative => 'Alternativa all\'immagine';

  @override
  String get no_trips_found => 'Dove vuoi andare?';

  @override
  String get expenses => 'Spese';

  @override
  String get participants => 'Partecipanti';

  @override
  String get participants_label => 'Partecipanti';

  @override
  String get last_7_days => '7 giorni';

  @override
  String get recent_activity => 'Attività recente';

  @override
  String get about => 'Informazioni';

  @override
  String get license_hint => 'Questa app è distribuita con licenza MIT.';

  @override
  String get license_link => 'Visualizza licenza MIT';

  @override
  String get license_section => 'Licenza';

  @override
  String get add_trip => 'Aggiungi un gruppo';

  @override
  String get new_group => 'Nuovo Gruppo';

  @override
  String get group_name => 'Nome';

  @override
  String get enter_title => 'Inserisci un nome';

  @override
  String get enter_participant => 'Inserisci almeno un partecipante';

  @override
  String get select_start => 'Seleziona inizio';

  @override
  String get select_end => 'Seleziona fine';

  @override
  String get start_date_not_selected => 'Seleziona inizio';

  @override
  String get end_date_not_selected => 'Seleziona fine';

  @override
  String get select_from_date => 'Seleziona inizio';

  @override
  String get select_to_date => 'Seleziona fine';

  @override
  String get date_range_not_selected => 'Seleziona periodo';

  @override
  String get date_range_partial => 'Seleziona entrambe le date';

  @override
  String get save => 'Salva';

  @override
  String get delete_trip => 'Elimina viaggio';

  @override
  String get delete_trip_confirm =>
      'Sei sicuro di voler eliminare questo viaggio?';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String from_to(Object end, Object start) {
    return '$start - $end';
  }

  @override
  String get add_expense => 'Nuova spesa';

  @override
  String get edit_expense => 'Modifica spesa';

  @override
  String get category => 'Categoria';

  @override
  String get amount => 'Importo';

  @override
  String get invalid_amount => 'Importo non valido';

  @override
  String get no_categories => 'Nessuna categoria';

  @override
  String get add_category => 'Aggiungi categoria';

  @override
  String get category_name => 'Nome categoria';

  @override
  String get note => 'Nota';

  @override
  String get note_hint => 'Nota';

  @override
  String get select_both_dates =>
      'Se selezioni una data, devi selezionare entrambe';

  @override
  String get select_both_dates_or_none =>
      'Seleziona entrambe le date o lascia entrambe vuote';

  @override
  String get end_date_after_start =>
      'La data di fine deve essere successiva a quella di inizio';

  @override
  String get start_date_optional => 'Dal';

  @override
  String get end_date_optional => 'Al';

  @override
  String get dates => 'Periodo';

  @override
  String get expenses_by_participant => 'Per partecipante';

  @override
  String get expenses_by_category => 'Per categoria';

  @override
  String get uncategorized => 'Senza categoria';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'Nessun viaggio da salvare';

  @override
  String get backup_error => 'Backup non riuscito';

  @override
  String get backup_share_message => 'Ecco il backup di Caravella';

  @override
  String get import => 'Importa';

  @override
  String get import_confirm_title => 'Importa dati';

  @override
  String import_confirm_message(Object file) {
    return 'Sicuro di voler sovrascrivere tutti i viaggi con il file \"$file\"? L’operazione non è reversibile.';
  }

  @override
  String get import_success => 'Import riuscito! Dati ricaricati.';

  @override
  String get import_error => 'Import fallito. Controlla il formato del file.';

  @override
  String get categories => 'Categorie';

  @override
  String get from => 'Dal';

  @override
  String get to => 'Al';

  @override
  String get add => 'Aggiungi';

  @override
  String get participant_name => 'Nome partecipante';

  @override
  String get participant_name_hint => 'Inserisci il nome del partecipante';

  @override
  String get edit_participant => 'Modifica partecipante';

  @override
  String get delete_participant => 'Elimina partecipante';

  @override
  String get add_participant => 'Aggiungi partecipante';

  @override
  String get no_participants => 'Nessun partecipante';

  @override
  String get category_name_hint => 'Inserisci il nome della categoria';

  @override
  String get edit_category => 'Modifica categoria';

  @override
  String get delete_category => 'Elimina categoria';

  @override
  String participant_name_semantics(Object name) {
    return 'Partecipante: $name';
  }

  @override
  String category_name_semantics(Object name) {
    return 'Categoria: $name';
  }

  @override
  String get currency => 'Valuta';

  @override
  String get settings_tab => 'Impostazioni';

  @override
  String get basic_info => 'Informazioni di base';

  @override
  String get settings => 'Impostazioni';

  @override
  String get history => 'Cronologia';

  @override
  String get all => 'TUTTI';

  @override
  String get search_groups => 'Cerca gruppi...';

  @override
  String get no_search_results => 'Nessun gruppo trovato per';

  @override
  String get try_different_search => 'Prova a cercare con parole diverse';

  @override
  String get active => 'Attivo';

  @override
  String get archived => 'Archiviato';

  @override
  String get archive => 'Archivia';

  @override
  String get unarchive => 'Disarchivia';

  @override
  String get archive_confirm => 'Vuoi archiviare';

  @override
  String get unarchive_confirm => 'Vuoi disarchiviare';

  @override
  String get overview => 'Panoramica';

  @override
  String get statistics => 'Statistiche';

  @override
  String get options => 'Opzioni';

  @override
  String get show_overview => 'Mostra panoramica';

  @override
  String get show_statistics => 'Mostra statistiche';

  @override
  String get no_expenses_to_display => 'Nessuna spesa da visualizzare';

  @override
  String get no_expenses_to_analyze => 'Nessuna spesa da analizzare';

  @override
  String get select_expense_date => 'Seleziona data spesa';

  @override
  String get select_expense_date_short => 'Seleziona data';

  @override
  String get date => 'Data';

  @override
  String get edit_group => 'Modifica gruppo';

  @override
  String get delete_group => 'Elimina gruppo';

  @override
  String get delete_group_confirm =>
      'Sei sicuro di voler eliminare questo gruppo di spese? Questa azione non può essere annullata.';

  @override
  String get add_expense_fab => 'Aggiungi Spesa';

  @override
  String get pin_group => 'Aggiungi pin';

  @override
  String get unpin_group => 'Rimuovi pin';

  @override
  String get theme_automatic => 'Automatico';

  @override
  String get theme_light => 'Chiaro';

  @override
  String get theme_dark => 'Scuro';

  @override
  String get developed_by => 'Sviluppato da calca';

  @override
  String get links => 'Collegamenti';

  @override
  String get daily_expenses_chart => 'Spese giornaliere';

  @override
  String get weekly_expenses_chart => 'Spese settimanali';

  @override
  String get daily_average_by_category => 'Media giornaliera per categoria';

  @override
  String get per_day => '/giorno';

  @override
  String get no_expenses_for_statistics =>
      'Nessuna spesa disponibile per le statistiche';

  @override
  String get settlement => 'Pareggia';

  @override
  String get all_balanced => 'Tutti i conti sono pari!';

  @override
  String get owes_to => ' deve dare a ';

  @override
  String get export_csv => 'Esporta CSV';

  @override
  String get no_expenses_to_export => 'Nessuna spesa da esportare';

  @override
  String get export_csv_share_text => 'Spese esportate da ';

  @override
  String get export_csv_error => 'Errore nell\'esportazione delle spese';

  @override
  String get expense_name => 'Descrizione';

  @override
  String get paid_by => 'Pagato da';

  @override
  String get expense_added_success => 'Spesa aggiunta';

  @override
  String get expense_updated_success => 'Spesa aggiornata';

  @override
  String get data_refreshing => 'Aggiornamento…';

  @override
  String get data_refreshed => 'Aggiornato';

  @override
  String get refresh => 'Aggiorna';

  @override
  String get group_added_success => 'Gruppo aggiunto';

  @override
  String get csv_select_directory_title => 'Seleziona cartella per salvare CSV';

  @override
  String csv_saved_in(Object path) {
    return 'CSV salvato in: $path';
  }

  @override
  String get csv_save_cancelled => 'Esportazione annullata';

  @override
  String get csv_save_error => 'Errore nel salvataggio del file CSV';

  @override
  String get csv_expense_name => 'Descrizione';

  @override
  String get csv_amount => 'Importo';

  @override
  String get csv_paid_by => 'Pagato da';

  @override
  String get csv_category => 'Categoria';

  @override
  String get csv_date => 'Data';

  @override
  String get csv_note => 'Nota';

  @override
  String get csv_location => 'Posizione';

  @override
  String get location => 'Posizione';

  @override
  String get location_hint => 'Posizione';

  @override
  String get get_current_location => 'Usa posizione corrente';

  @override
  String get enter_location_manually => 'Inserisci manualmente';

  @override
  String get location_permission_denied => 'Permesso posizione negato';

  @override
  String get location_service_disabled => 'Servizio posizione disabilitato';

  @override
  String get getting_location => 'Rilevamento posizione...';

  @override
  String get location_error => 'Errore nel rilevare la posizione';

  @override
  String get resolving_address => 'Risolvo indirizzo…';

  @override
  String get address_resolved => 'Indirizzo trovato';

  @override
  String get settings_general => 'Generali';

  @override
  String get settings_language => 'Lingua';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglese';

  @override
  String get settings_select_language => 'Seleziona lingua';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_select_theme => 'Seleziona tema';

  @override
  String get settings_data => 'Dati';

  @override
  String get settings_data_manage => 'Gestione dati';

  @override
  String get settings_data_desc => 'Backup e ripristino';

  @override
  String get settings_info => 'Informazioni';

  @override
  String get settings_app_version => 'Versione dell\'app';

  @override
  String get settings_info_card => 'Informazioni';

  @override
  String get settings_info_card_desc => 'Sviluppatore, Source code e Licenza';

  @override
  String get terms_github_title => 'GitHub: calca';

  @override
  String get terms_github_desc => 'Profilo dello sviluppatore su GitHub.';

  @override
  String get terms_repo_title => 'Repository GitHub';

  @override
  String get terms_repo_desc => 'Codice sorgente dell’applicazione.';

  @override
  String get terms_issue_title => 'Segnala un problema';

  @override
  String get terms_issue_desc => 'Vai alla pagina delle issue su GitHub.';

  @override
  String get terms_license_desc => 'Visualizza la licenza open source.';

  @override
  String get data_title => 'Backup & Ripristino';

  @override
  String get data_backup_title => 'Backup';

  @override
  String get data_backup_desc => 'Crea un file di backup delle tue spese.';

  @override
  String get data_restore_title => 'Ripristino';

  @override
  String get data_restore_desc => 'Importa un backup per ripristinare i dati.';

  @override
  String get info_tab => 'Info';

  @override
  String get select_paid_by => 'Seleziona chi ha pagato';

  @override
  String get select_category => 'Seleziona una categoria';

  @override
  String get check_form => 'Controlla i dati inseriti';

  @override
  String get delete_expense => 'Elimina spesa';

  @override
  String get delete_expense_confirm =>
      'Sei sicuro di voler eliminare questa spesa?';

  @override
  String get delete => 'Elimina';

  @override
  String get no_results_found => 'Nessun risultato trovato.';

  @override
  String get try_adjust_filter_or_search =>
      'Prova a modificare il filtro o la ricerca.';

  @override
  String get general_statistics => 'Statistiche generali';

  @override
  String get add_first_expense => 'Aggiungi la prima spesa per iniziare';

  @override
  String get overview_and_statistics => 'Panoramica e statistiche';

  @override
  String get daily_average => 'Media';

  @override
  String get spent_today => 'Oggi';

  @override
  String get average_expense => 'Spesa media';

  @override
  String get welcome_v3_cta => 'Inizia!';

  @override
  String get discard_changes_title => 'Scartare le modifiche?';

  @override
  String get discard_changes_message =>
      'Sei sicuro di voler scartare le modifiche non salvate?';

  @override
  String get discard => 'Scarta';

  @override
  String get category_placeholder => 'Categoria';

  @override
  String get image_requirements => 'PNG, JPG, GIF (max 10MB)';

  @override
  String error_saving_group(Object error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String get error_selecting_image =>
      'Errore durante la selezione dell\'immagine';

  @override
  String get error_saving_image =>
      'Errore durante il salvataggio dell\'immagine';

  @override
  String get already_exists => 'esiste già';

  @override
  String get status_all => 'Tutti';

  @override
  String get status_active => 'Attivi';

  @override
  String get status_archived => 'Archiviati';

  @override
  String get filter_status_tooltip => 'Filtra gruppi';

  @override
  String get welcome_logo_semantic => 'Logo dell\'app Caravella';

  @override
  String get create_new_group => 'Crea nuovo gruppo';

  @override
  String get accessibility_add_new_item => 'Aggiungi nuovo elemento';

  @override
  String get accessibility_navigation_bar => 'Barra di navigazione';

  @override
  String get accessibility_back_button => 'Indietro';

  @override
  String get accessibility_loading_groups => 'Caricamento gruppi';

  @override
  String get accessibility_loading_your_groups => 'Caricamento dei tuoi gruppi';

  @override
  String get accessibility_groups_list => 'Elenco gruppi';

  @override
  String get accessibility_welcome_screen => 'Schermata di benvenuto';

  @override
  String accessibility_total_expenses(String amount) {
    return 'Spese totali: ${amount}€';
  }

  @override
  String get accessibility_add_expense => 'Aggiungi spesa';

  @override
  String accessibility_security_switch(String state) {
    return 'Interruttore sicurezza - $state';
  }

  @override
  String get accessibility_switch_on => 'Attivo';

  @override
  String get accessibility_switch_off => 'Inattivo';

  @override
  String get accessibility_image_source_dialog => 'Finestra di selezione sorgente immagine';

  @override
  String get accessibility_currently_enabled => 'Attualmente attivo';

  @override
  String get accessibility_currently_disabled => 'Attualmente inattivo';

  @override
  String get accessibility_double_tap_disable => 'Tocca due volte per disattivare la sicurezza dello schermo';

  @override
  String get accessibility_double_tap_enable => 'Tocca due volte per attivare la sicurezza dello schermo';

  @override
  String get accessibility_toast_success => 'Successo';

  @override
  String get accessibility_toast_error => 'Errore';

  @override
  String get accessibility_toast_info => 'Informazione';
}
