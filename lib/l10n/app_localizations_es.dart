// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get developer_section_title => 'Desarrollador y Soporte';

  @override
  String get developer_section_desc => 'Apoya al desarrollador o ver perfil';

  @override
  String get repo_section_title => 'Código fuente y problemas';

  @override
  String get repo_section_desc => 'Ver código fuente o reportar un problema';

  @override
  String get license_section_title => 'Licencia';

  @override
  String get license_section_desc => 'Ver la licencia de código abierto';

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
  String get settings_flag_secure_desc =>
      'Impide capturas de pantalla y grabación de pantalla';

  @override
  String get settings_flag_secure_title => 'Pantalla segura';

  @override
  String get settings_privacy => 'Privacidad';

  @override
  String get select_currency => 'Seleccionar moneda';

  @override
  String get select_period_hint_short => 'Establecer fechas';

  @override
  String get select_period_hint => 'Seleccionar fechas';

  @override
  String get suggested_duration => 'Duración sugerida';

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
  String get save_change_expense => 'Guardar cambios';

  @override
  String get group_total => 'Total';

  @override
  String get total_spent => 'Total gastado';

  @override
  String get download_all_csv => 'Descargar todo (CSV)';

  @override
  String get share_all_csv => 'Compartir todo (CSV)';

  @override
  String get download_all_ofx => 'Descargar todo (OFX)';

  @override
  String get share_all_ofx => 'Compartir todo (OFX)';

  @override
  String get download_all_markdown => 'Descargar todo (Markdown)';

  @override
  String get share_all_markdown => 'Compartir todo (Markdown)';

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
  String get share_text_label => 'Compartir texto';

  @override
  String get share_image_label => 'Compartir imagen';

  @override
  String get export_share => 'Exportar y Compartir';

  @override
  String get contribution_percentages => 'Porcentajes';

  @override
  String get contribution_percentages_desc =>
      'Parte del total pagada por cada participante';

  @override
  String get export_options => 'Opciones de Exportación';

  @override
  String get welcome_v3_title => 'Organiza.\nComparte.\nLiquida.\n ';

  @override
  String get good_morning => 'Buenos días';

  @override
  String get good_afternoon => 'Buenas tardes';

  @override
  String get good_evening => 'Buenas noches';

  @override
  String get your_groups => 'Tus grupos';

  @override
  String get no_active_groups => 'No hay grupos activos';

  @override
  String get no_active_groups_subtitle => 'Crea un grupo de gastos';

  @override
  String get create_first_group => 'Crear un grupo';

  @override
  String get new_expense_group => 'Nuevo Grupo de Gastos';

  @override
  String get new_expense => 'New Expense';

  @override
  String get edit_expense => 'Editar gasto';

  @override
  String get tap_to_create => 'Tocar para crear';

  @override
  String get no_expense_label => 'No se encontraron gastos';

  @override
  String get image => 'Imagen';

  @override
  String get select_image => 'Seleccionar Imagen';

  @override
  String get change_image => 'Cambiar Imagen';

  @override
  String get from_gallery => 'Desde Galería';

  @override
  String get from_camera => 'Desde Cámara';

  @override
  String get remove_image => 'Eliminar Imagen';

  @override
  String get cannot_delete_assigned_participant =>
      'No se puede eliminar el participante: está asignado a uno o más gastos';

  @override
  String get cannot_delete_assigned_category =>
      'No se puede eliminar la categoría: está asignada a uno o más gastos';

  @override
  String get color => 'Color';

  @override
  String get remove_color => 'Eliminar Color';

  @override
  String get color_alternative => 'Alternativa a imagen';

  @override
  String get background => 'Fondo';

  @override
  String get select_background => 'Seleccionar Fondo';

  @override
  String get background_options => 'Opciones de Fondo';

  @override
  String get choose_image_or_color => 'Elige imagen o color';

  @override
  String get participants_description => 'Personas que comparten costos';

  @override
  String get categories_description => 'Agrupar gastos por tipo';

  @override
  String get dates_description => 'Inicio y fin opcionales';

  @override
  String get select_period => 'Select period';

  @override
  String get select_period_dates => 'Select the period dates';

  @override
  String duration_days(int days) {
    return '$days days';
  }

  @override
  String period_from_to(String start, String end, int days) {
    return 'From $start to $end ($days days)';
  }

  @override
  String period_from_select_end(String start) {
    return 'From $start - Select end';
  }

  @override
  String period_to_select_start(String end) {
    return 'To $end - Select start';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get clear => 'Clear';

  @override
  String get currency_description => 'Moneda base para el grupo';

  @override
  String get background_color_selected => 'Color seleccionado';

  @override
  String get background_tap_to_replace => 'Tocar para reemplazar';

  @override
  String get background_tap_to_change => 'Tocar para cambiar';

  @override
  String get background_select_image_or_color => 'Seleccionar imagen o color';

  @override
  String get background_random_color => 'Color aleatorio';

  @override
  String get background_remove => 'Eliminar fondo';

  @override
  String get crop_image_title => 'Recortar imagen';

  @override
  String get crop_confirm => 'Confirmar';

  @override
  String get saving => 'Guardando...';

  @override
  String get processing_image => 'Procesando imagen...';

  @override
  String get no_trips_found => '¿A dónde quieres ir?';

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
  String get last_7_days => '7 días';

  @override
  String get recent_activity => 'Actividad reciente';

  @override
  String get about => 'Acerca de';

  @override
  String get license_hint => 'Esta aplicación se distribuye bajo licencia MIT.';

  @override
  String get license_link => 'Ver licencia MIT en GitHub';

  @override
  String get license_section => 'Licencia';

  @override
  String get add_trip => 'Agregar grupo';

  @override
  String get new_group => 'Nuevo Grupo';

  @override
  String get group => 'Group';

  @override
  String get create => 'Crear';

  @override
  String get group_name => 'Nombre';

  @override
  String get enter_title => 'Introducir un nombre';

  @override
  String get enter_participant => 'Introducir al menos un participante';

  @override
  String get select_start => 'Seleccionar inicio';

  @override
  String get select_end => 'Seleccionar fin';

  @override
  String get start_date_not_selected => 'Seleccionar inicio';

  @override
  String get end_date_not_selected => 'Seleccionar fin';

  @override
  String get select_from_date => 'Seleccionar desde';

  @override
  String get select_to_date => 'Seleccionar hasta';

  @override
  String get date_range_not_selected => 'Seleccionar período';

  @override
  String get date_range_partial => 'Seleccionar ambas fechas';

  @override
  String get save => 'Guardar';

  @override
  String get delete_trip => 'Eliminar viaje';

  @override
  String get delete_trip_confirm =>
      '¿Estás seguro de que quieres eliminar este viaje?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String from_to(Object end, Object start) {
    return '$start - $end';
  }

  @override
  String get add_expense => 'Nuevo gasto';

  @override
  String get expand_form => 'Expandir formulario';

  @override
  String get expand_form_tooltip => 'Agregar fecha, ubicación y notas';

  @override
  String get category => 'Categoría';

  @override
  String get amount => 'Cantidad';

  @override
  String get invalid_amount => 'Cantidad inválida';

  @override
  String get no_categories => 'Sin categorías';

  @override
  String get add_category => 'Agregar categoría';

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
  String get select_both_dates_or_none =>
      'Selecciona ambas fechas o deja ambas vacías';

  @override
  String get end_date_after_start =>
      'La fecha de fin debe ser posterior a la de inicio';

  @override
  String get start_date_optional => 'Desde';

  @override
  String get end_date_optional => 'Hasta';

  @override
  String get dates => 'Período';

  @override
  String get expenses_by_participant => 'Por participante';

  @override
  String get expenses_by_category => 'Por categoría';

  @override
  String get uncategorized => 'Sin categoría';

  @override
  String get backup => 'Respaldo';

  @override
  String get no_trips_to_backup => 'No hay viajes para respaldar';

  @override
  String get backup_error => 'Error en el respaldo';

  @override
  String get backup_share_message => 'Aquí está tu respaldo de Caravella';

  @override
  String get import => 'Importar';

  @override
  String get import_confirm_title => 'Importar datos';

  @override
  String import_confirm_message(Object file) {
    return '¿Estás seguro de que quieres sobrescribir todos los viajes con el archivo \"$file\"? Esta acción no se puede deshacer.';
  }

  @override
  String get import_success => '¡Importación exitosa! Datos recargados.';

  @override
  String get import_error =>
      'Importación fallida. Verifica el formato del archivo.';

  @override
  String get categories => 'Categorías';

  @override
  String get other_settings => 'Otras configuraciones';

  @override
  String get other_settings_desc => 'Moneda, fondo y ubicación automática';

  @override
  String get segment_general => 'General';

  @override
  String get segment_other => 'Otro';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get add => 'Agregar';

  @override
  String get participant_name => 'Nombre del participante';

  @override
  String get participant_name_hint => 'Introducir nombre del participante';

  @override
  String get edit_participant => 'Editar participante';

  @override
  String get delete_participant => 'Eliminar participante';

  @override
  String get add_participant => 'Agregar participante';

  @override
  String get no_participants => 'Sin participantes';

  @override
  String get category_name_hint => 'Introducir nombre de la categoría';

  @override
  String get edit_category => 'Editar categoría';

  @override
  String get delete_category => 'Eliminar categoría';

  @override
  String participant_name_semantics(Object name) {
    return 'Participante: $name';
  }

  @override
  String category_name_semantics(Object name) {
    return 'Categoría: $name';
  }

  @override
  String get currency => 'Moneda';

  @override
  String get settings_tab => 'Configuración';

  @override
  String get basic_info => 'Información Básica';

  @override
  String get settings => 'Configuración';

  @override
  String get history => 'Historial';

  @override
  String get all => 'TODOS';

  @override
  String get search_groups => 'Buscar grupos...';

  @override
  String get no_search_results => 'No se encontraron grupos para';

  @override
  String get try_different_search => 'Intenta buscar con palabras diferentes';

  @override
  String get active => 'Activo';

  @override
  String get archived => 'Archivado';

  @override
  String get archive => 'Archivar';

  @override
  String get unarchive => 'Desarchivar';

  @override
  String get pin => 'Favorito';

  @override
  String get unpin => 'Desfavorito';

  @override
  String get delete => 'Eliminar';

  @override
  String get undo => 'DESHACER';

  @override
  String get archived_with_undo => 'Archivado';

  @override
  String get unarchived_with_undo => 'Desarchivado';

  @override
  String get pinned_with_undo => 'Marcado como favorito';

  @override
  String get unpinned_with_undo => 'Favorito quitado';

  @override
  String get deleted_with_undo => 'Eliminado';

  @override
  String get archive_confirm => '¿Quieres archivar';

  @override
  String get unarchive_confirm => '¿Quieres desarchivar';

  @override
  String get overview => 'Resumen';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get period => 'Período';

  @override
  String get total_expenses => 'Total de gastos';

  @override
  String get number_of_expenses => 'Número de gastos';

  @override
  String get options => 'Opciones';

  @override
  String get show_overview => 'Mostrar resumen';

  @override
  String get show_statistics => 'Mostrar estadísticas';

  @override
  String get no_expenses_to_display => 'No hay gastos para mostrar';

  @override
  String get no_expenses_to_analyze => 'No hay gastos para analizar';

  @override
  String get select_expense_date => 'Seleccionar fecha del gasto';

  @override
  String get select_expense_date_short => 'Seleccionar fecha';

  @override
  String get date => 'Fecha';

  @override
  String get edit_group => 'Editar Grupo';

  @override
  String get edit_group_desc =>
      'Modifica la configuración, participantes y categorías del grupo';

  @override
  String get new_group_desc =>
      'Crea un nuevo grupo de gastos con configuración personalizada';

  @override
  String get delete_group => 'Eliminar grupo';

  @override
  String get delete_group_confirm =>
      '¿Estás seguro de que quieres eliminar este grupo de gastos? Esta acción no se puede deshacer.';

  @override
  String get add_expense_fab => 'Agregar Gasto';

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
  String get developed_by => 'Desarrollado por calca';

  @override
  String get links => 'Enlaces';

  @override
  String get daily_expenses_chart => 'Gastos diarios';

  @override
  String get weekly_expenses_chart => 'Gastos semanales';

  @override
  String get daily_average_by_category => 'Promedio diario por categoría';

  @override
  String get per_day => '/día';

  @override
  String get no_expenses_for_statistics =>
      'No hay gastos disponibles para estadísticas';

  @override
  String get settlement => 'Liquidación';

  @override
  String get all_balanced => '¡Todas las cuentas están equilibradas!';

  @override
  String get owes_to => ' debe a ';

  @override
  String get export_csv => 'Exportar CSV';

  @override
  String get no_expenses_to_export => 'No hay gastos para exportar';

  @override
  String get export_csv_share_text => 'Gastos exportados desde ';

  @override
  String get export_csv_error => 'Error exportando gastos';

  @override
  String get expense_name => 'Descripción';

  @override
  String get paid_by => 'Pagado por';

  @override
  String get expense_added_success => 'Gasto agregado';

  @override
  String get expense_updated_success => 'Gasto actualizado';

  @override
  String get data_refreshing => 'Actualizando…';

  @override
  String get data_refreshed => 'Actualizado';

  @override
  String get refresh => 'Actualizar';

  @override
  String get group_added_success => 'Grupo agregado';

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
  String get enter_location_manually => 'Ingresar manualmente';

  @override
  String get location_permission_denied => 'Permiso de ubicación denegado';

  @override
  String get location_service_disabled => 'Servicio de ubicación deshabilitado';

  @override
  String get getting_location => 'Obteniendo ubicación...';

  @override
  String get location_error => 'Error obteniendo ubicación';

  @override
  String get resolving_address => 'Resolviendo dirección…';

  @override
  String get address_resolved => 'Dirección resuelta';

  @override
  String get search_place => 'Buscar lugar';

  @override
  String get search_place_hint => 'Buscar un lugar o dirección';

  @override
  String get settings_general => 'General';

  @override
  String get settings_general_desc => 'Configuración de idioma y apariencia';

  @override
  String get settings_auto_location_section => 'Detección de ubicación';

  @override
  String get settings_auto_location_section_desc =>
      'Configurar la detección automática de ubicación';

  @override
  String get settings_auto_location_title => 'Activar para detectar';

  @override
  String get settings_auto_location_desc => 'Detectar GPS al agregar un gasto';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_language_desc => 'Elige tu idioma preferido';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglés';

  @override
  String get settings_language_es => 'Español';

  @override
  String get settings_language_pt => 'Portugués';

  @override
  String get settings_language_zh => 'Chino (Simplificado)';

  @override
  String get settings_select_language => 'Seleccionar idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_theme_desc => 'Claro, oscuro o sistema';

  @override
  String get settings_select_theme => 'Seleccionar tema';

  @override
  String get settings_dynamic_color => 'Color dinámico';

  @override
  String get settings_dynamic_color_desc =>
      'Usar colores del fondo de pantalla';

  @override
  String get settings_privacy_desc => 'Opciones seguridad y privacidad';

  @override
  String get settings_data => 'Datos';

  @override
  String get settings_data_desc => 'Administra tu información';

  @override
  String get settings_data_manage => 'Gestión de datos';

  @override
  String get settings_info => 'Información';

  @override
  String get settings_info_desc => 'Detalles app y soporte';

  @override
  String get settings_app_version => 'Versión de la aplicación';

  @override
  String get settings_info_card => 'Información';

  @override
  String get settings_info_card_desc =>
      'Desarrollador, Código fuente y Licencia';

  @override
  String get terms_github_title => 'Sitio web: calca';

  @override
  String get terms_github_desc => 'Sitio web personal del desarrollador.';

  @override
  String get terms_repo_title => 'Repositorio GitHub';

  @override
  String get terms_repo_desc => 'Código fuente de la aplicación.';

  @override
  String get terms_issue_title => 'Reportar un problema';

  @override
  String get terms_issue_desc => 'Ir a la página de issues en GitHub.';

  @override
  String get terms_license_desc => 'Ver la licencia de código abierto.';

  @override
  String get support_developer_title => 'Cómprame un café';

  @override
  String get support_developer_desc =>
      'Apoya el desarrollo de esta aplicación.';

  @override
  String get data_title => 'Respaldo y Restauración';

  @override
  String get data_backup_title => 'Respaldo';

  @override
  String get data_backup_desc => 'Crear un archivo de respaldo de tus gastos.';

  @override
  String get data_restore_title => 'Restauración';

  @override
  String get data_restore_desc =>
      'Importar un respaldo para restaurar tus datos.';

  @override
  String get auto_backup_title => 'Respaldo automático';

  @override
  String get auto_backup_desc =>
      'Habilitar el respaldo automático del sistema operativo';

  @override
  String get settings_user_name_title => 'Tu nombre';

  @override
  String get settings_user_name_desc => 'Nombre o apodo para usar en la app';

  @override
  String get settings_user_name_hint => 'Ingresa tu nombre';

  @override
  String get info_tab => 'Info';

  @override
  String get select_paid_by => 'Seleccionar pagador';

  @override
  String get select_category => 'Seleccionar una categoría';

  @override
  String get check_form => 'Verificar los datos ingresados';

  @override
  String get delete_expense => 'Eliminar gasto';

  @override
  String get delete_expense_confirm =>
      '¿Estás seguro de que quieres eliminar este gasto?';

  @override
  String get no_results_found => 'No se encontraron resultados.';

  @override
  String get try_adjust_filter_or_search =>
      'Intenta ajustar el filtro o la búsqueda.';

  @override
  String get general_statistics => 'Estadísticas generales';

  @override
  String get add_first_expense => 'Agrega el primer gasto para empezar';

  @override
  String get overview_and_statistics => 'Resumen y estadísticas';

  @override
  String get daily_average => 'Diario';

  @override
  String get spent_today => 'Hoy';

  @override
  String get monthly_average => 'Mensual';

  @override
  String get average_expense => 'Gasto promedio';

  @override
  String get welcome_v3_cta => '¡Empezar!';

  @override
  String get discard_changes_title => '¿Descartar cambios?';

  @override
  String get discard_changes_message =>
      '¿Estás seguro de que quieres descartar los cambios no guardados?';

  @override
  String get discard => 'Descartar';

  @override
  String get category_placeholder => 'Categoría';

  @override
  String get image_requirements => 'PNG, JPG, GIF (máx 10MB)';

  @override
  String error_saving_group(Object error) {
    return 'Error guardando: $error';
  }

  @override
  String get error_selecting_image => 'Error seleccionando imagen';

  @override
  String get error_saving_image => 'Error guardando imagen';

  @override
  String get already_exists => 'ya existe';

  @override
  String get status_all => 'Todos';

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
      'Todos tus grupos están archivados. Puedes restaurarlos desde la sección Archivo o crear otros nuevos.';

  @override
  String get filter_status_tooltip => 'Filtrar grupos';

  @override
  String get welcome_logo_semantic => 'Logo de la aplicación Caravella';

  @override
  String get create_new_group => 'Crear nuevo grupo';

  @override
  String get accessibility_add_new_item => 'Agregar nuevo elemento';

  @override
  String get accessibility_navigation_bar => 'Barra de navegación';

  @override
  String get accessibility_back_button => 'Atrás';

  @override
  String get accessibility_loading_groups => 'Cargando grupos';

  @override
  String get accessibility_loading_your_groups => 'Cargando tus grupos';

  @override
  String get accessibility_groups_list => 'Lista de grupos';

  @override
  String get accessibility_welcome_screen => 'Pantalla de bienvenida';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Gastos totales: $amount€';
  }

  @override
  String get accessibility_add_expense => 'Agregar gasto';

  @override
  String accessibility_security_switch(Object state) {
    return 'Interruptor de seguridad - $state';
  }

  @override
  String get accessibility_switch_on => 'Activado';

  @override
  String get accessibility_switch_off => 'Desactivado';

  @override
  String get accessibility_image_source_dialog =>
      'Diálogo de selección de fuente de imagen';

  @override
  String get accessibility_currently_enabled => 'Actualmente habilitado';

  @override
  String get accessibility_currently_disabled => 'Actualmente deshabilitado';

  @override
  String get accessibility_double_tap_disable =>
      'Doble toque para deshabilitar la seguridad de pantalla';

  @override
  String get accessibility_double_tap_enable =>
      'Doble toque para habilitar la seguridad de pantalla';

  @override
  String get accessibility_toast_success => 'Éxito';

  @override
  String get accessibility_toast_error => 'Error';

  @override
  String get accessibility_toast_info => 'Información';

  @override
  String get color_suggested_title => 'Colores sugeridos';

  @override
  String get color_suggested_subtitle =>
      'Elige uno de los colores compatibles con el tema';

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
  String get search_currency => 'Buscar moneda...';

  @override
  String get activity => 'Gastos';

  @override
  String get search_expenses_hint => 'Buscar por nombre o nota...';

  @override
  String get clear_filters => 'Limpiar';

  @override
  String get show_filters => 'Mostrar filtros';

  @override
  String get hide_filters => 'Ocultar filtros';

  @override
  String get all_categories => 'Todas';

  @override
  String get all_participants => 'Todos';

  @override
  String get no_expenses_with_filters =>
      'Ningún gasto coincide con los filtros seleccionados';

  @override
  String get no_expenses_yet => 'Aún no hay gastos';

  @override
  String get empty_expenses_title => '¿Listo para empezar?';

  @override
  String get empty_expenses_subtitle =>
      '¡Agrega tu primer gasto para comenzar con este grupo!';

  @override
  String get add_first_expense_button => 'Agregar Primer Gasto';

  @override
  String get show_search => 'Mostrar barra de búsqueda';

  @override
  String get hide_search => 'Ocultar barra de búsqueda';

  @override
  String get expense_groups_title => 'Grupos de gastos';

  @override
  String get expense_groups_desc => 'Gestiona tus grupos de gastos';

  @override
  String get whats_new_title => 'Novedades';

  @override
  String get whats_new_desc =>
      'Descubre las últimas características y actualizaciones';

  @override
  String get whats_new_subtitle => 'Lo más destacado reciente';

  @override
  String get whats_new_latest =>
      'Mantente al día con las mejoras más recientes';

  @override
  String get changelog_title => 'Registro de cambios';

  @override
  String get changelog_desc => 'Historial de versiones y mejoras';

  @override
  String get average_per_person => 'Promedio por persona';

  @override
  String get more => 'más';

  @override
  String get less => 'menos';

  @override
  String get debt_prefix_to => 'a ';

  @override
  String get view_on_map => 'Ver en el mapa';

  @override
  String get expenses_map => 'Mapa de Gastos';

  @override
  String get no_locations_available => 'No hay ubicaciones disponibles';

  @override
  String get no_locations_subtitle =>
      'Agrega datos de ubicación a tus gastos para verlos en el mapa';

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
  String get check_for_updates_desc =>
      'Verificar disponibilidad de nueva versión';

  @override
  String get update_available => 'Actualización disponible';

  @override
  String get update_available_desc =>
      'Una nueva versión de la app está disponible';

  @override
  String get no_update_available => 'App actualizada';

  @override
  String get no_update_available_desc => 'Estás usando la última versión';

  @override
  String get update_now => 'Actualizar ahora';

  @override
  String get update_later => 'Más tarde';

  @override
  String get checking_for_updates => 'Verificando actualizaciones...';

  @override
  String get update_error => 'Error al verificar actualizaciones';

  @override
  String get update_downloading => 'Descargando...';

  @override
  String get update_installing => 'Instalando...';

  @override
  String get update_feature_android_only =>
      'Función disponible solo en Android con Google Play Store';

  @override
  String get update_recommendation_title => 'Actualización recomendada';

  @override
  String get update_recommendation_desc =>
      'Una nueva versión de Caravella está disponible. ¡Actualiza la app para tener siempre las últimas funciones y mejoras!';

  @override
  String get update_install => 'Instalar actualización';

  @override
  String get update_remind_later => 'Recuérdamelo después';

  @override
  String get send_reminder => 'Enviar recordatorio';

  @override
  String reminder_message_single(
    Object participantName,
    Object amount,
    Object creditorName,
    Object groupName,
  ) {
    return '¡Hola $participantName! 👋\n\nQuisiera recordarte que debes $amount a $creditorName para el grupo \"$groupName\".\n\n¡Gracias! 😊';
  }

  @override
  String reminder_message_multiple(
    Object participantName,
    Object groupName,
    Object debtsList,
  ) {
    return '¡Hola $participantName! 👋\n\nQuisiera recordarte tus pagos para el grupo \"$groupName\":\n\n$debtsList\n\n¡Gracias! 😊';
  }

  @override
  String get notification_enabled => 'Notificación persistente';

  @override
  String get notification_enabled_desc =>
      'Muestra los gastos del día en una notificación siempre visible';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Gastos de hoy: $amount $currency';
  }

  @override
  String notification_total_spent(String amount, String currency) {
    return 'Total: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Añadir Gasto';

  @override
  String get notification_close => 'Cerrar';

  @override
  String get group_type => 'Tipo';

  @override
  String get group_type_description => 'Elige el tipo de grupo';

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
  String get category_other_utilities => 'Utilidades';

  @override
  String get category_other_services => 'Servicios';

  @override
  String get attachments => 'Adjuntos';

  @override
  String get add_attachment => 'Agregar adjunto';

  @override
  String get attachment_limit_reached =>
      'Límite máximo de 5 adjuntos alcanzado';

  @override
  String get delete_attachment => 'Eliminar adjunto';

  @override
  String get share_attachment => 'Compartir adjunto';

  @override
  String get delete_attachment_confirm_title => 'Eliminar adjunto';

  @override
  String get delete_attachment_confirm_message =>
      '¿Estás seguro de que deseas eliminar este adjunto?';

  @override
  String get attachment_source => 'Elegir fuente';

  @override
  String get from_files => 'Desde archivos';

  @override
  String get archived_group_readonly => 'Grupo archivado - Solo lectura';

  @override
  String get archived_group_readonly_desc =>
      'Este grupo está archivado. No puedes modificarlo ni agregar nuevos gastos.';

  @override
  String get expense_readonly => 'Gasto - Solo lectura';

  @override
  String get expense_readonly_archived =>
      'Este gasto pertenece a un grupo archivado y no se puede modificar.';

  @override
  String get expense => 'Gasto';

  @override
  String get notification_disable => 'Desactivar';
}
