// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get developer_section_title => 'Desarrollador y soporte';

  @override
  String get repo_section_title => 'Código e incidencias';

  @override
  String get license_section_title => 'Licencia';

  @override
  String get weeklyChartBadge => 'S';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get dateRangeChartBadge => 'D';

  @override
  String get weeklyExpensesChart => 'Gastos semanales';

  @override
  String get monthlyExpensesChart => 'Gastos mensuales';

  @override
  String get dateRangeExpensesChart => 'Gastos por período';

  @override
  String get settings_flag_secure_desc => 'Bloquea capturas y grabación';

  @override
  String get settings_flag_secure_title => 'Pantalla segura';

  @override
  String get settings_app_functions_title => 'Acceso de agentes de IA';

  @override
  String get settings_app_functions_desc => 'Usa Gemini y otros asistentes IA';

  @override
  String get select_currency => 'Moneda';

  @override
  String days_count(int count) {
    return '$count días';
  }

  @override
  String get weekday_mon => 'L';

  @override
  String get weekday_tue => 'M';

  @override
  String get weekday_wed => 'M';

  @override
  String get weekday_thu => 'J';

  @override
  String get weekday_fri => 'V';

  @override
  String get weekday_sat => 'S';

  @override
  String get weekday_sun => 'D';

  @override
  String get month_january => 'Enero';

  @override
  String get month_february => 'Febrero';

  @override
  String get month_march => 'Marzo';

  @override
  String get month_april => 'Abril';

  @override
  String get month_may => 'Mayo';

  @override
  String get month_june => 'Junio';

  @override
  String get month_july => 'Julio';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_september => 'Septiembre';

  @override
  String get month_october => 'Octubre';

  @override
  String get month_november => 'Noviembre';

  @override
  String get month_december => 'Diciembre';

  @override
  String get in_group_prefix => 'en';

  @override
  String get group_total => 'Total';

  @override
  String get markdown_select_directory_title =>
      'Seleccionar carpeta para guardar Markdown';

  @override
  String markdown_saved_in(String path) {
    return 'Markdown guardado en: $path';
  }

  @override
  String get markdown_save_cancelled => 'Exportación Markdown cancelada';

  @override
  String get markdown_save_error => 'Error al guardar el archivo Markdown';

  @override
  String get share_label => 'Compartir';

  @override
  String get export_share => 'Compartir y exportar';

  @override
  String get export_options => 'Exportar gastos';

  @override
  String get welcome_v3_title => 'Organiza.\nComparte.\nLiquida.\n ';

  @override
  String get good_morning => 'Buenos días';

  @override
  String get good_afternoon => 'Buenas tardes';

  @override
  String get good_evening => 'Buenas noches';

  @override
  String get see_all => 'Ver todos';

  @override
  String get view_all_groups => 'Ver todos los grupos';

  @override
  String get no_active_groups => 'No hay grupos activos';

  @override
  String get create_first_group => 'Crear un grupo';

  @override
  String get new_expense_group => 'Nuevo';

  @override
  String get new_expense => 'Nuevo gasto';

  @override
  String get image => 'Foto';

  @override
  String get change_image => 'Cambiar foto';

  @override
  String get from_gallery => 'Desde la galería';

  @override
  String get from_camera => 'Desde la cámara';

  @override
  String get cannot_delete_assigned_participant =>
      'No se puede eliminar el participante: está asignado a uno o más gastos';

  @override
  String get cannot_delete_assigned_category =>
      'No se puede eliminar la categoría: está asignada a uno o más gastos';

  @override
  String get color => 'Color';

  @override
  String get background => 'Fondo';

  @override
  String get participants_description => 'Personas que comparten costos';

  @override
  String get categories_description => 'Agrupar gastos por tipo';

  @override
  String get dates_description => 'Inicio y fin, opcionales';

  @override
  String get select_period => 'Periodo';

  @override
  String get suggested_duration => 'Duración sugerida';

  @override
  String get confirm => 'Confirmar';

  @override
  String get clear => 'Quitar';

  @override
  String get background_color_selected => 'Color seleccionado';

  @override
  String get background_tap_to_replace => 'Tocar para reemplazar';

  @override
  String get background_tap_to_change => 'Tocar para cambiar';

  @override
  String get background_select_image_or_color => 'Elige una foto o un color';

  @override
  String get background_random_color => 'Color aleatorio';

  @override
  String get background_remove => 'Eliminar fondo';

  @override
  String get crop_image_title => 'Recorta la foto';

  @override
  String get crop_confirm => 'Confirmar';

  @override
  String get saving => 'Guardando…';

  @override
  String get expenses => 'Gastos';

  @override
  String get participants => 'Participantes';

  @override
  String participant_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '$count participante',
    );
    return '$_temp0';
  }

  @override
  String get participants_label => 'Participantes';

  @override
  String get last_7_days => 'Últimos 7 días';

  @override
  String get today => 'Hoy';

  @override
  String get this_month => 'Este mes';

  @override
  String get recent_expenses => 'Gastos recientes';

  @override
  String get license_link => 'Ver licencia MIT en GitHub';

  @override
  String get add_trip => 'Añadir grupo';

  @override
  String get group => 'Grupo';

  @override
  String get create => 'Crear';

  @override
  String get group_name => 'Nombre';

  @override
  String get enter_title => 'Introducir un nombre';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get add_expense => 'Nuevo gasto';

  @override
  String get edit_expense => 'Editar gasto';

  @override
  String get expand_form => 'Expandir formulario';

  @override
  String get expand_form_tooltip => 'Añadir fecha, ubicación y notas';

  @override
  String get category => 'Categoría';

  @override
  String get amount => 'Cantidad';

  @override
  String get invalid_amount => 'Cantidad inválida';

  @override
  String get add_category => 'Añadir categoría';

  @override
  String get category_name => 'Nombre de categoría';

  @override
  String get note => 'Nota';

  @override
  String get note_hint => 'Nota';

  @override
  String get select_both_dates =>
      'Si seleccionas una fecha, debes seleccionar ambas';

  @override
  String get end_date_after_start =>
      'La fecha de fin debe ser posterior a la de inicio';

  @override
  String get expenses_by_participant => 'Por participante';

  @override
  String get expenses_by_category => 'Por categoría';

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get backup => 'Respaldo';

  @override
  String get no_trips_to_backup => 'No hay grupos para guardar';

  @override
  String get backup_error => 'Error en el respaldo';

  @override
  String get backup_share_message => 'Aquí está tu respaldo de Caravella';

  @override
  String get import_confirm_title => 'Importar datos';

  @override
  String import_confirm_message(Object file) {
    return '¿Restaurar desde el archivo «$file»? Los grupos actuales se sustituirán y no se podrá deshacer.';
  }

  @override
  String get import_success => 'Datos restaurados';

  @override
  String get import_error => 'No se pudo restaurar: revisa el archivo';

  @override
  String get settings_flag_secure_error =>
      'No se pudo cambiar la protección de pantalla';

  @override
  String get settings_debug_logs_title => 'Registros de depuración';

  @override
  String get settings_debug_logs_desc => 'Registros y errores de la app';

  @override
  String get developer_link_error => 'No se pudo abrir el enlace';

  @override
  String get whats_new_load_error => 'No se pudieron cargar las novedades';

  @override
  String get categories => 'Categorías';

  @override
  String get other_settings_desc => 'Notificación, ubicación';

  @override
  String get segment_general => 'General';

  @override
  String get segment_other => 'Otro';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get add => 'Añadir';

  @override
  String get participant_name => 'Nombre del participante';

  @override
  String get edit_participant => 'Editar participante';

  @override
  String get add_participant => 'Añadir participante';

  @override
  String get edit_category => 'Editar categoría';

  @override
  String get currency => 'Moneda';

  @override
  String get settings_tab => 'Configuración';

  @override
  String get settings => 'Configuración';

  @override
  String get history => 'Historial';

  @override
  String get all => 'Todos';

  @override
  String get search_groups => 'Buscar grupos…';

  @override
  String get no_search_results => 'No se encontraron grupos';

  @override
  String get try_different_search => 'Intenta buscar con palabras diferentes';

  @override
  String get active => 'Activo';

  @override
  String get archived => 'Archivado';

  @override
  String get archive => 'Archivar';

  @override
  String get unarchive => 'Sacar del archivo';

  @override
  String get pin => 'Favorito';

  @override
  String get unpin => 'Desfavorito';

  @override
  String get archived_with_undo => 'Archivado';

  @override
  String get unarchived_with_undo => 'Sacado del archivo';

  @override
  String get pinned_with_undo => 'Marcado como favorito';

  @override
  String get unpinned_with_undo => 'Favorito quitado';

  @override
  String get deleted_with_undo => 'Eliminado';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get period => 'Período';

  @override
  String get total_expenses => 'Total de gastos';

  @override
  String get number_of_expenses => 'Número de gastos';

  @override
  String get select_expense_date => 'Seleccionar fecha del gasto';

  @override
  String get select_expense_date_short => 'Seleccionar fecha';

  @override
  String get date => 'Fecha';

  @override
  String get delete_group => 'Eliminar grupo';

  @override
  String get delete_group_confirm =>
      'El grupo y todos sus gastos se eliminarán. No se podrá deshacer.';

  @override
  String get add_expense_fab => 'Añadir gasto';

  @override
  String get pin_group => 'Marcar como favorito';

  @override
  String get unpin_group => 'Quitar favorito';

  @override
  String get theme_automatic => 'Automático';

  @override
  String get theme_light => 'Claro';

  @override
  String get theme_dark => 'Oscuro';

  @override
  String get per_day => '/día';

  @override
  String get no_expenses_for_statistics =>
      'No hay gastos disponibles para estadísticas';

  @override
  String get settlement => 'Saldar';

  @override
  String get all_balanced => 'Estáis en paz';

  @override
  String get no_expenses_to_export => 'No hay gastos para exportar';

  @override
  String get expense_name => 'Descripción';

  @override
  String get paid_by => 'Pagado por';

  @override
  String get added_by => 'Añadido por';

  @override
  String get edited_by => 'Editado por';

  @override
  String get expense_added_success => 'Gasto añadido';

  @override
  String get expense_updated_success => 'Gasto actualizado';

  @override
  String get refresh => 'Actualizar';

  @override
  String get group_added_success => 'Grupo añadido';

  @override
  String get group_deleted_success => 'Grupo eliminado';

  @override
  String get csv_select_directory_title =>
      'Seleccionar carpeta para guardar CSV';

  @override
  String csv_saved_in(Object path) {
    return 'CSV guardado en: $path';
  }

  @override
  String get csv_save_cancelled => 'Exportación cancelada';

  @override
  String get csv_save_error => 'Error guardando archivo CSV';

  @override
  String get ofx_select_directory_title =>
      'Seleccionar carpeta para guardar OFX';

  @override
  String ofx_saved_in(Object path) {
    return 'OFX guardado en: $path';
  }

  @override
  String get ofx_save_cancelled => 'Exportación OFX cancelada';

  @override
  String get ofx_save_error => 'Error guardando archivo OFX';

  @override
  String get csv_expense_name => 'Descripción';

  @override
  String get csv_amount => 'Cantidad';

  @override
  String get csv_paid_by => 'Pagado por';

  @override
  String get csv_category => 'Categoría';

  @override
  String get csv_date => 'Fecha';

  @override
  String get csv_note => 'Nota';

  @override
  String get csv_location => 'Ubicación';

  @override
  String get location => 'Lugar';

  @override
  String get location_hint => 'Lugar';

  @override
  String get get_current_location => 'Usar ubicación actual';

  @override
  String get getting_location => 'Obteniendo ubicación…';

  @override
  String get location_error => 'No se pudo obtener la ubicación';

  @override
  String get address_resolved => 'Dirección resuelta';

  @override
  String get settings_general => 'General';

  @override
  String get settings_auto_location_title => 'Ubicación automática';

  @override
  String get settings_auto_location_desc => 'Guarda dónde haces cada gasto';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglés';

  @override
  String get settings_language_es => 'Español';

  @override
  String get settings_language_pt => 'Portugués';

  @override
  String get settings_language_zh => 'Chino (simplificado)';

  @override
  String get settings_select_language => 'Idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_appearance => 'Apariencia';

  @override
  String get settings_appearance_desc => 'Idioma, tema y color dinámico';

  @override
  String get settings_dynamic_color => 'Color dinámico';

  @override
  String get settings_dynamic_color_desc =>
      'Usar colores del fondo de pantalla';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get settings_data => 'Datos';

  @override
  String get settings_data_manage => 'Gestión de datos';

  @override
  String get settings_info => 'Información';

  @override
  String get settings_app_version => 'Versión de la aplicación';

  @override
  String get settings_info_card => 'Información';

  @override
  String get settings_info_card_desc =>
      'Desarrollador, código fuente y licencia';

  @override
  String get settings_invite_friends => 'Invita a tus amigos';

  @override
  String get settings_invite_friends_desc =>
      'Comparte Caravella con quien quieras';

  @override
  String get invite_friends_message =>
      '¡Hola! Uso Caravella para dividir los gastos en grupo con amigos, es súper cómoda 🎒💸 Pruébala tú también: https://play.google.com/store/apps/details?id=io.caravella.egm';

  @override
  String get terms_github_title => 'Sitio web: calca';

  @override
  String get terms_github_desc => 'Web del desarrollador';

  @override
  String get terms_repo_title => 'Repositorio GitHub';

  @override
  String get terms_repo_desc => 'Código fuente de la app';

  @override
  String get terms_issue_title => 'Reportar un problema';

  @override
  String get terms_issue_desc => 'Informa de un problema en GitHub';

  @override
  String get terms_license_desc => 'Licencia de código abierto MIT';

  @override
  String get support_developer_title => 'Cómprame un café';

  @override
  String get support_developer_desc => 'Apoya el desarrollo de la app';

  @override
  String get data_title => 'Copia de seguridad y restauración';

  @override
  String get data_backup_desc => 'Guarda los gastos en un archivo';

  @override
  String get data_restore_title => 'Restauración';

  @override
  String get data_restore_desc => 'Desde un archivo de copia';

  @override
  String get auto_backup_title => 'Respaldo automático';

  @override
  String get auto_backup_desc => 'Copia del sistema operativo';

  @override
  String get settings_user_name_title => 'Tu nombre';

  @override
  String get settings_user_name_desc => 'Tu nombre en la app';

  @override
  String get settings_user_name_hint => 'Ingresa tu nombre';

  @override
  String get default_participant_me => 'Yo';

  @override
  String get select_category => 'Categoría';

  @override
  String get delete_expense => 'Eliminar gasto';

  @override
  String get delete_expense_confirm =>
      'El gasto se eliminará. No se podrá deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get daily_average => 'Diario';

  @override
  String get spent_today => 'Hoy';

  @override
  String get monthly_average => 'Mensual';

  @override
  String get welcome_v3_cta => 'Empezar';

  @override
  String get discard_changes_title => '¿Salir sin guardar?';

  @override
  String get discard_changes_message =>
      'Los cambios que no has guardado se perderán.';

  @override
  String get discard => 'Descartar';

  @override
  String error_saving_group(Object error) {
    return 'Error guardando: $error';
  }

  @override
  String get already_exists => 'ya existe';

  @override
  String get status_active => 'Activos';

  @override
  String get status_archived => 'Archivados';

  @override
  String get no_archived_groups => 'No hay grupos archivados';

  @override
  String get no_archived_groups_subtitle => 'Aún no has archivado ningún grupo';

  @override
  String get all_groups_archived_info =>
      'Todos tus grupos están en el archivo. Puedes recuperarlos desde allí o crear uno nuevo.';

  @override
  String get welcome_logo_semantic => 'Logo de la aplicación Caravella';

  @override
  String get create_new_group => 'Crear nuevo grupo';

  @override
  String get accessibility_back_button => 'Atrás';

  @override
  String get accessibility_groups_list => 'Lista de grupos';

  @override
  String get accessibility_welcome_screen => 'Pantalla de bienvenida';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Gastos totales: $amount';
  }

  @override
  String get accessibility_add_expense => 'Añadir gasto';

  @override
  String get accessibility_currently_disabled => 'Actualmente deshabilitado';

  @override
  String get accessibility_previous_month => 'Mes anterior';

  @override
  String get accessibility_next_month => 'Mes siguiente';

  @override
  String get color_suggested_title => 'Colores sugeridos';

  @override
  String get color_suggested_subtitle =>
      'Tonos suaves que se adaptan al tema claro y oscuro';

  @override
  String get color_random_subtitle =>
      'Deja que la aplicación elija un color por ti';

  @override
  String get currency_AED => 'Dírham de Emiratos Árabes Unidos';

  @override
  String get currency_AFN => 'Afghani afgano';

  @override
  String get currency_ALL => 'Lek albanés';

  @override
  String get currency_AMD => 'Dram armenio';

  @override
  String get currency_ANG => 'Florín antillano neerlandés';

  @override
  String get currency_AOA => 'Kwanza angoleño';

  @override
  String get currency_ARS => 'Peso argentino';

  @override
  String get currency_AUD => 'Dólar australiano';

  @override
  String get currency_AWG => 'Florín arubeño';

  @override
  String get currency_AZN => 'Manat azerbaiyano';

  @override
  String get currency_BAM => 'Marco convertible bosnio';

  @override
  String get currency_BBD => 'Dólar de Barbados';

  @override
  String get currency_BDT => 'Taka bangladesí';

  @override
  String get currency_BGN => 'Lev búlgaro';

  @override
  String get currency_BHD => 'Dinar bahreiní';

  @override
  String get currency_BIF => 'Franco burundés';

  @override
  String get currency_BMD => 'Dólar bermudeño';

  @override
  String get currency_BND => 'Dólar de Brunéi';

  @override
  String get currency_BOB => 'Boliviano';

  @override
  String get currency_BRL => 'Real brasileño';

  @override
  String get currency_BSD => 'Dólar bahameño';

  @override
  String get currency_BTN => 'Ngultrum butanés';

  @override
  String get currency_BWP => 'Pula botswanés';

  @override
  String get currency_BYN => 'Rublo bielorruso';

  @override
  String get currency_BZD => 'Dólar beliceño';

  @override
  String get currency_CAD => 'Dólar canadiense';

  @override
  String get currency_CDF => 'Franco congoleño';

  @override
  String get currency_CHF => 'Franco suizo';

  @override
  String get currency_CLP => 'Peso chileno';

  @override
  String get currency_CNY => 'Yuan chino';

  @override
  String get currency_COP => 'Peso colombiano';

  @override
  String get currency_CRC => 'Colón costarricense';

  @override
  String get currency_CUP => 'Peso cubano';

  @override
  String get currency_CVE => 'Escudo caboverdiano';

  @override
  String get currency_CZK => 'Corona checa';

  @override
  String get currency_DJF => 'Franco yibutiano';

  @override
  String get currency_DKK => 'Corona danesa';

  @override
  String get currency_DOP => 'Peso dominicano';

  @override
  String get currency_DZD => 'Dinar argelino';

  @override
  String get currency_EGP => 'Libra egipcia';

  @override
  String get currency_ERN => 'Nakfa eritreo';

  @override
  String get currency_ETB => 'Birr etíope';

  @override
  String get currency_EUR => 'Euro';

  @override
  String get currency_FJD => 'Dólar fiyiano';

  @override
  String get currency_FKP => 'Libra malvinense';

  @override
  String get currency_GBP => 'Libra esterlina';

  @override
  String get currency_GEL => 'Lari georgiano';

  @override
  String get currency_GHS => 'Cedi ghanés';

  @override
  String get currency_GIP => 'Libra gibraltareña';

  @override
  String get currency_GMD => 'Dalasi gambiano';

  @override
  String get currency_GNF => 'Franco guineano';

  @override
  String get currency_GTQ => 'Quetzal guatemalteco';

  @override
  String get currency_GYD => 'Dólar guyanés';

  @override
  String get currency_HKD => 'Dólar de Hong Kong';

  @override
  String get currency_HNL => 'Lempira hondureño';

  @override
  String get currency_HTG => 'Gourde haitiano';

  @override
  String get currency_HUF => 'Florín húngaro';

  @override
  String get currency_IDR => 'Rupia indonesia';

  @override
  String get currency_ILS => 'Nuevo shekel israelí';

  @override
  String get currency_INR => 'Rupia india';

  @override
  String get currency_IQD => 'Dinar iraquí';

  @override
  String get currency_IRR => 'Rial iraní';

  @override
  String get currency_ISK => 'Corona islandesa';

  @override
  String get currency_JMD => 'Dólar jamaiquino';

  @override
  String get currency_JOD => 'Dinar jordano';

  @override
  String get currency_JPY => 'Yen japonés';

  @override
  String get currency_KES => 'Chelín keniano';

  @override
  String get currency_KGS => 'Som kirguís';

  @override
  String get currency_KHR => 'Riel camboyano';

  @override
  String get currency_KID => 'Dólar kiribatí';

  @override
  String get currency_KMF => 'Franco comorense';

  @override
  String get currency_KPW => 'Won norcoreano';

  @override
  String get currency_KRW => 'Won surcoreano';

  @override
  String get currency_KWD => 'Dinar kuwaití';

  @override
  String get currency_KYD => 'Dólar caimán';

  @override
  String get currency_KZT => 'Tenge kazajo';

  @override
  String get currency_LAK => 'Kip laosiano';

  @override
  String get currency_LBP => 'Libra libanesa';

  @override
  String get currency_LKR => 'Rupia de Sri Lanka';

  @override
  String get currency_LRD => 'Dólar liberiano';

  @override
  String get currency_LSL => 'Loti lesothense';

  @override
  String get currency_LYD => 'Dinar libio';

  @override
  String get currency_MAD => 'Dírham marroquí';

  @override
  String get currency_MDL => 'Leu moldavo';

  @override
  String get currency_MGA => 'Ariary malgache';

  @override
  String get currency_MKD => 'Denar macedonio';

  @override
  String get currency_MMK => 'Kyat birmano';

  @override
  String get currency_MNT => 'Tugrik mongol';

  @override
  String get currency_MOP => 'Pataca macaense';

  @override
  String get currency_MRU => 'Ouguiya mauritano';

  @override
  String get currency_MUR => 'Rupia mauriciana';

  @override
  String get currency_MVR => 'Rufiyaa maldiva';

  @override
  String get currency_MWK => 'Kwacha malauí';

  @override
  String get currency_MXN => 'Peso mexicano';

  @override
  String get currency_MYR => 'Ringgit malayo';

  @override
  String get currency_MZN => 'Metical mozambiqueño';

  @override
  String get currency_NAD => 'Dólar namibio';

  @override
  String get currency_NGN => 'Naira nigeriana';

  @override
  String get currency_NIO => 'Córdoba nicaragüense';

  @override
  String get currency_NOK => 'Corona noruega';

  @override
  String get currency_NPR => 'Rupia nepalí';

  @override
  String get currency_NZD => 'Dólar neozelandés';

  @override
  String get currency_OMR => 'Rial omaní';

  @override
  String get currency_PAB => 'Balboa panameño';

  @override
  String get currency_PEN => 'Sol peruano';

  @override
  String get currency_PGK => 'Kina papú';

  @override
  String get currency_PHP => 'Peso filipino';

  @override
  String get currency_PKR => 'Rupia pakistaní';

  @override
  String get currency_PLN => 'Zloty polaco';

  @override
  String get currency_PYG => 'Guaraní paraguayo';

  @override
  String get currency_QAR => 'Riyal catarí';

  @override
  String get currency_RON => 'Leu rumano';

  @override
  String get currency_RSD => 'Dinar serbio';

  @override
  String get currency_RUB => 'Rublo ruso';

  @override
  String get currency_RWF => 'Franco ruandés';

  @override
  String get currency_SAR => 'Riyal saudí';

  @override
  String get currency_SBD => 'Dólar de las Islas Salomón';

  @override
  String get currency_SCR => 'Rupia seychellense';

  @override
  String get currency_SDG => 'Libra sudanesa';

  @override
  String get currency_SEK => 'Corona sueca';

  @override
  String get currency_SGD => 'Dólar singapurense';

  @override
  String get currency_SHP => 'Libra de Santa Elena';

  @override
  String get currency_SLE => 'Leone sierraleonés';

  @override
  String get currency_SLL => 'Leone sierraleonés (anterior)';

  @override
  String get currency_SOS => 'Chelín somalí';

  @override
  String get currency_SRD => 'Dólar surinamés';

  @override
  String get currency_SSP => 'Libra sursudanesa';

  @override
  String get currency_STN => 'Dobra santotomense';

  @override
  String get currency_SVC => 'Colón salvadoreño';

  @override
  String get currency_SYP => 'Libra siria';

  @override
  String get currency_SZL => 'Lilangeni suazi';

  @override
  String get currency_THB => 'Baht tailandés';

  @override
  String get currency_TJS => 'Somoni tayiko';

  @override
  String get currency_TMT => 'Manat turkmeno';

  @override
  String get currency_TND => 'Dinar tunecino';

  @override
  String get currency_TOP => 'Pa\'anga tongano';

  @override
  String get currency_TRY => 'Lira turca';

  @override
  String get currency_TTD => 'Dólar trinitense';

  @override
  String get currency_TVD => 'Dólar tuvaluano';

  @override
  String get currency_TWD => 'Dólar taiwanés';

  @override
  String get currency_TZS => 'Chelín tanzano';

  @override
  String get currency_UAH => 'Grivna ucraniana';

  @override
  String get currency_UGX => 'Chelín ugandés';

  @override
  String get currency_USD => 'Dólar estadounidense';

  @override
  String get currency_UYU => 'Peso uruguayo';

  @override
  String get currency_UZS => 'Som uzbeko';

  @override
  String get currency_VED => 'Bolívar venezolano';

  @override
  String get currency_VES => 'Bolívar soberano venezolano';

  @override
  String get currency_VND => 'Dong vietnamita';

  @override
  String get currency_VUV => 'Vatu vanuatuense';

  @override
  String get currency_WST => 'Tala samoano';

  @override
  String get currency_XAF => 'Franco CFA de África Central';

  @override
  String get currency_XOF => 'Franco CFA de África Occidental';

  @override
  String get currency_XPF => 'Franco CFP';

  @override
  String get currency_YER => 'Rial yemení';

  @override
  String get currency_ZAR => 'Rand sudafricano';

  @override
  String get currency_ZMW => 'Kwacha zambiano';

  @override
  String get currency_ZWL => 'Dólar zimbabuense';

  @override
  String get search_currency => 'Buscar moneda…';

  @override
  String get clear_filters => 'Restablecer';

  @override
  String get filters => 'Filtros';

  @override
  String get empty_expenses_title => 'Aún no hay gastos';

  @override
  String get empty_expenses_subtitle =>
      'Añade el primero: lo encontrarás aquí.';

  @override
  String get add_first_expense_button => 'Añadir gasto';

  @override
  String get show_search => 'Mostrar barra de búsqueda';

  @override
  String get whats_new_title => 'Novedades';

  @override
  String get changelog_title => 'Registro de cambios';

  @override
  String get expenses_map => 'Mapa de Gastos';

  @override
  String get no_locations_available => 'Sin lugares';

  @override
  String get no_locations_subtitle =>
      'Añade un lugar a tus gastos para verlos en el mapa';

  @override
  String expense_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gastos',
      one: '1 gasto',
    );
    return '$_temp0';
  }

  @override
  String get check_for_updates => 'Buscar actualizaciones';

  @override
  String get check_for_updates_desc => 'Busca una nueva versión';

  @override
  String get update_available => 'Actualización disponible';

  @override
  String get update_available_desc =>
      'Una nueva versión de la app está disponible';

  @override
  String get no_update_available => 'App actualizada';

  @override
  String get update_now => 'Actualizar ahora';

  @override
  String get update_later => 'Más tarde';

  @override
  String get checking_for_updates => 'Buscando actualizaciones…';

  @override
  String get update_error => 'No se pudieron buscar actualizaciones';

  @override
  String get update_downloading => 'Descargando…';

  @override
  String get update_ready_to_install => 'Actualización lista para instalar';

  @override
  String get update_ready_to_install_desc =>
      'La descarga ha finalizado. Instálala para completar la actualización.';

  @override
  String get update_installing => 'Instalando…';

  @override
  String get update_install => 'Instalar actualización';

  @override
  String get send_reminder => 'Enviar recordatorio';

  @override
  String get notification_enabled_desc => 'Gastos de hoy en una notificación';

  @override
  String get group_type => 'Tipo';

  @override
  String get group_type_travel => 'Viaje';

  @override
  String get group_type_personal => 'Personal';

  @override
  String get group_type_family => 'Familia';

  @override
  String get group_type_other => 'Otro';

  @override
  String get category_travel_transport => 'Transporte';

  @override
  String get category_travel_accommodation => 'Alojamiento';

  @override
  String get category_travel_restaurants => 'Restaurantes';

  @override
  String get category_personal_shopping => 'Compras';

  @override
  String get category_personal_health => 'Salud';

  @override
  String get category_personal_entertainment => 'Entretenimiento';

  @override
  String get category_family_groceries => 'Comestibles';

  @override
  String get category_family_home => 'Casa';

  @override
  String get category_family_bills => 'Facturas';

  @override
  String get category_other_misc => 'Varios';

  @override
  String get category_other_utilities => 'Suministros';

  @override
  String get category_other_services => 'Servicios';

  @override
  String get attachments => 'Adjuntos';

  @override
  String get delete_attachment => 'Eliminar adjunto';

  @override
  String get share_attachment => 'Compartir adjunto';

  @override
  String get delete_attachment_confirm_title => '¿Eliminar el adjunto?';

  @override
  String get delete_attachment_confirm_message =>
      'El adjunto se eliminará del gasto.';

  @override
  String get attachment_source => 'Añadir adjunto';

  @override
  String get from_files => 'Desde un archivo';

  @override
  String get expense => 'Gasto';

  @override
  String get notification_enabled => 'Notificación persistente';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Gastos de hoy: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Añadir gasto';

  @override
  String get notification_disable => 'Desactivar';

  @override
  String get wizard_group_creation_title => 'Nuevo grupo';

  @override
  String get wizard_skip => 'Omitir';

  @override
  String get wizard_user_name_welcome => '¡Hola!';

  @override
  String get wizard_user_name_label => 'Tu nombre (opcional)';

  @override
  String get wizard_user_name_hint => 'ej. Carlos';

  @override
  String get wizard_participants_section_title => '¿Quién participa?';

  @override
  String get wizard_participants_section_hint =>
      'Añade amigos o compañeros. Puedes modificarlos después.';

  @override
  String get danger_zone => 'Zona de peligro';

  @override
  String get export_options_desc => 'Descarga o comparte los gastos';

  @override
  String get export_csv_description => 'Formato hoja de cálculo';

  @override
  String get export_ofx_description => 'Formato bancario';

  @override
  String get export_markdown_description => 'Formato documento';

  @override
  String get save_label => 'Guardar';

  @override
  String get sync_title => 'Sincronización';

  @override
  String get sync_settings_desc => 'Wi-Fi, Bluetooth o Google Drive';

  @override
  String get sync_multiuser_title => 'Sincroniza con otros';

  @override
  String get sync_multiuser_description => 'Grupos por Wi-Fi o Bluetooth';

  @override
  String get sync_multidevice_title => 'Sincroniza dispositivos';

  @override
  String get sync_multidevice_description =>
      'Sincroniza tus dispositivos con Drive';

  @override
  String get sync_local_title => 'Wi-Fi';

  @override
  String get sync_local_description => 'Automática en la misma Wi-Fi';

  @override
  String get sync_cloud_title => 'Google Drive';

  @override
  String get sync_cloud_description => 'Sincronización vía Google Drive';

  @override
  String get sync_cloud_scope_description =>
      'Sincroniza todos tus grupos a la vez (con Wi-Fi y Bluetooth eliges grupo por grupo)';

  @override
  String get sync_cloud_enable => 'Activa la sincronización con Google Drive';

  @override
  String get sync_cloud_privacy =>
      'Tus datos se guardan en tu Google Drive personal, no en servidores de terceros.';

  @override
  String sync_cloud_signed_in_as(String email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String get sync_cloud_sign_in_failed =>
      'El inicio de sesión de Google falló o fue cancelado';

  @override
  String get sync_history_title => 'Historial de sincronizaciones';

  @override
  String sync_history_group_desc(String groupTitle) {
    return 'Sincronizaciones de «$groupTitle»';
  }

  @override
  String get sync_status_syncing => 'Sincronizando…';

  @override
  String get sync_now => 'Sincronizar ahora';

  @override
  String sync_last_sync(String time) {
    return 'Última sincronización: $time';
  }

  @override
  String get sync_bt_title => 'Bluetooth';

  @override
  String get sync_bt_description => 'Manual, con dispositivos cercanos';

  @override
  String get sync_bt_searching => 'Buscando dispositivos cercanos…';

  @override
  String get sync_bt_advertise_waiting => 'Esperando un dispositivo cercano…';

  @override
  String get sync_bt_sync_with => 'Sincronizar';

  @override
  String get sync_bt_completed => 'Sincronización completada';

  @override
  String sync_bt_received_sent(int received, int sent) {
    return 'Recibidos $received cambios, enviados $sent';
  }

  @override
  String get sync_bt_error => 'Sincronización fallida';

  @override
  String get sync_bt_error_detail =>
      'Algo salió mal durante la conexión. Inténtalo de nuevo.';

  @override
  String get sync_bt_retry => 'Reintentar';

  @override
  String get sync_bt_permission_denied =>
      'Bluetooth no permitido: actívalo en los ajustes del teléfono';

  @override
  String get sync_history_empty => 'Sin sincronizaciones';

  @override
  String get sync_channel_lan => 'LAN';

  @override
  String get sync_channel_bluetooth => 'Bluetooth';

  @override
  String get sync_channel_cloud => 'Nube';

  @override
  String sync_records_exchanged(int sent, int received) {
    return '$sent enviados, $received recibidos';
  }

  @override
  String get sync_group_shared => 'Compartido';

  @override
  String get sync_group_enable => 'Compartir este grupo';

  @override
  String get sync_group_enable_desc => 'Con los dispositivos vinculados';

  @override
  String get sync_group_needs_channel =>
      'Activa Wi-Fi o Bluetooth en Sincronización para compartir el grupo';

  @override
  String get sync_qr_show_button => 'Mostrar código QR';

  @override
  String get sync_qr_scan_button => 'Escanear código QR';

  @override
  String get sync_qr_show_title => 'Emparejar un dispositivo';

  @override
  String get sync_qr_show_description =>
      'Escanea este código desde otro dispositivo en la misma red Wi-Fi para emparejarlo con la sincronización';

  @override
  String sync_qr_sharing_group(String groupTitle) {
    return 'Compartiendo «$groupTitle»';
  }

  @override
  String sync_qr_expires_in(String time) {
    return 'Caduca en $time';
  }

  @override
  String get sync_qr_expired_title => 'Código caducado';

  @override
  String get sync_qr_expired_desc =>
      'Genera un código nuevo para seguir emparejando';

  @override
  String get sync_qr_regenerate_button => 'Generar código nuevo';

  @override
  String get sync_qr_no_network =>
      'Conéctate al Wi-Fi para generar el código de emparejamiento';

  @override
  String get sync_qr_scan_title => 'Escanea el código de emparejamiento';

  @override
  String get sync_qr_scan_description => 'Escanea el QR del otro dispositivo';

  @override
  String sync_qr_pair_success(String deviceName) {
    return 'Emparejado con $deviceName';
  }

  @override
  String get sync_qr_pair_failed =>
      'Error al emparejar — asegúrate de que ambos dispositivos estén en la misma red Wi-Fi';

  @override
  String get sync_qr_pair_expired =>
      'Este código de emparejamiento ha caducado — pide al otro dispositivo que muestre uno nuevo';

  @override
  String get sync_qr_pair_emulator_host =>
      'Este código se generó en un emulador de Android, que no se puede alcanzar desde otros dispositivos — empareja usando dos dispositivos físicos en la misma red Wi-Fi';

  @override
  String get sync_qr_emulator_warning =>
      'Este dispositivo es un emulador de Android — su dirección normalmente no es alcanzable desde otros dispositivos, por lo que el emparejamiento podría fallar';

  @override
  String get sync_paired_devices_title => 'Dispositivos emparejados';

  @override
  String get sync_paired_devices_empty => 'Aún no hay dispositivos emparejados';

  @override
  String get sync_paired_devices_remove => 'Quitar emparejamiento';

  @override
  String get search_expenses => 'Buscar gastos';

  @override
  String search_in_group(String groupName) {
    return 'Buscar en $groupName';
  }

  @override
  String get has_attachment => 'Con adjunto';

  @override
  String get has_location => 'Con ubicación';

  @override
  String get search_no_results => 'No se encontraron gastos';

  @override
  String get search_no_results_hint =>
      'Prueba diferentes términos o ajusta los filtros';

  @override
  String get voice_input_button => 'Añadir por voz';

  @override
  String get voice_input_listening => 'Escuchando…';

  @override
  String get voice_input_tap_to_speak => 'Toca para hablar';

  @override
  String get voice_input_processing => 'Procesando…';

  @override
  String get voice_input_error => 'Error de reconocimiento de voz';

  @override
  String get voice_input_permission_denied => 'Permiso de micrófono denegado';

  @override
  String get voice_input_not_available => 'Reconocimiento de voz no disponible';

  @override
  String get voice_input_no_speech =>
      'No he escuchado nada. Inténtalo de nuevo.';

  @override
  String get voice_input_hint =>
      'Prueba a decir: «50 euros por la cena en el restaurante»';

  @override
  String get voice_add_expense => 'Añadir por voz';

  @override
  String get voice_expense_saved => 'Gasto guardado';

  @override
  String get voice_expense_needs_more_info =>
      'Faltan algunos datos: completa el gasto';

  @override
  String get from_unsplash => 'Desde Unsplash';

  @override
  String get unsplash_search_hint => 'Buscar fotos en Unsplash…';

  @override
  String get unsplash_no_results => 'No se encontraron imágenes';

  @override
  String get unsplash_downloading => 'Descargando foto…';

  @override
  String get unsplash_error => 'Error al cargar las imágenes';

  @override
  String get unsplash_photos_by => 'Fotos de';

  @override
  String get unsplash_use_photo => 'Usar esta foto';

  @override
  String get scan_receipt => 'Escanear recibo';

  @override
  String get scanning_receipt => 'Leyendo el recibo…';

  @override
  String get receipt_scan_error => 'No se pudo leer el recibo';

  @override
  String get receipt_scan_permission_denied =>
      'Cámara no permitida: actívala en los ajustes del teléfono para leer recibos';

  @override
  String get no_text_found => 'No se encontró texto en la imagen';

  @override
  String get receipt_scanned => 'Recibo escaneado';

  @override
  String get settings_group_templates_manage_title => 'Plantillas de grupo';

  @override
  String get settings_group_templates_manage_desc =>
      'Crea y edita tus plantillas';

  @override
  String get settings_group_templates_page_title => 'Plantillas de grupo';

  @override
  String get settings_group_templates_empty_state => 'Sin plantillas';

  @override
  String get settings_group_templates_add_title => 'Nueva plantilla';

  @override
  String get settings_group_templates_edit_title => 'Editar plantilla';

  @override
  String get settings_group_templates_name_label => 'Nombre de la plantilla';

  @override
  String get settings_group_templates_name_hint => 'Ej. Semana de esquí';

  @override
  String get settings_group_templates_icon_label => 'Icono';

  @override
  String get settings_group_templates_categories_label =>
      'Categorías predeterminadas';

  @override
  String get settings_group_templates_validation_error =>
      'Se requiere nombre y al menos una categoría';

  @override
  String get settings_group_templates_delete_title => 'Eliminar plantilla';

  @override
  String settings_group_templates_delete_message(String templateName) {
    return '¿Eliminar la plantilla «$templateName»?';
  }

  @override
  String get clear_dates => 'Quitar fechas';

  @override
  String accessibility_map_marker_expense(String name, String amount) {
    return '$name, $amount';
  }

  @override
  String accessibility_map_marker_group(int count, String place) {
    return '$count gastos, $place';
  }

  @override
  String get nav_home => 'Inicio';

  @override
  String get nav_groups => 'Grupos';

  @override
  String get quick_action_map => 'Mapa';

  @override
  String get quick_action_search => 'Buscar';

  @override
  String new_expense_in_group(String group) {
    return 'Nuevo gasto en $group';
  }

  @override
  String groups_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos activos',
      one: '1 grupo activo',
      zero: 'Ningún grupo activo',
    );
    return '$_temp0';
  }

  @override
  String get get_started_title => 'Primeros pasos';

  @override
  String get_started_progress(int done, int total) {
    return '$done de $total hechos';
  }

  @override
  String get get_started_create_group => 'Crea el grupo';

  @override
  String get get_started_first_expense => 'Añade el primer gasto';

  @override
  String get get_started_participants => 'Añade a los participantes';

  @override
  String get get_started_look => 'Elige una foto o un color';

  @override
  String get_started_step_done(String step) {
    return '$step, hecho';
  }

  @override
  String get balances => 'Saldos';

  @override
  String get per_person => 'Por persona';

  @override
  String get settle_up => 'Para saldar';

  @override
  String get all_settled_up => 'Todo saldado';

  @override
  String balance_gets_back(String name, String amount) {
    return '$name recupera $amount';
  }

  @override
  String balance_owes(String name, String amount) {
    return '$name debe $amount';
  }

  @override
  String settlement_pays(String from, String to, String amount) {
    return '$from paga a $to $amount';
  }

  @override
  String places_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares',
      one: '1 lugar',
    );
    return '$_temp0';
  }

  @override
  String get more_options => 'Más opciones';

  @override
  String get highest_expense => 'Gasto más alto';

  @override
  String get most_expensive_day => 'Día más caro';

  @override
  String get chart_day_by_day => 'Día a día';

  @override
  String get this_week => 'Esta semana';

  @override
  String get last_week => 'La semana pasada';

  @override
  String get quick_action_scan => 'Escanear';

  @override
  String get quick_action_voice => 'Voz';

  @override
  String get sync_state_syncing => 'sincronizando';

  @override
  String get sync_state_synced => 'actualizado';

  @override
  String get sync_state_error =>
      'sincronización fallida, toca para ver detalles';

  @override
  String get share_balances => 'Compartir saldos';

  @override
  String balances_share_title(String group) {
    return '$group · saldos';
  }

  @override
  String balances_share_footer(String total, String perPerson) {
    return 'Total $total · $perPerson por persona';
  }

  @override
  String balance_reminder_message(
    String from,
    String group,
    String amount,
    String to,
  ) {
    return '¡Hola $from! En «$group» debes $amount a $to.';
  }

  @override
  String get chart_week_by_week => 'Semana a semana';

  @override
  String get chart_month_by_month => 'Mes a mes';

  @override
  String get edit => 'Editar';

  @override
  String get recent_searches => 'Búsquedas recientes';

  @override
  String get by_type => 'Por tipo';

  @override
  String get favorites => 'Favoritos';

  @override
  String get all_groups => 'Todos';

  @override
  String get status_label => 'Estado';

  @override
  String show_results(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mostrar $count resultados',
      one: 'Mostrar 1 resultado',
      zero: 'Sin resultados',
    );
    return '$_temp0';
  }

  @override
  String get expense_details_section => 'Detalles';

  @override
  String get add_expense_button => 'Añadir gasto';

  @override
  String auto_backup_last(String date) {
    return 'Última copia: $date';
  }

  @override
  String get auto_backup_never => 'Aún no hay copia';

  @override
  String get auto_backup_off => 'Apagado: datos fuera de la copia';

  @override
  String get drive_backup_connect => 'Conectar Google Drive';

  @override
  String get drive_backup_connect_desc => 'Copias en una carpeta privada';

  @override
  String get drive_backup_now => 'Guardar en Drive ahora';

  @override
  String get drive_backup_none => 'Aún no hay copias en Drive';

  @override
  String get drive_backup_restore => 'Restaurar desde Drive';

  @override
  String get drive_backup_restore_desc => 'Elige una de las últimas 5 copias';

  @override
  String get drive_backup_weekly => 'Copia semanal';

  @override
  String get drive_backup_weekly_desc => 'Cada semana, al abrir la app';

  @override
  String get drive_backup_disconnect => 'Desconectar';

  @override
  String get drive_backup_saved => 'Copia guardada en Google Drive';

  @override
  String get drive_backup_error => 'No se pudo conectar con Google Drive';

  @override
  String get expense_more_details => 'Más detalles';

  @override
  String get quick_action_photo => 'Foto';

  @override
  String get photo_add_expense => 'Nuevo gasto con foto del recibo';

  @override
  String get receipt_photo_error => 'No se pudo tomar la foto del recibo';

  @override
  String get crop_hint =>
      'Arrastra y pellizca para elegir la parte que quieres';

  @override
  String get crop_preview => 'Vista previa';

  @override
  String get crop_use_photo => 'Usar esta foto';

  @override
  String get welcome_tagline =>
      'Gastos de viajes, casa y amigos, repartidos de forma justa. Todo se queda en tu teléfono.';

  @override
  String get wizard_name_title => '¿Cómo te llamas?';

  @override
  String get wizard_name_note =>
      'Se queda en tu teléfono. Serás el primer participante de tus grupos.';

  @override
  String get wizard_type_title => '¿Qué tipo de grupo?';

  @override
  String get wizard_type_note =>
      'Define las categorías iniciales: puedes cambiarlas cuando quieras.';

  @override
  String get group_type_personal_desc => 'Solo tus gastos';

  @override
  String get group_type_family_desc => 'Casa, familia, compañeros de piso';

  @override
  String get group_type_travel_desc => 'Vacaciones, findes, excursiones';

  @override
  String get group_type_other_desc => 'Cenas, eventos, regalos';

  @override
  String get wizard_details_title => '¿Cómo lo llamamos?';

  @override
  String get wizard_details_note =>
      'Las fechas sirven para el gráfico de gastos. Puedes cambiarlo todo después.';

  @override
  String wizard_people_you(String name) {
    return '$name (tú)';
  }

  @override
  String get wizard_people_add_hint => 'Nombre de un amigo';

  @override
  String wizard_people_remove(String name) {
    return 'Quitar a $name';
  }

  @override
  String get wizard_dates_add => 'Fechas';

  @override
  String get wizard_continue => 'Continuar';

  @override
  String get wizard_create => 'Crear grupo';

  @override
  String get attachment_take_photo => 'Hacer una foto';

  @override
  String get attachment_record_video => 'Grabar un vídeo';

  @override
  String get place_search_action => 'Buscar un lugar';

  @override
  String get background_photo => 'Foto';

  @override
  String get background_none => 'Ninguno';
}
