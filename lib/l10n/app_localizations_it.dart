// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get developer_section_title => 'Sviluppatore & Supporto';

  @override
  String get developer_section_desc =>
      'Supporta lo sviluppatore o visualizza il profilo';

  @override
  String get repo_section_title => 'Codice & Segnalazioni';

  @override
  String get repo_section_desc =>
      'Visualizza il codice sorgente o segnala un problema';

  @override
  String get license_section_title => 'Licenza';

  @override
  String get license_section_desc => 'Visualizza la licenza open source';

  @override
  String get weeklyChartBadge => 'S';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get dateRangeChartBadge => 'G';

  @override
  String get weeklyExpensesChart => 'Spese settimanali';

  @override
  String get monthlyExpensesChart => 'Spese mensili';

  @override
  String get dateRangeExpensesChart => 'Spese per periodo';

  @override
  String get settings_flag_secure_desc =>
      'Impedisce screenshot e registrazione schermo';

  @override
  String get settings_flag_secure_title => 'Proteggi schermata';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get select_currency => 'Seleziona valuta';

  @override
  String get select_period_hint_short => 'Imposta date';

  @override
  String get select_period_hint => 'Seleziona le date';

  @override
  String get suggested_duration => 'Durata suggerita';

  @override
  String days_count(int count) {
    return '$count giorni';
  }

  @override
  String get weekday_mon => 'L';

  @override
  String get weekday_tue => 'M';

  @override
  String get weekday_wed => 'M';

  @override
  String get weekday_thu => 'G';

  @override
  String get weekday_fri => 'V';

  @override
  String get weekday_sat => 'S';

  @override
  String get weekday_sun => 'D';

  @override
  String get month_january => 'Gennaio';

  @override
  String get month_february => 'Febbraio';

  @override
  String get month_march => 'Marzo';

  @override
  String get month_april => 'Aprile';

  @override
  String get month_may => 'Maggio';

  @override
  String get month_june => 'Giugno';

  @override
  String get month_july => 'Luglio';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_september => 'Settembre';

  @override
  String get month_october => 'Ottobre';

  @override
  String get month_november => 'Novembre';

  @override
  String get month_december => 'Dicembre';

  @override
  String get in_group_prefix => 'in';

  @override
  String get save_change_expense => 'Salva modifiche';

  @override
  String get group_total => 'Totale';

  @override
  String get total_spent => 'Totale speso';

  @override
  String get download_all_csv => 'Scarica tutto (CSV)';

  @override
  String get share_all_csv => 'Condividi tutto (CSV)';

  @override
  String get download_all_ofx => 'Scarica tutto (OFX)';

  @override
  String get share_all_ofx => 'Condividi tutto (OFX)';

  @override
  String get download_all_markdown => 'Scarica tutto (Markdown)';

  @override
  String get share_all_markdown => 'Condividi tutto (Markdown)';

  @override
  String get markdown_select_directory_title =>
      'Seleziona cartella per salvare Markdown';

  @override
  String markdown_saved_in(String path) {
    return 'Markdown salvato in: $path';
  }

  @override
  String get markdown_save_cancelled => 'Esportazione Markdown annullata';

  @override
  String get markdown_save_error => 'Errore nel salvataggio del file Markdown';

  @override
  String get share_label => 'Condividi';

  @override
  String get share_text_label => 'Condividi testo';

  @override
  String get share_image_label => 'Condividi immagine';

  @override
  String get export_share => 'Esporta e Condividi';

  @override
  String get contribution_percentages => 'Percentuali';

  @override
  String get contribution_percentages_desc =>
      'Quota del totale pagata da ciascun partecipante';

  @override
  String get export_options => 'Opzioni di Esportazione';

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
  String get no_active_groups_subtitle => 'Crea un gruppo di spese';

  @override
  String get create_first_group => 'Crea un gruppo';

  @override
  String get new_expense_group => 'Nuovo Gruppo di Spese';

  @override
  String get new_expense => 'Nuova spesa';

  @override
  String get edit_expense => 'Modifica spesa';

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
  String get cannot_delete_assigned_participant =>
      'Impossibile eliminare il partecipante: è assegnato a una o più spese';

  @override
  String get cannot_delete_assigned_category =>
      'Impossibile eliminare la categoria: è assegnata a una o più spese';

  @override
  String get color => 'Colore';

  @override
  String get remove_color => 'Rimuovi Colore';

  @override
  String get color_alternative => 'Alternativa all\'immagine';

  @override
  String get background => 'Sfondo';

  @override
  String get select_background => 'Seleziona Sfondo';

  @override
  String get background_options => 'Opzioni Sfondo';

  @override
  String get choose_image_or_color => 'Scegli immagine o colore';

  @override
  String get participants_description => 'Persone che condividono spese';

  @override
  String get categories_description => 'Organizza spese per tipo';

  @override
  String get dates_description => 'Date inizio/fine opzionali';

  @override
  String get select_period => 'Seleziona periodo';

  @override
  String get select_period_dates => 'Seleziona le date del periodo';

  @override
  String duration_days(int days) {
    return '$days giorni';
  }

  @override
  String period_from_to(String start, String end, int days) {
    return 'Dal $start al $end ($days giorni)';
  }

  @override
  String period_from_select_end(String start) {
    return 'Dal $start - Seleziona fine';
  }

  @override
  String period_to_select_start(String end) {
    return 'Al $end - Seleziona inizio';
  }

  @override
  String get confirm => 'Conferma';

  @override
  String get clear => 'Cancella';

  @override
  String get currency_description => 'Valuta base del gruppo';

  @override
  String get background_color_selected => 'Colore selezionato';

  @override
  String get background_tap_to_replace => 'Tocca per sostituire';

  @override
  String get background_tap_to_change => 'Tocca per cambiare';

  @override
  String get background_select_image_or_color => 'Seleziona immagine o colore';

  @override
  String get background_random_color => 'Colore casuale';

  @override
  String get background_remove => 'Rimuovi sfondo';

  @override
  String get crop_image_title => 'Ritaglia immagine';

  @override
  String get crop_confirm => 'Conferma';

  @override
  String get saving => 'Salvataggio...';

  @override
  String get processing_image => 'Elaborazione immagine...';

  @override
  String get no_trips_found => 'Dove vuoi andare?';

  @override
  String get expenses => 'Spese';

  @override
  String get participants => 'Partecipanti';

  @override
  String participant_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipanti',
      one: '$count partecipante',
    );
    return '$_temp0';
  }

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
  String get group => 'Gruppo';

  @override
  String get create => 'Crea';

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
  String get expand_form => 'Espandi modulo';

  @override
  String get expand_form_tooltip => 'Aggiungi data, luogo e note';

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
  String get other_settings => 'Altre impostazioni';

  @override
  String get other_settings_desc => 'Valuta, sfondo e posizione automatica';

  @override
  String get segment_general => 'Generali';

  @override
  String get segment_other => 'Altro';

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
  String get pin => 'Preferito';

  @override
  String get unpin => 'Rimuovi preferito';

  @override
  String get delete => 'Elimina';

  @override
  String get undo => 'ANNULLA';

  @override
  String get archived_with_undo => 'Archiviato';

  @override
  String get unarchived_with_undo => 'Disarchiviato';

  @override
  String get pinned_with_undo => 'Segnato come preferito';

  @override
  String get unpinned_with_undo => 'Preferito rimosso';

  @override
  String get deleted_with_undo => 'Eliminato';

  @override
  String get archive_confirm => 'Vuoi archiviare';

  @override
  String get unarchive_confirm => 'Vuoi disarchiviare';

  @override
  String get overview => 'Panoramica';

  @override
  String get statistics => 'Statistiche';

  @override
  String get period => 'Periodo';

  @override
  String get total_expenses => 'Totale spese';

  @override
  String get number_of_expenses => 'Numero di spese';

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
  String get edit_group_desc =>
      'Modifica impostazioni, partecipanti e categorie del gruppo';

  @override
  String get new_group_desc =>
      'Crea un nuovo gruppo spese con impostazioni personalizzate';

  @override
  String get delete_group => 'Elimina gruppo';

  @override
  String get delete_group_confirm =>
      'Sei sicuro di voler eliminare questo gruppo di spese? Questa azione non può essere annullata.';

  @override
  String get add_expense_fab => 'Aggiungi Spesa';

  @override
  String get pin_group => 'Segna come preferito';

  @override
  String get unpin_group => 'Rimuovi preferito';

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
  String get group_deleted_success => 'Gruppo eliminato';

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
  String get ofx_select_directory_title => 'Seleziona cartella per salvare OFX';

  @override
  String ofx_saved_in(Object path) {
    return 'OFX salvato in: $path';
  }

  @override
  String get ofx_save_cancelled => 'Esportazione OFX annullata';

  @override
  String get ofx_save_error => 'Errore nel salvataggio del file OFX';

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
  String get csv_location => 'Luogo';

  @override
  String get location => 'Luogo';

  @override
  String get location_hint => 'Luogo';

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
  String get search_place => 'Cerca luogo';

  @override
  String get search_place_hint => 'Cerca un luogo o indirizzo';

  @override
  String get settings_general => 'Generali';

  @override
  String get settings_general_desc => 'Impostazioni lingua e aspetto';

  @override
  String get settings_auto_location_section => 'Rilevamento posizione';

  @override
  String get settings_auto_location_section_desc =>
      'Configura il rilevamento automatico della posizione';

  @override
  String get settings_auto_location_title => 'Attiva per rilevare';

  @override
  String get settings_auto_location_desc =>
      'Rileva GPS quando aggiungi una spesa';

  @override
  String get settings_language => 'Lingua';

  @override
  String get settings_language_desc => 'Scegli la lingua preferita';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglese';

  @override
  String get settings_language_es => 'Spagnolo';

  @override
  String get settings_language_pt => 'Portoghese';

  @override
  String get settings_language_zh => 'Cinese (Semplificato)';

  @override
  String get settings_select_language => 'Seleziona lingua';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_theme_desc => 'Chiaro, scuro o sistema';

  @override
  String get settings_select_theme => 'Seleziona tema';

  @override
  String get settings_dynamic_color => 'Colore dinamico';

  @override
  String get settings_dynamic_color_desc => 'Usa i colori dello sfondo';

  @override
  String get settings_privacy_desc => 'Opzioni sicurezza e privacy';

  @override
  String get settings_data => 'Dati';

  @override
  String get settings_data_desc => 'Gestisci le tue informazioni';

  @override
  String get settings_data_manage => 'Gestione dati';

  @override
  String get settings_info => 'Informazioni';

  @override
  String get settings_info_desc => 'Dettagli app e supporto';

  @override
  String get settings_app_version => 'Versione dell\'app';

  @override
  String get settings_info_card => 'Informazioni';

  @override
  String get settings_info_card_desc => 'Sviluppatore, Source code e Licenza';

  @override
  String get terms_github_title => 'Sito web: calca';

  @override
  String get terms_github_desc => 'Sito web personale dello sviluppatore.';

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
  String get support_developer_title => 'Offrimi un caffè';

  @override
  String get support_developer_desc => 'Sostieni lo sviluppo di questa app.';

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
  String get auto_backup_title => 'Backup automatico';

  @override
  String get auto_backup_desc =>
      'Abilita il backup automatico del sistema operativo';

  @override
  String get settings_user_name_title => 'Il tuo nome';

  @override
  String get settings_user_name_desc => 'Nome o nickname da usare nell\'app';

  @override
  String get settings_user_name_hint => 'Inserisci il tuo nome';

  @override
  String get default_participant_me => 'Io';

  @override
  String get info_tab => 'Info';

  @override
  String get select_paid_by => 'Seleziona chi ha pagato';

  @override
  String get select_category => 'Seleziona categoria';

  @override
  String get check_form => 'Controlla i dati inseriti';

  @override
  String get delete_expense => 'Elimina spesa';

  @override
  String get delete_expense_confirm =>
      'Sei sicuro di voler eliminare questa spesa?';

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
  String get monthly_average => 'Mensile';

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
  String get no_archived_groups => 'Nessun gruppo archiviato';

  @override
  String get no_archived_groups_subtitle =>
      'Non hai ancora archiviato nessun gruppo';

  @override
  String get all_groups_archived_info =>
      'Tutti i tuoi gruppi sono archiviati. Puoi recuperarli dalla sezione Archivio o crearne di nuovi.';

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
  String accessibility_total_expenses(Object amount) {
    return 'Spese totali: $amount€';
  }

  @override
  String get accessibility_add_expense => 'Aggiungi spesa';

  @override
  String accessibility_security_switch(Object state) {
    return 'Interruttore sicurezza - $state';
  }

  @override
  String get accessibility_switch_on => 'Attivo';

  @override
  String get accessibility_switch_off => 'Inattivo';

  @override
  String get accessibility_image_source_dialog =>
      'Finestra di selezione sorgente immagine';

  @override
  String get accessibility_currently_enabled => 'Attualmente attivo';

  @override
  String get accessibility_currently_disabled => 'Attualmente inattivo';

  @override
  String get accessibility_double_tap_disable =>
      'Tocca due volte per disattivare la sicurezza dello schermo';

  @override
  String get accessibility_double_tap_enable =>
      'Tocca due volte per attivare la sicurezza dello schermo';

  @override
  String get accessibility_toast_success => 'Successo';

  @override
  String get accessibility_toast_error => 'Errore';

  @override
  String get accessibility_toast_info => 'Informazione';

  @override
  String get color_suggested_title => 'Colori suggeriti';

  @override
  String get color_suggested_subtitle =>
      'Scegli uno dei colori compatibili col tema';

  @override
  String get color_random_subtitle =>
      'Lascia che l\'app scelga un colore per te';

  @override
  String get currency_AED => 'Dirham Emirati Arabi Uniti';

  @override
  String get currency_AFN => 'Afghani afghano';

  @override
  String get currency_ALL => 'Lek albanese';

  @override
  String get currency_AMD => 'Dram armeno';

  @override
  String get currency_ANG => 'Fiorino Antille Olandesi';

  @override
  String get currency_AOA => 'Kwanza angolano';

  @override
  String get currency_ARS => 'Peso argentino';

  @override
  String get currency_AUD => 'Dollaro australiano';

  @override
  String get currency_AWG => 'Fiorino arubano';

  @override
  String get currency_AZN => 'Manat azero';

  @override
  String get currency_BAM => 'Marco convertibile bosniaco';

  @override
  String get currency_BBD => 'Dollaro barbadiano';

  @override
  String get currency_BDT => 'Taka bengalese';

  @override
  String get currency_BGN => 'Lev bulgaro';

  @override
  String get currency_BHD => 'Dinaro bahreinita';

  @override
  String get currency_BIF => 'Franco burundese';

  @override
  String get currency_BMD => 'Dollaro bermudiano';

  @override
  String get currency_BND => 'Dollaro del Brunei';

  @override
  String get currency_BOB => 'Boliviano';

  @override
  String get currency_BRL => 'Real brasiliano';

  @override
  String get currency_BSD => 'Dollaro bahamense';

  @override
  String get currency_BTN => 'Ngultrum bhutanese';

  @override
  String get currency_BWP => 'Pula del Botswana';

  @override
  String get currency_BYN => 'Rublo bielorusso';

  @override
  String get currency_BZD => 'Dollaro beliziano';

  @override
  String get currency_CAD => 'Dollaro canadese';

  @override
  String get currency_CDF => 'Franco congolese';

  @override
  String get currency_CHF => 'Franco svizzero';

  @override
  String get currency_CLP => 'Peso cileno';

  @override
  String get currency_CNY => 'Yuan Renminbi cinese';

  @override
  String get currency_COP => 'Peso colombiano';

  @override
  String get currency_CRC => 'Colón costaricano';

  @override
  String get currency_CUP => 'Peso cubano';

  @override
  String get currency_CVE => 'Escudo capoverdiano';

  @override
  String get currency_CZK => 'Corona ceca';

  @override
  String get currency_DJF => 'Franco gibutiano';

  @override
  String get currency_DKK => 'Corona danese';

  @override
  String get currency_DOP => 'Peso dominicano';

  @override
  String get currency_DZD => 'Dinaro algerino';

  @override
  String get currency_EGP => 'Sterlina egiziana';

  @override
  String get currency_ERN => 'Nakfa eritrea';

  @override
  String get currency_ETB => 'Birr etiope';

  @override
  String get currency_EUR => 'Euro';

  @override
  String get currency_FJD => 'Dollaro figiano';

  @override
  String get currency_FKP => 'Sterlina delle Falkland';

  @override
  String get currency_GBP => 'Sterlina britannica';

  @override
  String get currency_GEL => 'Lari georgiano';

  @override
  String get currency_GHS => 'Cedi ghanese';

  @override
  String get currency_GIP => 'Sterlina di Gibilterra';

  @override
  String get currency_GMD => 'Dalasi gambiano';

  @override
  String get currency_GNF => 'Franco della Guinea';

  @override
  String get currency_GTQ => 'Quetzal guatemalteco';

  @override
  String get currency_GYD => 'Dollaro della Guyana';

  @override
  String get currency_HKD => 'Dollaro di Hong Kong';

  @override
  String get currency_HNL => 'Lempira honduregna';

  @override
  String get currency_HTG => 'Gourde haitiano';

  @override
  String get currency_HUF => 'Fiorino ungherese';

  @override
  String get currency_IDR => 'Rupia indonesiana';

  @override
  String get currency_ILS => 'Nuovo shekel israeliano';

  @override
  String get currency_INR => 'Rupia indiana';

  @override
  String get currency_IQD => 'Dinaro iracheno';

  @override
  String get currency_IRR => 'Rial iraniano';

  @override
  String get currency_ISK => 'Corona islandese';

  @override
  String get currency_JMD => 'Dollaro giamaicano';

  @override
  String get currency_JOD => 'Dinaro giordano';

  @override
  String get currency_JPY => 'Yen giapponese';

  @override
  String get currency_KES => 'Scellino keniota';

  @override
  String get currency_KGS => 'Som kirghiso';

  @override
  String get currency_KHR => 'Riel cambogiano';

  @override
  String get currency_KID => 'Dollaro di Kiribati';

  @override
  String get currency_KMF => 'Franco comoriano';

  @override
  String get currency_KPW => 'Won nordcoreano';

  @override
  String get currency_KRW => 'Won sudcoreano';

  @override
  String get currency_KWD => 'Dinaro kuwaitiano';

  @override
  String get currency_KYD => 'Dollaro delle Cayman';

  @override
  String get currency_KZT => 'Tenge kazako';

  @override
  String get currency_LAK => 'Kip laotiano';

  @override
  String get currency_LBP => 'Lira libanese';

  @override
  String get currency_LKR => 'Rupia singalese';

  @override
  String get currency_LRD => 'Dollaro liberiano';

  @override
  String get currency_LSL => 'Loti del Lesotho';

  @override
  String get currency_LYD => 'Dinaro libico';

  @override
  String get currency_MAD => 'Dirham marocchino';

  @override
  String get currency_MDL => 'Leu moldavo';

  @override
  String get currency_MGA => 'Ariary malgascio';

  @override
  String get currency_MKD => 'Denar macedone';

  @override
  String get currency_MMK => 'Kyat del Myanmar';

  @override
  String get currency_MNT => 'Tugrik mongolo';

  @override
  String get currency_MOP => 'Pataca di Macao';

  @override
  String get currency_MRU => 'Ouguiya mauritana';

  @override
  String get currency_MUR => 'Rupia mauriziana';

  @override
  String get currency_MVR => 'Rufiyaa maldiviana';

  @override
  String get currency_MWK => 'Kwacha malawiano';

  @override
  String get currency_MXN => 'Peso messicano';

  @override
  String get currency_MYR => 'Ringgit malese';

  @override
  String get currency_MZN => 'Metical mozambicano';

  @override
  String get currency_NAD => 'Dollaro namibiano';

  @override
  String get currency_NGN => 'Naira nigeriana';

  @override
  String get currency_NIO => 'Córdoba oro nicaraguense';

  @override
  String get currency_NOK => 'Corona norvegese';

  @override
  String get currency_NPR => 'Rupia nepalese';

  @override
  String get currency_NZD => 'Dollaro neozelandese';

  @override
  String get currency_OMR => 'Rial omanita';

  @override
  String get currency_PAB => 'Balboa panamense';

  @override
  String get currency_PEN => 'Sol peruviano';

  @override
  String get currency_PGK => 'Kina papuana';

  @override
  String get currency_PHP => 'Peso filippino';

  @override
  String get currency_PKR => 'Rupia pakistana';

  @override
  String get currency_PLN => 'Złoty polacco';

  @override
  String get currency_PYG => 'Guaraní paraguaiano';

  @override
  String get currency_QAR => 'Rial qatariano';

  @override
  String get currency_RON => 'Leu rumeno';

  @override
  String get currency_RSD => 'Dinaro serbo';

  @override
  String get currency_RUB => 'Rublo russo';

  @override
  String get currency_RWF => 'Franco ruandese';

  @override
  String get currency_SAR => 'Riyal saudita';

  @override
  String get currency_SBD => 'Dollaro delle Isole Salomone';

  @override
  String get currency_SCR => 'Rupia delle Seychelles';

  @override
  String get currency_SDG => 'Sterlina sudanese';

  @override
  String get currency_SEK => 'Corona svedese';

  @override
  String get currency_SGD => 'Dollaro di Singapore';

  @override
  String get currency_SHP => 'Sterlina di Sant’Elena';

  @override
  String get currency_SLE => 'Leone sierraleonese (nuovo)';

  @override
  String get currency_SLL => 'Leone sierraleonese (vecchio)';

  @override
  String get currency_SOS => 'Scellino somalo';

  @override
  String get currency_SRD => 'Dollaro surinamese';

  @override
  String get currency_SSP => 'Sterlina sud-sudanese';

  @override
  String get currency_STN => 'Dobra di São Tomé e Príncipe';

  @override
  String get currency_SVC => 'Colón salvadoregno (storico)';

  @override
  String get currency_SYP => 'Lira siriana';

  @override
  String get currency_SZL => 'Lilangeni eSwatini';

  @override
  String get currency_THB => 'Baht thailandese';

  @override
  String get currency_TJS => 'Somoni tagiko';

  @override
  String get currency_TMT => 'Manat turkmeno';

  @override
  String get currency_TND => 'Dinaro tunisino';

  @override
  String get currency_TOP => 'Paʻanga tongano';

  @override
  String get currency_TRY => 'Lira turca';

  @override
  String get currency_TTD => 'Dollaro Trinidad e Tobago';

  @override
  String get currency_TVD => 'Dollaro di Tuvalu';

  @override
  String get currency_TWD => 'Nuovo dollaro di Taiwan';

  @override
  String get currency_TZS => 'Scellino tanzaniano';

  @override
  String get currency_UAH => 'Grivnia ucraina';

  @override
  String get currency_UGX => 'Scellino ugandese';

  @override
  String get currency_USD => 'Dollaro USA';

  @override
  String get currency_UYU => 'Peso uruguaiano';

  @override
  String get currency_UZS => 'Som uzbeko';

  @override
  String get currency_VED => 'Bolívar venezuelano digitale';

  @override
  String get currency_VES => 'Bolívar venezuelano';

  @override
  String get currency_VND => 'Dong vietnamita';

  @override
  String get currency_VUV => 'Vatu vanuatiano';

  @override
  String get currency_WST => 'Tala samoano';

  @override
  String get currency_XAF => 'Franco CFA BEAC';

  @override
  String get currency_XOF => 'Franco CFA BCEAO';

  @override
  String get currency_XPF => 'Franco CFP';

  @override
  String get currency_YER => 'Rial yemenita';

  @override
  String get currency_ZAR => 'Rand sudafricano';

  @override
  String get currency_ZMW => 'Kwacha dello Zambia';

  @override
  String get currency_ZWL => 'Dollaro zimbabwiano';

  @override
  String get search_currency => 'Cerca valuta...';

  @override
  String get activity => 'Spese';

  @override
  String get search_expenses_hint => 'Cerca per nome o nota...';

  @override
  String get clear_filters => 'Pulisci';

  @override
  String get show_filters => 'Mostra filtri';

  @override
  String get hide_filters => 'Nascondi filtri';

  @override
  String get all_categories => 'Tutte';

  @override
  String get all_participants => 'Tutti';

  @override
  String get no_expenses_with_filters =>
      'Nessuna spesa trovata con i filtri selezionati';

  @override
  String get no_expenses_yet => 'Nessuna spesa ancora aggiunta';

  @override
  String get empty_expenses_title => 'Pronti per iniziare?';

  @override
  String get empty_expenses_subtitle =>
      'Aggiungi la prima spesa per iniziare con questo gruppo!';

  @override
  String get add_first_expense_button => 'Aggiungi Prima Spesa';

  @override
  String get show_search => 'Mostra barra di ricerca';

  @override
  String get hide_search => 'Nascondi barra di ricerca';

  @override
  String get expense_groups_title => 'Gruppi di spese';

  @override
  String get expense_groups_desc => 'Gestisci i tuoi gruppi di spese';

  @override
  String get whats_new_title => 'Novità';

  @override
  String get whats_new_desc => 'Scopri le ultime novità e aggiornamenti';

  @override
  String get whats_new_subtitle => 'Ultimi Aggiornamenti';

  @override
  String get whats_new_latest =>
      'Resta aggiornato con i miglioramenti più recenti';

  @override
  String get changelog_title => 'Cronologia versioni';

  @override
  String get changelog_desc => 'Storico delle versioni e miglioramenti';

  @override
  String get average_per_person => 'Speso medio per persona';

  @override
  String get more => 'altro';

  @override
  String get less => 'meno';

  @override
  String get debt_prefix_to => 'a ';

  @override
  String get view_on_map => 'View on map';

  @override
  String get expenses_map => 'Mappa delle spese';

  @override
  String get no_locations_available => 'No locations available';

  @override
  String get no_locations_subtitle =>
      'Add location data to your expenses to see them on the map';

  @override
  String expense_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expenses',
      one: '1 expense',
    );
    return '$_temp0';
  }

  @override
  String get check_for_updates => 'Controlla aggiornamenti';

  @override
  String get check_for_updates_desc => 'Verifica disponibilità nuova versione';

  @override
  String get update_available => 'Aggiornamento disponibile';

  @override
  String get update_available_desc =>
      'È disponibile una nuova versione dell\'app';

  @override
  String get no_update_available => 'App aggiornata';

  @override
  String get no_update_available_desc => 'Stai usando l\'ultima versione';

  @override
  String get update_now => 'Aggiorna ora';

  @override
  String get update_later => 'Più tardi';

  @override
  String get checking_for_updates => 'Verifica aggiornamenti...';

  @override
  String get update_error => 'Errore verifica aggiornamenti';

  @override
  String get update_downloading => 'Download in corso...';

  @override
  String get update_installing => 'Installazione in corso...';

  @override
  String get update_feature_android_only =>
      'Funzione disponibile solo su Android con Google Play Store';

  @override
  String get update_recommendation_title => 'Aggiornamento consigliato';

  @override
  String get update_recommendation_desc =>
      'È disponibile una nuova versione di Caravella. Aggiorna l\'app per avere sempre le ultime funzionalità e miglioramenti!';

  @override
  String get update_install => 'Installa aggiornamento';

  @override
  String get update_remind_later => 'Ricordamelo dopo';

  @override
  String get send_reminder => 'Invia promemoria';

  @override
  String reminder_message_single(
    Object participantName,
    Object amount,
    Object creditorName,
    Object groupName,
  ) {
    return 'Ciao $participantName! 👋\n\nVorrei ricordarti che devi $amount a $creditorName per il gruppo \"$groupName\".\n\nGrazie! 😊';
  }

  @override
  String reminder_message_multiple(
    Object participantName,
    Object groupName,
    Object debtsList,
  ) {
    return 'Ciao $participantName! 👋\n\nVorrei ricordarti i tuoi pagamenti per il gruppo \"$groupName\":\n\n$debtsList\n\nGrazie! 😊';
  }

  @override
  String get notification_enabled => 'Notifica persistente';

  @override
  String get notification_enabled_desc =>
      'Visualizza le spese del giorno in una notifica sempre visibile';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Spese del giorno: $amount $currency';
  }

  @override
  String notification_total_spent(String amount, String currency) {
    return 'Totale: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Aggiungi Spesa';

  @override
  String get notification_close => 'Chiudi';

  @override
  String get group_type => 'Tipologia';

  @override
  String get group_type_description => 'Scegli il tipo di gruppo';

  @override
  String get group_type_travel => 'Viaggio';

  @override
  String get group_type_personal => 'Personale';

  @override
  String get group_type_family => 'Famiglia';

  @override
  String get group_type_other => 'Altro';

  @override
  String get category_travel_transport => 'Trasporti';

  @override
  String get category_travel_accommodation => 'Alloggio';

  @override
  String get category_travel_restaurants => 'Ristoranti';

  @override
  String get category_personal_shopping => 'Shopping';

  @override
  String get category_personal_health => 'Salute';

  @override
  String get category_personal_entertainment => 'Intrattenimento';

  @override
  String get category_family_groceries => 'Spesa';

  @override
  String get category_family_home => 'Casa';

  @override
  String get category_family_bills => 'Bolletta';

  @override
  String get category_other_misc => 'Varie';

  @override
  String get category_other_utilities => 'Utilità';

  @override
  String get category_other_services => 'Servizi';

  @override
  String get attachments => 'Allegati';

  @override
  String get add_attachment => 'Aggiungi allegato';

  @override
  String get attachment_limit_reached =>
      'Limite massimo di 5 allegati raggiunto';

  @override
  String get delete_attachment => 'Elimina allegato';

  @override
  String get share_attachment => 'Condividi allegato';

  @override
  String get delete_attachment_confirm_title => 'Elimina allegato';

  @override
  String get delete_attachment_confirm_message =>
      'Sei sicuro di voler eliminare questo allegato?';

  @override
  String get attachment_source => 'Scegli sorgente';

  @override
  String get from_files => 'Dai file';

  @override
  String get archived_group_readonly => 'Gruppo archiviato - Sola lettura';

  @override
  String get archived_group_readonly_desc =>
      'Questo gruppo è archiviato. Non è possibile modificarlo o aggiungere nuove spese.';

  @override
  String get expense_readonly => 'Spesa - Sola lettura';

  @override
  String get expense_readonly_archived =>
      'Questa spesa appartiene a un gruppo archiviato e non può essere modificata.';

  @override
  String get expense => 'Spesa';

  @override
  String get notification_disable => 'Disabilita';

  @override
  String get wizard_group_creation_title => 'Nuovo Gruppo';

  @override
  String get wizard_step_name => 'Nome';

  @override
  String get wizard_step_type_and_name => 'Tipologia e Nome';

  @override
  String get wizard_type_and_name_description => 'Crea il tuo gruppo';

  @override
  String get wizard_step_participants => 'Partecipanti';

  @override
  String get wizard_step_categories => 'Categorie';

  @override
  String get wizard_step_period => 'Periodo';

  @override
  String get wizard_step_background => 'Sfondo';

  @override
  String get wizard_step_congratulations => 'Congratulazioni!';

  @override
  String get wizard_step_of => 'di';

  @override
  String get wizard_next => 'Avanti';

  @override
  String get wizard_previous => 'Indietro';

  @override
  String get wizard_skip => 'Salta';

  @override
  String get wizard_finish => 'Crea Gruppo';

  @override
  String get wizard_name_description => 'Nome del gruppo';

  @override
  String get wizard_participants_description =>
      'Aggiungi le persone che parteciperanno alle spese';

  @override
  String get wizard_categories_description =>
      'Crea categorie per organizzare le spese';

  @override
  String get wizard_period_description =>
      'Imposta date di inizio e fine (opzionale)';

  @override
  String get wizard_background_description =>
      'Scegli un colore di sfondo per il gruppo';

  @override
  String wizard_congratulations_message(String groupName) {
    return 'Il tuo gruppo \'$groupName\' è stato creato con successo!';
  }

  @override
  String get wizard_group_summary => 'Riepilogo gruppo:';

  @override
  String wizard_created_participants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipanti',
      one: '1 partecipante',
    );
    return '$_temp0';
  }

  @override
  String wizard_created_categories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorie',
      one: '1 categoria',
    );
    return '$_temp0';
  }

  @override
  String get wizard_step_user_name => 'Il tuo nome';

  @override
  String get wizard_user_name_welcome => 'Ciao! 👋';

  @override
  String get wizard_user_name_description => 'Come vuoi essere chiamato?';

  @override
  String get wizard_user_name_local_storage_note =>
      'Salvato solo sul tuo dispositivo';

  @override
  String get wizard_user_name_label => 'Il tuo nome (facoltativo)';

  @override
  String get wizard_user_name_hint => 'Mario';

  @override
  String get wizard_step_participants_and_categories => 'Chi e cosa';

  @override
  String get wizard_participants_and_categories_description =>
      'Definisci chi partecipa e su cosa si divideranno le spese';

  @override
  String get wizard_participants_section_title => 'Chi partecipa?';

  @override
  String get wizard_participants_section_hint =>
      'Aggiungi amici o coinquilini. Puoi modificarli dopo.';

  @override
  String get wizard_categories_section_title => 'Cosa si divide?';

  @override
  String get wizard_categories_section_hint =>
      'Es. Cibo, Alloggio, Trasporti. Puoi aggiungere o rinominare in seguito.';

  @override
  String get wizard_step_color_and_final => 'Colore e conferma';

  @override
  String get wizard_color_and_final_description =>
      'Scegli un colore per il gruppo e controlla il riepilogo';

  @override
  String get wizard_preview_title => 'Anteprima gruppo';

  @override
  String get wizard_success_title => '🎉 Congratulazioni!';

  @override
  String get wizard_go_to_group => 'Vai al gruppo';
}
