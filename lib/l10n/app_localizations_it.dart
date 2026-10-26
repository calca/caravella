// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get developer_section_title => 'Sviluppatore e supporto';

  @override
  String get repo_section_title => 'Codice e segnalazioni';

  @override
  String get license_section_title => 'Licenza';

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
  String get settings_flag_secure_desc => 'Blocca screenshot e registrazione';

  @override
  String get settings_flag_secure_title => 'Proteggi schermata';

  @override
  String get settings_app_functions_title => 'Accesso agenti AI';

  @override
  String get settings_app_functions_desc => 'Usa Gemini e altri assistenti AI';

  @override
  String get select_currency => 'Valuta';

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
  String get group_total => 'Totale';

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
  String get export_share => 'Condividi ed esporta';

  @override
  String get export_options => 'Esporta le spese';

  @override
  String get welcome_v3_title => 'Organizza.\nCondividi.\nBilancia.\n ';

  @override
  String get good_morning => 'Buongiorno';

  @override
  String get good_afternoon => 'Buon pomeriggio';

  @override
  String get good_evening => 'Buonasera';

  @override
  String get see_all => 'Vedi tutti';

  @override
  String get view_all_groups => 'Vedi tutti i gruppi';

  @override
  String get no_active_groups => 'Nessun gruppo attivo';

  @override
  String get create_first_group => 'Crea un gruppo';

  @override
  String get new_expense_group => 'Nuovo';

  @override
  String get new_expense => 'Nuova spesa';

  @override
  String get image => 'Foto';

  @override
  String get change_image => 'Cambia foto';

  @override
  String get from_gallery => 'Dalla galleria';

  @override
  String get from_camera => 'Dalla fotocamera';

  @override
  String get cannot_delete_assigned_participant =>
      'Impossibile eliminare il partecipante: è assegnato a una o più spese';

  @override
  String get cannot_delete_assigned_category =>
      'Impossibile eliminare la categoria: è assegnata a una o più spese';

  @override
  String get color => 'Colore';

  @override
  String get background => 'Sfondo';

  @override
  String get participants_description => 'Persone che condividono spese';

  @override
  String get categories_description => 'Organizza spese per tipo';

  @override
  String get dates_description => 'Inizio e fine, facoltative';

  @override
  String get select_period => 'Periodo';

  @override
  String get suggested_duration => 'Durata suggerita';

  @override
  String get confirm => 'Conferma';

  @override
  String get clear => 'Rimuovi';

  @override
  String get background_color_selected => 'Colore selezionato';

  @override
  String get background_tap_to_replace => 'Tocca per sostituire';

  @override
  String get background_tap_to_change => 'Tocca per cambiare';

  @override
  String get background_select_image_or_color => 'Scegli una foto o un colore';

  @override
  String get background_random_color => 'Colore casuale';

  @override
  String get background_remove => 'Rimuovi sfondo';

  @override
  String get crop_image_title => 'Ritaglia la foto';

  @override
  String get crop_confirm => 'Conferma';

  @override
  String get saving => 'Salvataggio…';

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
  String get last_7_days => 'Ultimi 7 giorni';

  @override
  String get today => 'Oggi';

  @override
  String get this_month => 'Questo mese';

  @override
  String get recent_expenses => 'Spese recenti';

  @override
  String get license_link => 'Visualizza licenza MIT';

  @override
  String get add_trip => 'Aggiungi un gruppo';

  @override
  String get group => 'Gruppo';

  @override
  String get create => 'Crea';

  @override
  String get group_name => 'Nome';

  @override
  String get enter_title => 'Inserisci un nome';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get ok => 'OK';

  @override
  String get add_expense => 'Nuova spesa';

  @override
  String get edit_expense => 'Modifica spesa';

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
  String get end_date_after_start =>
      'La data di fine deve essere successiva a quella di inizio';

  @override
  String get expenses_by_participant => 'Per partecipante';

  @override
  String get expenses_by_category => 'Per categoria';

  @override
  String get uncategorized => 'Senza categoria';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'Nessun gruppo da salvare';

  @override
  String get backup_error => 'Backup non riuscito';

  @override
  String get backup_share_message => 'Ecco il backup di Caravella';

  @override
  String get import_confirm_title => 'Importa dati';

  @override
  String import_confirm_message(Object file) {
    return 'Ripristinare dal file «$file»? I gruppi attuali verranno sostituiti e non si potrà annullare.';
  }

  @override
  String get import_success => 'Dati ripristinati';

  @override
  String get import_error => 'Ripristino non riuscito: controlla il file';

  @override
  String get settings_flag_secure_error =>
      'Impossibile modificare la protezione schermo';

  @override
  String get settings_debug_logs_title => 'Log di debug';

  @override
  String get settings_debug_logs_desc => 'Log dell\'app ed errori';

  @override
  String get developer_link_error => 'Impossibile aprire il link';

  @override
  String get whats_new_load_error => 'Impossibile caricare le novità';

  @override
  String get categories => 'Categorie';

  @override
  String get other_settings_desc => 'Notifica, posizione';

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
  String get edit_participant => 'Modifica partecipante';

  @override
  String get add_participant => 'Aggiungi partecipante';

  @override
  String get edit_category => 'Modifica categoria';

  @override
  String get currency => 'Valuta';

  @override
  String get settings_tab => 'Impostazioni';

  @override
  String get settings => 'Impostazioni';

  @override
  String get history => 'Cronologia';

  @override
  String get all => 'Tutti';

  @override
  String get search_groups => 'Cerca gruppi e spese…';

  @override
  String get no_search_results => 'Nessun risultato';

  @override
  String get try_different_search => 'Prova a cercare con parole diverse';

  @override
  String get active => 'Attivo';

  @override
  String get archived => 'Archiviato';

  @override
  String get archive => 'Archivia';

  @override
  String get unarchive => 'Togli dall\'archivio';

  @override
  String get pin => 'Preferito';

  @override
  String get unpin => 'Rimuovi preferito';

  @override
  String get archived_with_undo => 'Archiviato';

  @override
  String get unarchived_with_undo => 'Tolto dall\'archivio';

  @override
  String get pinned_with_undo => 'Segnato come preferito';

  @override
  String get unpinned_with_undo => 'Preferito rimosso';

  @override
  String get deleted_with_undo => 'Eliminato';

  @override
  String get statistics => 'Statistiche';

  @override
  String get period => 'Periodo';

  @override
  String get total_expenses => 'Totale spese';

  @override
  String get number_of_expenses => 'Numero di spese';

  @override
  String get select_expense_date => 'Seleziona data spesa';

  @override
  String get select_expense_date_short => 'Seleziona data';

  @override
  String get date => 'Data';

  @override
  String get delete_group => 'Elimina gruppo';

  @override
  String get delete_group_confirm =>
      'Il gruppo e tutte le sue spese verranno eliminati. Non si potrà annullare.';

  @override
  String get add_expense_fab => 'Aggiungi spesa';

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
  String get per_day => '/giorno';

  @override
  String get no_expenses_for_statistics =>
      'Nessuna spesa disponibile per le statistiche';

  @override
  String get settlement => 'Salda';

  @override
  String get all_balanced => 'Siete pari';

  @override
  String get no_expenses_to_export => 'Nessuna spesa da esportare';

  @override
  String get expense_name => 'Descrizione';

  @override
  String get paid_by => 'Pagato da';

  @override
  String get added_by => 'Aggiunto da';

  @override
  String get edited_by => 'Modificato da';

  @override
  String get expense_added_success => 'Spesa aggiunta';

  @override
  String get expense_updated_success => 'Spesa aggiornata';

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
  String get getting_location => 'Rilevamento posizione…';

  @override
  String get location_error => 'Impossibile rilevare la posizione';

  @override
  String get address_resolved => 'Indirizzo trovato';

  @override
  String get settings_general => 'Generali';

  @override
  String get settings_auto_location_title => 'Posizione automatica';

  @override
  String get settings_auto_location_desc => 'Salva il luogo delle nuove spese';

  @override
  String get settings_language => 'Lingua';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglese';

  @override
  String get settings_language_es => 'Spagnolo';

  @override
  String get settings_language_pt => 'Portoghese';

  @override
  String get settings_language_zh => 'Cinese (semplificato)';

  @override
  String get settings_select_language => 'Lingua';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_appearance => 'Aspetto';

  @override
  String get settings_appearance_desc => 'Lingua, tema e colore dinamico';

  @override
  String get settings_dynamic_color => 'Colore dinamico';

  @override
  String get settings_dynamic_color_desc => 'Usa i colori dello sfondo';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_data => 'Dati';

  @override
  String get settings_data_manage => 'Gestione dati';

  @override
  String get settings_info => 'Informazioni';

  @override
  String get settings_app_version => 'Versione dell\'app';

  @override
  String get settings_info_card => 'Informazioni';

  @override
  String get settings_info_card_desc =>
      'Sviluppatore, codice sorgente e licenza';

  @override
  String get settings_invite_friends => 'Invita i tuoi amici';

  @override
  String get settings_invite_friends_desc => 'Condividi Caravella con chi vuoi';

  @override
  String get invite_friends_message =>
      'Ciao! Uso Caravella per dividere le spese di gruppo con gli amici, è comodissima 🎒💸 Provala anche tu: https://play.google.com/store/apps/details?id=io.caravella.egm';

  @override
  String get terms_github_title => 'Sito web: calca';

  @override
  String get terms_github_desc => 'Sito dello sviluppatore';

  @override
  String get terms_repo_title => 'Repository GitHub';

  @override
  String get terms_repo_desc => 'Codice sorgente dell\'app';

  @override
  String get terms_issue_title => 'Segnala un problema';

  @override
  String get terms_issue_desc => 'Segnala un problema su GitHub';

  @override
  String get terms_license_desc => 'Licenza open source MIT';

  @override
  String get support_developer_title => 'Offrimi un caffè';

  @override
  String get support_developer_desc => 'Sostieni lo sviluppo dell\'app';

  @override
  String get data_title => 'Backup e ripristino';

  @override
  String get data_backup_desc => 'Salva le spese in un file';

  @override
  String get data_restore_title => 'Ripristino';

  @override
  String get data_restore_desc => 'Da un file di backup';

  @override
  String get auto_backup_title => 'Backup automatico';

  @override
  String get auto_backup_desc => 'Backup del sistema operativo';

  @override
  String get settings_user_name_title => 'Il tuo nome';

  @override
  String get settings_user_name_desc => 'Il tuo nome nell\'app';

  @override
  String get settings_user_name_hint => 'Inserisci il tuo nome';

  @override
  String get default_participant_me => 'Io';

  @override
  String get select_category => 'Categoria';

  @override
  String get delete_expense => 'Elimina spesa';

  @override
  String get delete_expense_confirm =>
      'La spesa verrà eliminata. Non si potrà annullare.';

  @override
  String get delete => 'Elimina';

  @override
  String get spent_today => 'Oggi';

  @override
  String get welcome_v3_cta => 'Inizia';

  @override
  String get discard_changes_title => 'Uscire senza salvare?';

  @override
  String get discard_changes_message =>
      'Le modifiche che non hai salvato andranno perse.';

  @override
  String get discard => 'Scarta';

  @override
  String error_saving_group(Object error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String get already_exists => 'esiste già';

  @override
  String get status_active => 'Attivi';

  @override
  String get status_archived => 'Archiviati';

  @override
  String get no_archived_groups => 'Nessun gruppo archiviato';

  @override
  String get no_archived_groups_subtitle =>
      'Tieni premuto un gruppo e scegli Archivia: lo ritrovi qui.';

  @override
  String get all_groups_archived_info =>
      'Tutti i tuoi gruppi sono in archivio. Puoi riprenderli da lì o crearne uno nuovo.';

  @override
  String get welcome_logo_semantic => 'Logo dell\'app Caravella';

  @override
  String get create_new_group => 'Crea nuovo gruppo';

  @override
  String get accessibility_back_button => 'Indietro';

  @override
  String get accessibility_groups_list => 'Elenco gruppi';

  @override
  String get accessibility_welcome_screen => 'Schermata di benvenuto';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Spese totali: $amount';
  }

  @override
  String get accessibility_add_expense => 'Aggiungi spesa';

  @override
  String get accessibility_currently_disabled => 'Attualmente inattivo';

  @override
  String get accessibility_previous_month => 'Mese precedente';

  @override
  String get accessibility_next_month => 'Mese successivo';

  @override
  String get color_suggested_title => 'Colori suggeriti';

  @override
  String get color_suggested_subtitle =>
      'Tinte morbide, si adattano al tema chiaro e scuro';

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
  String get search_currency => 'Cerca valuta…';

  @override
  String get clear_filters => 'Azzera';

  @override
  String get filters => 'Filtri';

  @override
  String get empty_expenses_title => 'Ancora nessuna spesa';

  @override
  String get empty_expenses_subtitle => 'Aggiungi la prima: la ritrovi qui.';

  @override
  String get add_first_expense_button => 'Aggiungi spesa';

  @override
  String get show_search => 'Mostra barra di ricerca';

  @override
  String get whats_new_title => 'Novità';

  @override
  String get changelog_title => 'Cronologia versioni';

  @override
  String get expenses_map => 'Mappa delle spese';

  @override
  String get no_locations_available => 'Nessun luogo';

  @override
  String get no_locations_subtitle =>
      'Aggiungi un luogo alle spese per vederle sulla mappa';

  @override
  String expense_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spese',
      one: '1 spesa',
    );
    return '$_temp0';
  }

  @override
  String get check_for_updates => 'Controlla aggiornamenti';

  @override
  String get check_for_updates_desc => 'Cerca una nuova versione';

  @override
  String get update_available => 'Aggiornamento disponibile';

  @override
  String get update_available_desc =>
      'È disponibile una nuova versione dell\'app';

  @override
  String get no_update_available => 'App aggiornata';

  @override
  String get update_now => 'Aggiorna ora';

  @override
  String get update_later => 'Più tardi';

  @override
  String get checking_for_updates => 'Verifica aggiornamenti…';

  @override
  String get update_error => 'Impossibile verificare gli aggiornamenti';

  @override
  String get update_downloading => 'Download in corso…';

  @override
  String get update_ready_to_install =>
      'Aggiornamento pronto per l\'installazione';

  @override
  String get update_ready_to_install_desc =>
      'Il download è stato completato. Installalo per completare l\'aggiornamento.';

  @override
  String get update_installing => 'Installazione in corso…';

  @override
  String get update_install => 'Installa aggiornamento';

  @override
  String get send_reminder => 'Invia promemoria';

  @override
  String get notification_enabled_desc => 'Spese di oggi sempre in notifica';

  @override
  String get group_type => 'Tipologia';

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
  String get category_family_bills => 'Bollette';

  @override
  String get category_other_misc => 'Varie';

  @override
  String get category_other_utilities => 'Utenze';

  @override
  String get category_other_services => 'Servizi';

  @override
  String get attachments => 'Allegati';

  @override
  String get delete_attachment => 'Elimina allegato';

  @override
  String get share_attachment => 'Condividi allegato';

  @override
  String get delete_attachment_confirm_title => 'Eliminare l\'allegato?';

  @override
  String get delete_attachment_confirm_message =>
      'L\'allegato verrà eliminato dalla spesa.';

  @override
  String get attachment_source => 'Aggiungi allegato';

  @override
  String get from_files => 'Da un file';

  @override
  String get expense => 'Spesa';

  @override
  String get notification_enabled => 'Notifica persistente';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Spese del giorno: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Aggiungi spesa';

  @override
  String get notification_disable => 'Disabilita';

  @override
  String get wizard_group_creation_title => 'Nuovo gruppo';

  @override
  String get wizard_skip => 'Salta';

  @override
  String get wizard_user_name_welcome => 'Ciao!';

  @override
  String get wizard_user_name_label => 'Il tuo nome (facoltativo)';

  @override
  String get wizard_user_name_hint => 'es. Marco';

  @override
  String get wizard_participants_section_title => 'Chi partecipa?';

  @override
  String get wizard_participants_section_hint =>
      'Aggiungi amici o coinquilini. Puoi modificarli dopo.';

  @override
  String get danger_zone => 'Zona pericolosa';

  @override
  String get export_options_desc => 'Scarica o condividi le spese';

  @override
  String get export_csv_description => 'Formato foglio di calcolo';

  @override
  String get export_ofx_description => 'Formato bancario';

  @override
  String get export_markdown_description => 'Formato documento';

  @override
  String get save_label => 'Salva';

  @override
  String get sync_title => 'Sincronizzazione';

  @override
  String get sync_settings_desc => 'Wi-Fi, Bluetooth o Google Drive';

  @override
  String get sync_multiuser_title => 'Sincronizza con altri';

  @override
  String get sync_multiuser_description => 'Gruppi via Wi-Fi o Bluetooth';

  @override
  String get sync_multidevice_title => 'Sincronizza dispositivi';

  @override
  String get sync_multidevice_description =>
      'Allinea i tuoi dispositivi via Drive';

  @override
  String get sync_local_title => 'Wi-Fi';

  @override
  String get sync_local_description => 'Automatica sulla stessa rete Wi-Fi';

  @override
  String get sync_cloud_title => 'Google Drive';

  @override
  String get sync_cloud_description => 'Sincronizzazione via Google Drive';

  @override
  String get sync_cloud_scope_description =>
      'Sincronizza tutti i tuoi gruppi insieme (con Wi-Fi e Bluetooth invece scegli gruppo per gruppo)';

  @override
  String get sync_cloud_enable => 'Attiva la sincronizzazione con Google Drive';

  @override
  String get sync_cloud_privacy =>
      'I tuoi dati vengono salvati nel tuo Google Drive personale, non su server di terzi.';

  @override
  String sync_cloud_signed_in_as(String email) {
    return 'Accesso effettuato come $email';
  }

  @override
  String get sync_cloud_sign_in_failed =>
      'Accesso a Google non riuscito o annullato';

  @override
  String get sync_history_title => 'Cronologia sincronizzazioni';

  @override
  String sync_history_group_desc(String groupTitle) {
    return 'Sincronizzazioni di «$groupTitle»';
  }

  @override
  String get sync_status_syncing => 'Sincronizzazione…';

  @override
  String get sync_now => 'Sincronizza ora';

  @override
  String sync_last_sync(String time) {
    return 'Ultima sincronizzazione: $time';
  }

  @override
  String get sync_bt_title => 'Bluetooth';

  @override
  String get sync_bt_description => 'Manuale, con dispositivi vicini';

  @override
  String get sync_bt_searching => 'Ricerca dispositivi vicini…';

  @override
  String get sync_bt_advertise_waiting => 'In attesa di un dispositivo vicino…';

  @override
  String get sync_bt_sync_with => 'Sincronizza';

  @override
  String get sync_bt_completed => 'Sincronizzazione completata';

  @override
  String sync_bt_received_sent(int received, int sent) {
    return 'Ricevute $received modifiche, inviate $sent';
  }

  @override
  String get sync_bt_error => 'Sincronizzazione fallita';

  @override
  String get sync_bt_error_detail =>
      'Qualcosa è andato storto durante la connessione. Riprova.';

  @override
  String get sync_bt_retry => 'Riprova';

  @override
  String get sync_bt_permission_denied =>
      'Bluetooth non consentito: attivalo nelle impostazioni del telefono';

  @override
  String get sync_history_empty => 'Nessuna sincronizzazione';

  @override
  String get sync_channel_lan => 'LAN';

  @override
  String get sync_channel_bluetooth => 'Bluetooth';

  @override
  String get sync_channel_cloud => 'Cloud';

  @override
  String sync_records_exchanged(int sent, int received) {
    return '$sent inviate, $received ricevute';
  }

  @override
  String get sync_group_shared => 'Condiviso';

  @override
  String get sync_group_enable => 'Condividi questo gruppo';

  @override
  String get sync_group_enable_desc => 'Con i dispositivi abbinati';

  @override
  String get sync_group_needs_channel =>
      'Attiva Wi-Fi o Bluetooth nella sincronizzazione per condividere il gruppo';

  @override
  String get sync_qr_show_button => 'Mostra codice QR';

  @override
  String get sync_qr_scan_button => 'Scansiona codice QR';

  @override
  String get sync_qr_show_title => 'Abbina un dispositivo';

  @override
  String get sync_qr_show_description =>
      'Scansiona questo codice da un altro dispositivo sulla stessa rete Wi-Fi per abbinarlo alla sincronizzazione';

  @override
  String sync_qr_sharing_group(String groupTitle) {
    return 'Condividi «$groupTitle»';
  }

  @override
  String sync_qr_expires_in(String time) {
    return 'Scade tra $time';
  }

  @override
  String get sync_qr_expired_title => 'Codice scaduto';

  @override
  String get sync_qr_expired_desc =>
      'Genera un nuovo codice per continuare l\'abbinamento';

  @override
  String get sync_qr_regenerate_button => 'Genera nuovo codice';

  @override
  String get sync_qr_no_network =>
      'Connettiti al Wi-Fi per generare il codice di abbinamento';

  @override
  String get sync_qr_scan_title => 'Scansiona il codice di abbinamento';

  @override
  String get sync_qr_scan_description =>
      'Inquadra il QR dell\'altro dispositivo';

  @override
  String sync_qr_pair_success(String deviceName) {
    return 'Abbinato con $deviceName';
  }

  @override
  String get sync_qr_pair_failed =>
      'Abbinamento non riuscito — assicurati che entrambi i dispositivi siano sulla stessa rete Wi-Fi';

  @override
  String get sync_qr_pair_expired =>
      'Questo codice di abbinamento è scaduto — chiedi all\'altro dispositivo di mostrarne uno nuovo';

  @override
  String get sync_qr_pair_emulator_host =>
      'Questo codice è stato generato su un emulatore Android, non raggiungibile da altri dispositivi — usa due dispositivi fisici sulla stessa rete Wi-Fi';

  @override
  String get sync_qr_emulator_warning =>
      'Questo dispositivo è un emulatore Android — il suo indirizzo di solito non è raggiungibile da altri dispositivi, quindi l\'abbinamento potrebbe fallire';

  @override
  String get sync_paired_devices_title => 'Dispositivi abbinati';

  @override
  String get sync_paired_devices_empty => 'Nessun dispositivo abbinato';

  @override
  String get sync_paired_devices_remove => 'Rimuovi abbinamento';

  @override
  String get search_expenses => 'Cerca spese';

  @override
  String search_in_group(String groupName) {
    return 'Cerca in $groupName';
  }

  @override
  String get has_attachment => 'Con allegato';

  @override
  String get has_location => 'Con posizione';

  @override
  String get search_no_results => 'Nessuna spesa trovata';

  @override
  String get search_no_results_hint =>
      'Prova termini diversi o modifica i filtri';

  @override
  String get voice_input_button => 'Inserisci con la voce';

  @override
  String get voice_input_listening => 'In ascolto…';

  @override
  String get voice_input_tap_to_speak => 'Tocca per parlare';

  @override
  String get voice_input_processing => 'Elaborazione…';

  @override
  String get voice_input_error => 'Errore nel riconoscimento vocale';

  @override
  String get voice_input_permission_denied => 'Permesso microfono negato';

  @override
  String get voice_input_not_available =>
      'Riconoscimento vocale non disponibile';

  @override
  String get voice_input_no_speech => 'Non ho sentito nulla. Riprova.';

  @override
  String get voice_input_hint =>
      'Prova a dire: «50 euro per la cena al ristorante»';

  @override
  String get voice_add_expense => 'Aggiungi con la voce';

  @override
  String get voice_expense_saved => 'Spesa salvata';

  @override
  String get voice_expense_needs_more_info =>
      'Mancano alcuni dati: completa la spesa';

  @override
  String get from_unsplash => 'Da Unsplash';

  @override
  String get unsplash_search_hint => 'Cerca foto su Unsplash…';

  @override
  String get unsplash_no_results => 'Nessuna immagine trovata';

  @override
  String get unsplash_downloading => 'Scaricamento foto…';

  @override
  String get unsplash_error => 'Impossibile caricare le immagini';

  @override
  String get unsplash_photos_by => 'Foto di';

  @override
  String get unsplash_use_photo => 'Usa questa foto';

  @override
  String get scan_receipt => 'Scansiona scontrino';

  @override
  String get scanning_receipt => 'Lettura scontrino…';

  @override
  String get receipt_scan_error => 'Impossibile leggere lo scontrino';

  @override
  String get receipt_scan_permission_denied =>
      'Fotocamera non consentita: attivala nelle impostazioni del telefono per leggere gli scontrini';

  @override
  String get no_text_found => 'Nessun testo trovato nell\'immagine';

  @override
  String get receipt_scanned => 'Scontrino scansionato';

  @override
  String get settings_group_templates_manage_title => 'Modelli di gruppo';

  @override
  String get settings_group_templates_manage_desc =>
      'Crea e modifica i tuoi modelli';

  @override
  String get settings_group_templates_page_title => 'Modelli di gruppo';

  @override
  String get settings_group_templates_empty_state => 'Nessun modello';

  @override
  String get settings_group_templates_add_title => 'Nuovo modello';

  @override
  String get settings_group_templates_edit_title => 'Modifica modello';

  @override
  String get settings_group_templates_name_label => 'Nome del modello';

  @override
  String get settings_group_templates_name_hint => 'Es. Settimana bianca';

  @override
  String get settings_group_templates_icon_label => 'Icona';

  @override
  String get settings_group_templates_categories_label =>
      'Categorie predefinite';

  @override
  String get settings_group_templates_validation_error =>
      'Nome e almeno una categoria sono obbligatori';

  @override
  String get settings_group_templates_delete_title => 'Elimina modello';

  @override
  String settings_group_templates_delete_message(String templateName) {
    return 'Eliminare il modello «$templateName»?';
  }

  @override
  String get clear_dates => 'Rimuovi date';

  @override
  String accessibility_map_marker_expense(String name, String amount) {
    return '$name, $amount';
  }

  @override
  String accessibility_map_marker_group(int count, String place) {
    return '$count spese, $place';
  }

  @override
  String get nav_home => 'Home';

  @override
  String get nav_groups => 'Gruppi';

  @override
  String get quick_action_map => 'Mappa';

  @override
  String get quick_action_search => 'Cerca';

  @override
  String new_expense_in_group(String group) {
    return 'Nuova spesa in $group';
  }

  @override
  String groups_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gruppi attivi',
      one: '1 gruppo attivo',
      zero: 'Nessun gruppo attivo',
    );
    return '$_temp0';
  }

  @override
  String get get_started_title => 'Per iniziare';

  @override
  String get_started_progress(int done, int total) {
    return '$done di $total fatti';
  }

  @override
  String get get_started_create_group => 'Crea il gruppo';

  @override
  String get get_started_first_expense => 'Aggiungi la prima spesa';

  @override
  String get get_started_participants => 'Aggiungi i partecipanti';

  @override
  String get get_started_look => 'Scegli una foto o un colore';

  @override
  String get_started_step_done(String step) {
    return '$step, fatto';
  }

  @override
  String get balances => 'Saldi';

  @override
  String get settle_up => 'Per pareggiare';

  @override
  String get all_settled_up => 'Siete pari';

  @override
  String balance_gets_back(String name, String amount) {
    return '$name deve ricevere $amount';
  }

  @override
  String balance_owes(String name, String amount) {
    return '$name deve dare $amount';
  }

  @override
  String settlement_pays(String from, String to, String amount) {
    return '$from dà a $to $amount';
  }

  @override
  String places_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count luoghi',
      one: '1 luogo',
    );
    return '$_temp0';
  }

  @override
  String get more_options => 'Altre opzioni';

  @override
  String get highest_expense => 'Spesa più alta';

  @override
  String get most_expensive_day => 'Giorno più caro';

  @override
  String get chart_day_by_day => 'Giorno per giorno';

  @override
  String get this_week => 'Questa settimana';

  @override
  String get last_week => 'Settimana scorsa';

  @override
  String get quick_action_scan => 'Scansiona';

  @override
  String get quick_action_voice => 'Voce';

  @override
  String get sync_state_syncing => 'sincronizzazione in corso';

  @override
  String get sync_state_error =>
      'sincronizzazione non riuscita, tocca per i dettagli';

  @override
  String get share_balances => 'Condividi i saldi';

  @override
  String balances_share_title(String group) {
    return '$group · saldi';
  }

  @override
  String balances_share_footer(String total, String perPerson) {
    return 'Totale $total · $perPerson a testa';
  }

  @override
  String balance_reminder_message(
    String from,
    String group,
    String amount,
    String to,
  ) {
    return 'Ciao $from! Per «$group» devi $amount a $to.';
  }

  @override
  String get chart_week_by_week => 'Settimana per settimana';

  @override
  String get chart_month_by_month => 'Mese per mese';

  @override
  String get edit => 'Modifica';

  @override
  String get recent_searches => 'Ricerche recenti';

  @override
  String get by_type => 'Per tipo';

  @override
  String get favorites => 'Preferiti';

  @override
  String get all_groups => 'Tutti';

  @override
  String get status_label => 'Stato';

  @override
  String show_results(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostra $count risultati',
      one: 'Mostra 1 risultato',
      zero: 'Nessun risultato',
    );
    return '$_temp0';
  }

  @override
  String get expense_details_section => 'Dettagli';

  @override
  String get add_expense_button => 'Aggiungi spesa';

  @override
  String auto_backup_last(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String get auto_backup_never => 'Nessun backup ancora';

  @override
  String get auto_backup_off => 'Spento: dati fuori dal backup';

  @override
  String get drive_backup_connect => 'Collega Google Drive';

  @override
  String get drive_backup_connect_desc => 'Backup in una cartella privata';

  @override
  String get drive_backup_now => 'Salva su Drive ora';

  @override
  String get drive_backup_none => 'Ancora nessun backup su Drive';

  @override
  String get drive_backup_restore => 'Ripristina da Drive';

  @override
  String get drive_backup_restore_desc => 'Scegli uno degli ultimi 5 backup';

  @override
  String get drive_backup_weekly => 'Backup settimanale';

  @override
  String get drive_backup_weekly_desc => 'Ogni settimana, all\'apertura';

  @override
  String get drive_backup_disconnect => 'Scollega';

  @override
  String get drive_backup_saved => 'Backup salvato su Google Drive';

  @override
  String get drive_backup_error => 'Impossibile raggiungere Google Drive';

  @override
  String get expense_more_details => 'Altri dettagli';

  @override
  String get quick_action_photo => 'Foto';

  @override
  String get photo_add_expense => 'Nuova spesa dalla foto dello scontrino';

  @override
  String get receipt_photo_error =>
      'Impossibile scattare la foto dello scontrino';

  @override
  String get crop_hint => 'Trascina e pizzica per scegliere la parte da tenere';

  @override
  String get crop_preview => 'Anteprima';

  @override
  String get crop_use_photo => 'Usa questa foto';

  @override
  String get welcome_tagline =>
      'Le spese di viaggi, casa e amici, divise in modo giusto. Tutto resta sul tuo telefono.';

  @override
  String get wizard_name_title => 'Come ti chiami?';

  @override
  String get wizard_name_note =>
      'Resta sul tuo telefono. Sarai il primo partecipante dei tuoi gruppi.';

  @override
  String get wizard_type_title => 'Che gruppo è?';

  @override
  String get wizard_type_note =>
      'Decide le categorie di partenza: puoi cambiarle quando vuoi.';

  @override
  String get group_type_personal_desc => 'Solo le tue spese';

  @override
  String get group_type_family_desc => 'Casa, famiglia, coinquilini';

  @override
  String get group_type_travel_desc => 'Vacanze, weekend, gite';

  @override
  String get group_type_other_desc => 'Cene, eventi, regali';

  @override
  String get wizard_details_title => 'Come lo chiamiamo?';

  @override
  String get wizard_details_note =>
      'Le date servono per il grafico delle spese. Puoi cambiare tutto anche dopo.';

  @override
  String wizard_people_you(String name) {
    return '$name (tu)';
  }

  @override
  String get wizard_people_add_hint => 'Nome di un amico';

  @override
  String wizard_people_remove(String name) {
    return 'Rimuovi $name';
  }

  @override
  String get wizard_dates_add => 'Date';

  @override
  String get wizard_continue => 'Continua';

  @override
  String get wizard_create => 'Crea gruppo';

  @override
  String get attachment_take_photo => 'Scatta una foto';

  @override
  String get attachment_record_video => 'Registra un video';

  @override
  String get place_search_action => 'Cerca un luogo';

  @override
  String get background_photo => 'Foto';

  @override
  String get background_none => 'Nessuno';

  @override
  String get stats_pace_title => 'Ritmo di spesa';

  @override
  String get stats_per_day => 'al giorno';

  @override
  String get stats_per_month => 'al mese';

  @override
  String stats_pace_days(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Media su $count giorni',
      one: 'Su 1 giorno',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_pace_months(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Media su $count mesi',
      one: 'Su 1 mese',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_per_expense(String amount) {
    return '$amount a spesa';
  }

  @override
  String stats_active_days(int active, int total) {
    return '$active giorni su $total con spese';
  }

  @override
  String stats_active_months(int active, int total) {
    return '$active mesi su $total con spese';
  }

  @override
  String get most_expensive_month => 'Mese più caro';

  @override
  String get per_month => '/mese';

  @override
  String get map_location_off =>
      'Attiva la posizione automatica per vedere le spese sulla mappa';

  @override
  String get map_no_places => 'Ancora nessuna spesa con un luogo';

  @override
  String get no_active_groups_subtitle =>
      'Creane uno per un viaggio, una casa condivisa o un evento.';

  @override
  String get export_options_empty => 'Ancora nessuna spesa da esportare';

  @override
  String get sync_badge_ok => 'sincronizzato nelle ultime 24 ore';

  @override
  String get sync_badge_failed => 'ultima sincronizzazione non riuscita';

  @override
  String get sync_badge_stale => 'non sincronizzato nelle ultime 24 ore';

  @override
  String sync_group_received(String from, String title) {
    return '$from ti ha condiviso “$title”';
  }

  @override
  String sync_group_received_anon(String title) {
    return 'Ti è stato condiviso “$title”';
  }

  @override
  String get group_welcome_title => 'Ti sei unito al gruppo';

  @override
  String group_welcome_body(
    String from,
    String people,
    String expenses,
    String total,
  ) {
    return 'Condiviso da $from: $people, $expenses, $total finora. Le spese che aggiungi qui arrivano anche sugli altri dispositivi.';
  }

  @override
  String group_welcome_body_anon(String people, String expenses, String total) {
    return '$people, $expenses, $total finora. Le spese che aggiungi qui arrivano anche sugli altri dispositivi.';
  }

  @override
  String get toast_open => 'Apri';

  @override
  String stats_per_person(String amount) {
    return '$amount a testa';
  }

  @override
  String get balances_share_per_person => 'Quota a testa';

  @override
  String balances_share_basis(String people) {
    return 'Divisa in parti uguali tra $people';
  }
}
