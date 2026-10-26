// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get developer_section_title => 'Desenvolvedor e suporte';

  @override
  String get repo_section_title => 'Código e problemas';

  @override
  String get license_section_title => 'Licença';

  @override
  String get weeklyChartBadge => 'W';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get dateRangeChartBadge => 'D';

  @override
  String get weeklyExpensesChart => 'Despesas semanais';

  @override
  String get monthlyExpensesChart => 'Despesas mensais';

  @override
  String get dateRangeExpensesChart => 'Despesas por período';

  @override
  String get settings_flag_secure_desc => 'Bloqueia capturas e gravação';

  @override
  String get settings_flag_secure_title => 'Tela segura';

  @override
  String get settings_app_functions_title => 'Acesso de agentes de IA';

  @override
  String get settings_app_functions_desc =>
      'Usa o Gemini e outros assistentes IA';

  @override
  String get select_currency => 'Moeda';

  @override
  String days_count(int count) {
    return '$count dias';
  }

  @override
  String get weekday_mon => 'S';

  @override
  String get weekday_tue => 'T';

  @override
  String get weekday_wed => 'Q';

  @override
  String get weekday_thu => 'Q';

  @override
  String get weekday_fri => 'S';

  @override
  String get weekday_sat => 'S';

  @override
  String get weekday_sun => 'D';

  @override
  String get month_january => 'Janeiro';

  @override
  String get month_february => 'Fevereiro';

  @override
  String get month_march => 'Março';

  @override
  String get month_april => 'Abril';

  @override
  String get month_may => 'Maio';

  @override
  String get month_june => 'Junho';

  @override
  String get month_july => 'Julho';

  @override
  String get month_august => 'Agosto';

  @override
  String get month_september => 'Setembro';

  @override
  String get month_october => 'Outubro';

  @override
  String get month_november => 'Novembro';

  @override
  String get month_december => 'Dezembro';

  @override
  String get in_group_prefix => 'em';

  @override
  String get group_total => 'Total';

  @override
  String get markdown_select_directory_title =>
      'Selecionar pasta para salvar Markdown';

  @override
  String markdown_saved_in(String path) {
    return 'Markdown salvo em: $path';
  }

  @override
  String get markdown_save_cancelled => 'Exportação Markdown cancelada';

  @override
  String get markdown_save_error => 'Erro ao salvar arquivo Markdown';

  @override
  String get share_label => 'Compartilhar';

  @override
  String get export_share => 'Compartilhar e exportar';

  @override
  String get export_options => 'Exportar despesas';

  @override
  String get welcome_v3_title => 'Organize.\nCompartilhe.\nQuite.\n ';

  @override
  String get good_morning => 'Bom dia';

  @override
  String get good_afternoon => 'Boa tarde';

  @override
  String get good_evening => 'Boa noite';

  @override
  String get see_all => 'Ver todos';

  @override
  String get view_all_groups => 'Ver todos os grupos';

  @override
  String get no_active_groups => 'Nenhum grupo ativo';

  @override
  String get create_first_group => 'Criar um grupo';

  @override
  String get new_expense_group => 'Novo';

  @override
  String get new_expense => 'Nova despesa';

  @override
  String get image => 'Foto';

  @override
  String get change_image => 'Alterar foto';

  @override
  String get from_gallery => 'Da galeria';

  @override
  String get from_camera => 'Da câmera';

  @override
  String get cannot_delete_assigned_participant =>
      'Não é possível excluir o participante: ele está atribuído a uma ou mais despesas';

  @override
  String get cannot_delete_assigned_category =>
      'Não é possível excluir a categoria: ela está atribuída a uma ou mais despesas';

  @override
  String get color => 'Cor';

  @override
  String get background => 'Fundo';

  @override
  String get participants_description => 'Pessoas que dividem os custos';

  @override
  String get categories_description => 'Agrupe despesas por tipo';

  @override
  String get dates_description => 'Início e fim, opcionais';

  @override
  String get select_period => 'Período';

  @override
  String get suggested_duration => 'Duração sugerida';

  @override
  String get confirm => 'Confirmar';

  @override
  String get clear => 'Remover';

  @override
  String get background_color_selected => 'Cor selecionada';

  @override
  String get background_tap_to_replace => 'Toque para substituir';

  @override
  String get background_tap_to_change => 'Toque para alterar';

  @override
  String get background_select_image_or_color => 'Escolha uma foto ou uma cor';

  @override
  String get background_random_color => 'Cor aleatória';

  @override
  String get background_remove => 'Remover fundo';

  @override
  String get crop_image_title => 'Recorte a foto';

  @override
  String get crop_confirm => 'Confirmar';

  @override
  String get saving => 'Salvando…';

  @override
  String get expenses => 'Despesas';

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
  String get last_7_days => 'Últimos 7 dias';

  @override
  String get today => 'Hoje';

  @override
  String get this_month => 'Este mês';

  @override
  String get recent_expenses => 'Despesas recentes';

  @override
  String get license_link => 'Ver Licença MIT no GitHub';

  @override
  String get add_trip => 'Adicionar grupo';

  @override
  String get group => 'Grupo';

  @override
  String get create => 'Criar';

  @override
  String get group_name => 'Nome';

  @override
  String get enter_title => 'Digite um nome';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get add_expense => 'Nova despesa';

  @override
  String get edit_expense => 'Editar despesa';

  @override
  String get expand_form => 'Expandir formulário';

  @override
  String get expand_form_tooltip => 'Adicionar data, localização e notas';

  @override
  String get category => 'Categoria';

  @override
  String get amount => 'Valor';

  @override
  String get invalid_amount => 'Valor inválido';

  @override
  String get add_category => 'Adicionar categoria';

  @override
  String get category_name => 'Nome da categoria';

  @override
  String get note => 'Nota';

  @override
  String get note_hint => 'Nota';

  @override
  String get select_both_dates => 'Se selecionar uma data, selecione as duas';

  @override
  String get end_date_after_start => 'Data final deve ser após a inicial';

  @override
  String get expenses_by_participant => 'Por participante';

  @override
  String get expenses_by_category => 'Por categoria';

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'Nenhum grupo para salvar';

  @override
  String get backup_error => 'Falha no backup';

  @override
  String get backup_share_message => 'Aqui está o seu backup do Caravella';

  @override
  String get import_confirm_title => 'Importar dados';

  @override
  String import_confirm_message(Object file) {
    return 'Restaurar do arquivo “$file”? Os grupos atuais serão substituídos e não será possível desfazer.';
  }

  @override
  String get import_success => 'Dados restaurados';

  @override
  String get import_error => 'Não foi possível restaurar: verifique o arquivo';

  @override
  String get settings_flag_secure_error =>
      'Não foi possível alterar a proteção de tela';

  @override
  String get settings_debug_logs_title => 'Registros de depuração';

  @override
  String get settings_debug_logs_desc => 'Registos e erros da app';

  @override
  String get developer_link_error => 'Não foi possível abrir o link';

  @override
  String get whats_new_load_error => 'Não foi possível carregar as novidades';

  @override
  String get categories => 'Categorias';

  @override
  String get other_settings_desc => 'Notificação, localização';

  @override
  String get segment_general => 'Geral';

  @override
  String get segment_other => 'Outro';

  @override
  String get from => 'De';

  @override
  String get to => 'Até';

  @override
  String get add => 'Adicionar';

  @override
  String get participant_name => 'Nome do participante';

  @override
  String get edit_participant => 'Editar participante';

  @override
  String get add_participant => 'Adicionar participante';

  @override
  String get edit_category => 'Editar categoria';

  @override
  String get currency => 'Moeda';

  @override
  String get settings_tab => 'Configurações';

  @override
  String get settings => 'Configurações';

  @override
  String get history => 'Histórico';

  @override
  String get all => 'Todos';

  @override
  String get search_groups => 'Pesquisar grupos e despesas…';

  @override
  String get no_search_results => 'Nenhum resultado';

  @override
  String get try_different_search => 'Tente pesquisar com palavras diferentes';

  @override
  String get active => 'Ativo';

  @override
  String get archived => 'Arquivado';

  @override
  String get archive => 'Arquivar';

  @override
  String get unarchive => 'Tirar do arquivo';

  @override
  String get pin => 'Favorito';

  @override
  String get unpin => 'Desfavorito';

  @override
  String get archived_with_undo => 'Arquivado';

  @override
  String get unarchived_with_undo => 'Retirado do arquivo';

  @override
  String get pinned_with_undo => 'Marcado como favorito';

  @override
  String get unpinned_with_undo => 'Favorito removido';

  @override
  String get deleted_with_undo => 'Excluído';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get period => 'Período';

  @override
  String get total_expenses => 'Total de despesas';

  @override
  String get number_of_expenses => 'Número de despesas';

  @override
  String get select_expense_date => 'Selecionar data da despesa';

  @override
  String get select_expense_date_short => 'Selecionar data';

  @override
  String get date => 'Data';

  @override
  String get delete_group => 'Excluir grupo';

  @override
  String get delete_group_confirm =>
      'O grupo e todas as suas despesas serão excluídos. Não será possível desfazer.';

  @override
  String get add_expense_fab => 'Adicionar despesa';

  @override
  String get pin_group => 'Marcar como favorito';

  @override
  String get unpin_group => 'Remover favorito';

  @override
  String get theme_automatic => 'Automático';

  @override
  String get theme_light => 'Claro';

  @override
  String get theme_dark => 'Escuro';

  @override
  String get per_day => '/dia';

  @override
  String get no_expenses_for_statistics => 'Sem despesas para estatísticas';

  @override
  String get settlement => 'Acertar';

  @override
  String get all_balanced => 'Vocês estão quites';

  @override
  String get no_expenses_to_export => 'Nenhuma despesa para exportar';

  @override
  String get expense_name => 'Descrição';

  @override
  String get paid_by => 'Pago por';

  @override
  String get added_by => 'Adicionado por';

  @override
  String get edited_by => 'Editado por';

  @override
  String get expense_added_success => 'Despesa adicionada';

  @override
  String get expense_updated_success => 'Despesa atualizada';

  @override
  String get refresh => 'Atualizar';

  @override
  String get group_added_success => 'Grupo adicionado';

  @override
  String get group_deleted_success => 'Grupo excluído';

  @override
  String get csv_select_directory_title =>
      'Selecione a pasta para salvar o CSV';

  @override
  String csv_saved_in(Object path) {
    return 'CSV salvo em: $path';
  }

  @override
  String get csv_save_cancelled => 'Exportação cancelada';

  @override
  String get csv_save_error => 'Erro ao salvar arquivo CSV';

  @override
  String get ofx_select_directory_title =>
      'Selecione a pasta para salvar o OFX';

  @override
  String ofx_saved_in(Object path) {
    return 'OFX salvo em: $path';
  }

  @override
  String get ofx_save_cancelled => 'Exportação OFX cancelada';

  @override
  String get ofx_save_error => 'Erro ao salvar arquivo OFX';

  @override
  String get csv_expense_name => 'Descrição';

  @override
  String get csv_amount => 'Valor';

  @override
  String get csv_paid_by => 'Pago por';

  @override
  String get csv_category => 'Categoria';

  @override
  String get csv_date => 'Data';

  @override
  String get csv_note => 'Nota';

  @override
  String get csv_location => 'Local';

  @override
  String get location => 'Local';

  @override
  String get location_hint => 'Local';

  @override
  String get get_current_location => 'Usar localização atual';

  @override
  String get getting_location => 'Obtendo localização…';

  @override
  String get location_error => 'Não foi possível obter a localização';

  @override
  String get address_resolved => 'Endereço resolvido';

  @override
  String get settings_general => 'Geral';

  @override
  String get settings_auto_location_title => 'Localização automática';

  @override
  String get settings_auto_location_desc => 'Guarda onde fazes cada despesa';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglês';

  @override
  String get settings_language_es => 'Espanhol';

  @override
  String get settings_language_pt => 'Português';

  @override
  String get settings_language_zh => 'Chinês (simplificado)';

  @override
  String get settings_select_language => 'Idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_appearance => 'Aparência';

  @override
  String get settings_appearance_desc => 'Idioma, tema e cor dinâmica';

  @override
  String get settings_dynamic_color => 'Cor dinâmica';

  @override
  String get settings_dynamic_color_desc => 'Usar cores do papel de parede';

  @override
  String get settings_privacy => 'Privacidade';

  @override
  String get settings_data => 'Dados';

  @override
  String get settings_data_manage => 'Gerenciamento de dados';

  @override
  String get settings_info => 'Informações';

  @override
  String get settings_app_version => 'Versão do app';

  @override
  String get settings_info_card => 'Informações';

  @override
  String get settings_info_card_desc => 'Desenvolvedor, código-fonte e licença';

  @override
  String get settings_invite_friends => 'Convide seus amigos';

  @override
  String get settings_invite_friends_desc =>
      'Compartilhe o Caravella com quem quiser';

  @override
  String get invite_friends_message =>
      'Oi! Uso o Caravella para dividir as despesas em grupo com amigos, é super prático 🎒💸 Experimente também: https://play.google.com/store/apps/details?id=io.caravella.egm';

  @override
  String get terms_github_title => 'Site: calca';

  @override
  String get terms_github_desc => 'Site do programador';

  @override
  String get terms_repo_title => 'Repositório GitHub';

  @override
  String get terms_repo_desc => 'Código-fonte do app';

  @override
  String get terms_issue_title => 'Reportar um problema';

  @override
  String get terms_issue_desc => 'Reporta um problema no GitHub';

  @override
  String get terms_license_desc => 'Licença open source MIT';

  @override
  String get support_developer_title => 'Pague um café';

  @override
  String get support_developer_desc => 'Apoie o desenvolvimento do app';

  @override
  String get data_title => 'Backup e restauração';

  @override
  String get data_backup_desc => 'Guarda as despesas num ficheiro';

  @override
  String get data_restore_title => 'Restaurar';

  @override
  String get data_restore_desc => 'A partir de um ficheiro';

  @override
  String get auto_backup_title => 'Backup automático';

  @override
  String get auto_backup_desc => 'Backup do sistema operativo';

  @override
  String get settings_user_name_title => 'Seu nome';

  @override
  String get settings_user_name_desc => 'O teu nome na app';

  @override
  String get settings_user_name_hint => 'Insira seu nome';

  @override
  String get default_participant_me => 'Eu';

  @override
  String get select_category => 'Categoria';

  @override
  String get delete_expense => 'Excluir despesa';

  @override
  String get delete_expense_confirm =>
      'A despesa será excluída. Não será possível desfazer.';

  @override
  String get delete => 'Excluir';

  @override
  String get spent_today => 'Hoje';

  @override
  String get welcome_v3_cta => 'Começar';

  @override
  String get discard_changes_title => 'Sair sem salvar?';

  @override
  String get discard_changes_message =>
      'As alterações que você não salvou serão perdidas.';

  @override
  String get discard => 'Descartar';

  @override
  String error_saving_group(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get already_exists => 'já existe';

  @override
  String get status_active => 'Ativos';

  @override
  String get status_archived => 'Arquivados';

  @override
  String get no_archived_groups => 'Nenhum grupo arquivado';

  @override
  String get no_archived_groups_subtitle =>
      'Toque e segure um grupo e escolha Arquivar: ele aparece aqui.';

  @override
  String get all_groups_archived_info =>
      'Todos os seus grupos estão no arquivo. Você pode recuperá-los de lá ou criar um novo.';

  @override
  String get welcome_logo_semantic => 'Logo do app Caravella';

  @override
  String get create_new_group => 'Criar novo grupo';

  @override
  String get accessibility_back_button => 'Voltar';

  @override
  String get accessibility_groups_list => 'Lista de grupos';

  @override
  String get accessibility_welcome_screen => 'Tela de boas-vindas';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Despesas totais: $amount';
  }

  @override
  String get accessibility_add_expense => 'Adicionar despesa';

  @override
  String get accessibility_currently_disabled => 'Atualmente desativado';

  @override
  String get accessibility_previous_month => 'Mês anterior';

  @override
  String get accessibility_next_month => 'Próximo mês';

  @override
  String get color_suggested_title => 'Cores sugeridas';

  @override
  String get color_suggested_subtitle =>
      'Tons suaves que se adaptam ao tema claro e escuro';

  @override
  String get color_random_subtitle => 'Deixe o app escolher uma cor';

  @override
  String get currency_AED => 'United Arab Emirates Dirham';

  @override
  String get currency_AFN => 'Afghan Afghani';

  @override
  String get currency_ALL => 'Albanian Lek';

  @override
  String get currency_AMD => 'Armenian Dram';

  @override
  String get currency_ANG => 'Netherlands Antillean Guilder';

  @override
  String get currency_AOA => 'Angolan Kwanza';

  @override
  String get currency_ARS => 'Argentine Peso';

  @override
  String get currency_AUD => 'Australian Dollar';

  @override
  String get currency_AWG => 'Aruban Florin';

  @override
  String get currency_AZN => 'Azerbaijani Manat';

  @override
  String get currency_BAM => 'Bosnia and Herzegovina Convertible Mark';

  @override
  String get currency_BBD => 'Barbadian Dollar';

  @override
  String get currency_BDT => 'Bangladeshi Taka';

  @override
  String get currency_BGN => 'Bulgarian Lev';

  @override
  String get currency_BHD => 'Bahraini Dinar';

  @override
  String get currency_BIF => 'Burundian Franc';

  @override
  String get currency_BMD => 'Bermudian Dollar';

  @override
  String get currency_BND => 'Brunei Dollar';

  @override
  String get currency_BOB => 'Bolivian Boliviano';

  @override
  String get currency_BRL => 'Brazilian Real';

  @override
  String get currency_BSD => 'Bahamian Dollar';

  @override
  String get currency_BTN => 'Bhutanese Ngultrum';

  @override
  String get currency_BWP => 'Botswana Pula';

  @override
  String get currency_BYN => 'Belarusian Ruble';

  @override
  String get currency_BZD => 'Belize Dollar';

  @override
  String get currency_CAD => 'Canadian Dollar';

  @override
  String get currency_CDF => 'Congolese Franc';

  @override
  String get currency_CHF => 'Swiss Franc';

  @override
  String get currency_CLP => 'Chilean Peso';

  @override
  String get currency_CNY => 'Chinese Yuan';

  @override
  String get currency_COP => 'Colombian Peso';

  @override
  String get currency_CRC => 'Costa Rican Colón';

  @override
  String get currency_CUP => 'Cuban Peso';

  @override
  String get currency_CVE => 'Cape Verdean Escudo';

  @override
  String get currency_CZK => 'Czech Koruna';

  @override
  String get currency_DJF => 'Djiboutian Franc';

  @override
  String get currency_DKK => 'Danish Krone';

  @override
  String get currency_DOP => 'Dominican Peso';

  @override
  String get currency_DZD => 'Algerian Dinar';

  @override
  String get currency_EGP => 'Egyptian Pound';

  @override
  String get currency_ERN => 'Eritrean Nakfa';

  @override
  String get currency_ETB => 'Ethiopian Birr';

  @override
  String get currency_EUR => 'Euro';

  @override
  String get currency_FJD => 'Fiji Dollar';

  @override
  String get currency_FKP => 'Falkland Islands Pound';

  @override
  String get currency_GBP => 'Pound Sterling';

  @override
  String get currency_GEL => 'Georgian Lari';

  @override
  String get currency_GHS => 'Ghanaian Cedi';

  @override
  String get currency_GIP => 'Gibraltar Pound';

  @override
  String get currency_GMD => 'Gambian Dalasi';

  @override
  String get currency_GNF => 'Guinean Franc';

  @override
  String get currency_GTQ => 'Guatemalan Quetzal';

  @override
  String get currency_GYD => 'Guyanese Dollar';

  @override
  String get currency_HKD => 'Hong Kong Dollar';

  @override
  String get currency_HNL => 'Honduran Lempira';

  @override
  String get currency_HTG => 'Haitian Gourde';

  @override
  String get currency_HUF => 'Hungarian Forint';

  @override
  String get currency_IDR => 'Indonesian Rupiah';

  @override
  String get currency_ILS => 'Israeli New Shekel';

  @override
  String get currency_INR => 'Indian Rupee';

  @override
  String get currency_IQD => 'Iraqi Dinar';

  @override
  String get currency_IRR => 'Iranian Rial';

  @override
  String get currency_ISK => 'Icelandic Króna';

  @override
  String get currency_JMD => 'Jamaican Dollar';

  @override
  String get currency_JOD => 'Jordanian Dinar';

  @override
  String get currency_JPY => 'Japanese Yen';

  @override
  String get currency_KES => 'Kenyan Shilling';

  @override
  String get currency_KGS => 'Kyrgyzstani Som';

  @override
  String get currency_KHR => 'Cambodian Riel';

  @override
  String get currency_KID => 'Kiribati Dollar';

  @override
  String get currency_KMF => 'Comorian Franc';

  @override
  String get currency_KPW => 'North Korean Won';

  @override
  String get currency_KRW => 'South Korean Won';

  @override
  String get currency_KWD => 'Kuwaiti Dinar';

  @override
  String get currency_KYD => 'Cayman Islands Dollar';

  @override
  String get currency_KZT => 'Kazakhstani Tenge';

  @override
  String get currency_LAK => 'Lao Kip';

  @override
  String get currency_LBP => 'Lebanese Pound';

  @override
  String get currency_LKR => 'Sri Lankan Rupee';

  @override
  String get currency_LRD => 'Liberian Dollar';

  @override
  String get currency_LSL => 'Lesotho Loti';

  @override
  String get currency_LYD => 'Libyan Dinar';

  @override
  String get currency_MAD => 'Moroccan Dirham';

  @override
  String get currency_MDL => 'Moldovan Leu';

  @override
  String get currency_MGA => 'Malagasy Ariary';

  @override
  String get currency_MKD => 'Macedonian Denar';

  @override
  String get currency_MMK => 'Myanmar Kyat';

  @override
  String get currency_MNT => 'Mongolian Tögrög';

  @override
  String get currency_MOP => 'Macanese Pataca';

  @override
  String get currency_MRU => 'Mauritanian Ouguiya';

  @override
  String get currency_MUR => 'Mauritian Rupee';

  @override
  String get currency_MVR => 'Maldivian Rufiyaa';

  @override
  String get currency_MWK => 'Malawian Kwacha';

  @override
  String get currency_MXN => 'Mexican Peso';

  @override
  String get currency_MYR => 'Malaysian Ringgit';

  @override
  String get currency_MZN => 'Mozambican Metical';

  @override
  String get currency_NAD => 'Namibian Dollar';

  @override
  String get currency_NGN => 'Nigerian Naira';

  @override
  String get currency_NIO => 'Nicaraguan Córdoba';

  @override
  String get currency_NOK => 'Norwegian Krone';

  @override
  String get currency_NPR => 'Nepalese Rupee';

  @override
  String get currency_NZD => 'New Zealand Dollar';

  @override
  String get currency_OMR => 'Omani Rial';

  @override
  String get currency_PAB => 'Panamanian Balboa';

  @override
  String get currency_PEN => 'Peruvian Sol';

  @override
  String get currency_PGK => 'Papua New Guinean Kina';

  @override
  String get currency_PHP => 'Philippine Peso';

  @override
  String get currency_PKR => 'Pakistani Rupee';

  @override
  String get currency_PLN => 'Polish Zloty';

  @override
  String get currency_PYG => 'Paraguayan Guaraní';

  @override
  String get currency_QAR => 'Qatari Riyal';

  @override
  String get currency_RON => 'Romanian Leu';

  @override
  String get currency_RSD => 'Serbian Dinar';

  @override
  String get currency_RUB => 'Russian Ruble';

  @override
  String get currency_RWF => 'Rwandan Franc';

  @override
  String get currency_SAR => 'Saudi Riyal';

  @override
  String get currency_SBD => 'Solomon Islands Dollar';

  @override
  String get currency_SCR => 'Seychellois Rupee';

  @override
  String get currency_SDG => 'Sudanese Pound';

  @override
  String get currency_SEK => 'Swedish Krona';

  @override
  String get currency_SGD => 'Singapore Dollar';

  @override
  String get currency_SHP => 'Saint Helena Pound';

  @override
  String get currency_SLE => 'Sierra Leonean Leone (new)';

  @override
  String get currency_SLL => 'Sierra Leonean Leone (old)';

  @override
  String get currency_SOS => 'Somali Shilling';

  @override
  String get currency_SRD => 'Surinamese Dollar';

  @override
  String get currency_SSP => 'South Sudanese Pound';

  @override
  String get currency_STN => 'São Tomé and Príncipe Dobra';

  @override
  String get currency_SVC => 'Salvadoran Colón (historic)';

  @override
  String get currency_SYP => 'Syrian Pound';

  @override
  String get currency_SZL => 'Eswatini Lilangeni';

  @override
  String get currency_THB => 'Thai Baht';

  @override
  String get currency_TJS => 'Tajikistani Somoni';

  @override
  String get currency_TMT => 'Turkmenistan Manat';

  @override
  String get currency_TND => 'Tunisian Dinar';

  @override
  String get currency_TOP => 'Tongan Paʻanga';

  @override
  String get currency_TRY => 'Turkish Lira';

  @override
  String get currency_TTD => 'Trinidad and Tobago Dollar';

  @override
  String get currency_TVD => 'Tuvaluan Dollar';

  @override
  String get currency_TWD => 'New Taiwan Dollar';

  @override
  String get currency_TZS => 'Tanzanian Shilling';

  @override
  String get currency_UAH => 'Ukrainian Hryvnia';

  @override
  String get currency_UGX => 'Ugandan Shilling';

  @override
  String get currency_USD => 'United States Dollar';

  @override
  String get currency_UYU => 'Uruguayan Peso';

  @override
  String get currency_UZS => 'Uzbekistani So\'m';

  @override
  String get currency_VED => 'Venezuelan Digital Bolívar';

  @override
  String get currency_VES => 'Venezuelan Bolívar';

  @override
  String get currency_VND => 'Vietnamese Đồng';

  @override
  String get currency_VUV => 'Vanuatu Vatu';

  @override
  String get currency_WST => 'Samoan Tala';

  @override
  String get currency_XAF => 'CFA Franc BEAC';

  @override
  String get currency_XOF => 'CFA Franc BCEAO';

  @override
  String get currency_XPF => 'CFP Franc';

  @override
  String get currency_YER => 'Yemeni Rial';

  @override
  String get currency_ZAR => 'South African Rand';

  @override
  String get currency_ZMW => 'Zambian Kwacha';

  @override
  String get currency_ZWL => 'Zimbabwean Dollar';

  @override
  String get search_currency => 'Pesquisar moeda…';

  @override
  String get clear_filters => 'Redefinir';

  @override
  String get filters => 'Filtros';

  @override
  String get empty_expenses_title => 'Ainda não há despesas';

  @override
  String get empty_expenses_subtitle =>
      'Adicione a primeira: você a encontrará aqui.';

  @override
  String get add_first_expense_button => 'Adicionar despesa';

  @override
  String get show_search => 'Mostrar barra de pesquisa';

  @override
  String get whats_new_title => 'Novidades';

  @override
  String get changelog_title => 'Histórico de versões';

  @override
  String get expenses_map => 'Mapa das despesas';

  @override
  String get no_locations_available => 'Nenhum lugar';

  @override
  String get no_locations_subtitle =>
      'Adicione um lugar às despesas para vê-las no mapa';

  @override
  String expense_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despesas',
      one: '1 despesa',
    );
    return '$_temp0';
  }

  @override
  String get check_for_updates => 'Verificar atualizações';

  @override
  String get check_for_updates_desc => 'Procura uma nova versão';

  @override
  String get update_available => 'Atualização disponível';

  @override
  String get update_available_desc =>
      'Uma nova versão do aplicativo está disponível';

  @override
  String get no_update_available => 'App atualizado';

  @override
  String get update_now => 'Atualizar agora';

  @override
  String get update_later => 'Mais tarde';

  @override
  String get checking_for_updates => 'Verificando atualizações…';

  @override
  String get update_error => 'Não foi possível verificar atualizações';

  @override
  String get update_downloading => 'Baixando…';

  @override
  String get update_ready_to_install => 'Atualização pronta para instalar';

  @override
  String get update_ready_to_install_desc =>
      'O download foi concluído. Instale para concluir a atualização.';

  @override
  String get update_installing => 'Instalando…';

  @override
  String get update_install => 'Instalar atualização';

  @override
  String get send_reminder => 'Enviar lembrete';

  @override
  String get notification_enabled_desc => 'Despesas de hoje numa notificação';

  @override
  String get group_type => 'Tipo';

  @override
  String get group_type_travel => 'Viagem';

  @override
  String get group_type_personal => 'Pessoal';

  @override
  String get group_type_family => 'Família';

  @override
  String get group_type_other => 'Outro';

  @override
  String get category_travel_transport => 'Transporte';

  @override
  String get category_travel_accommodation => 'Acomodação';

  @override
  String get category_travel_restaurants => 'Restaurantes';

  @override
  String get category_personal_shopping => 'Compras';

  @override
  String get category_personal_health => 'Saúde';

  @override
  String get category_personal_entertainment => 'Entretenimento';

  @override
  String get category_family_groceries => 'Supermercado';

  @override
  String get category_family_home => 'Casa';

  @override
  String get category_family_bills => 'Contas';

  @override
  String get category_other_misc => 'Diversos';

  @override
  String get category_other_utilities => 'Serviços públicos';

  @override
  String get category_other_services => 'Serviços';

  @override
  String get attachments => 'Anexos';

  @override
  String get delete_attachment => 'Excluir anexo';

  @override
  String get share_attachment => 'Compartilhar anexo';

  @override
  String get delete_attachment_confirm_title => 'Excluir o anexo?';

  @override
  String get delete_attachment_confirm_message =>
      'O anexo será excluído da despesa.';

  @override
  String get attachment_source => 'Adicionar anexo';

  @override
  String get from_files => 'De um arquivo';

  @override
  String get expense => 'Despesa';

  @override
  String get notification_enabled => 'Notificação persistente';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Despesas de hoje: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Adicionar despesa';

  @override
  String get notification_disable => 'Desativar';

  @override
  String get wizard_group_creation_title => 'Novo grupo';

  @override
  String get wizard_skip => 'Pular';

  @override
  String get wizard_user_name_welcome => 'Olá!';

  @override
  String get wizard_user_name_label => 'Seu nome (opcional)';

  @override
  String get wizard_user_name_hint => 'ex. Pedro';

  @override
  String get wizard_participants_section_title => 'Quem está participando?';

  @override
  String get wizard_participants_section_hint =>
      'Adicione amigos ou colegas de quarto. Você pode modificá-los depois.';

  @override
  String get danger_zone => 'Zona de perigo';

  @override
  String get export_options_desc => 'Descarrega ou partilha as despesas';

  @override
  String get export_csv_description => 'Formato planilha';

  @override
  String get export_ofx_description => 'Formato bancário';

  @override
  String get export_markdown_description => 'Formato documento';

  @override
  String get save_label => 'Salvar';

  @override
  String get sync_title => 'Sincronização';

  @override
  String get sync_settings_desc => 'Wi-Fi, Bluetooth ou Google Drive';

  @override
  String get sync_multiuser_title => 'Sincronizar com outros';

  @override
  String get sync_multiuser_description => 'Grupos por Wi-Fi ou Bluetooth';

  @override
  String get sync_multidevice_title => 'Sincronizar dispositivos';

  @override
  String get sync_multidevice_description =>
      'Sincroniza os teus dispositivos no Drive';

  @override
  String get sync_local_title => 'Wi-Fi';

  @override
  String get sync_local_description => 'Automática na mesma rede Wi-Fi';

  @override
  String get sync_cloud_title => 'Google Drive';

  @override
  String get sync_cloud_description => 'Sincronização via Google Drive';

  @override
  String get sync_cloud_scope_description =>
      'Sincroniza todos os seus grupos juntos (com Wi-Fi e Bluetooth você escolhe grupo por grupo)';

  @override
  String get sync_cloud_enable => 'Ative a sincronização com o Google Drive';

  @override
  String get sync_cloud_privacy =>
      'Seus dados são salvos no seu Google Drive pessoal, não em servidores de terceiros.';

  @override
  String sync_cloud_signed_in_as(String email) {
    return 'Conectado como $email';
  }

  @override
  String get sync_cloud_sign_in_failed =>
      'Falha ou cancelamento no login do Google';

  @override
  String get sync_history_title => 'Histórico de sincronizações';

  @override
  String sync_history_group_desc(String groupTitle) {
    return 'Sincronizações de “$groupTitle”';
  }

  @override
  String get sync_status_syncing => 'Sincronizando…';

  @override
  String get sync_now => 'Sincronizar agora';

  @override
  String sync_last_sync(String time) {
    return 'Última sincronização: $time';
  }

  @override
  String get sync_bt_title => 'Bluetooth';

  @override
  String get sync_bt_description => 'Manual, com dispositivos próximos';

  @override
  String get sync_bt_searching => 'Procurando dispositivos próximos…';

  @override
  String get sync_bt_advertise_waiting => 'Aguardando um dispositivo próximo…';

  @override
  String get sync_bt_sync_with => 'Sincronizar';

  @override
  String get sync_bt_completed => 'Sincronização concluída';

  @override
  String sync_bt_received_sent(int received, int sent) {
    return 'Recebidas $received alterações, enviadas $sent';
  }

  @override
  String get sync_bt_error => 'Sincronização falhou';

  @override
  String get sync_bt_error_detail =>
      'Algo deu errado durante a conexão. Tente novamente.';

  @override
  String get sync_bt_retry => 'Tentar novamente';

  @override
  String get sync_bt_permission_denied =>
      'Bluetooth não permitido: ative-o nas configurações do telefone';

  @override
  String get sync_history_empty => 'Nenhuma sincronização';

  @override
  String get sync_channel_lan => 'LAN';

  @override
  String get sync_channel_bluetooth => 'Bluetooth';

  @override
  String get sync_channel_cloud => 'Nuvem';

  @override
  String sync_records_exchanged(int sent, int received) {
    return '$sent enviadas, $received recebidas';
  }

  @override
  String get sync_group_shared => 'Compartilhado';

  @override
  String get sync_group_enable => 'Compartilhar este grupo';

  @override
  String get sync_group_enable_desc => 'Com os dispositivos emparelhados';

  @override
  String get sync_group_needs_channel =>
      'Ative Wi-Fi ou Bluetooth em Sincronização para compartilhar o grupo';

  @override
  String get sync_qr_show_button => 'Mostrar código QR';

  @override
  String get sync_qr_scan_button => 'Escanear código QR';

  @override
  String get sync_qr_show_title => 'Parear um dispositivo';

  @override
  String get sync_qr_show_description =>
      'Escaneie este código a partir de outro dispositivo na mesma rede Wi-Fi para pareá-lo com a sincronização';

  @override
  String sync_qr_sharing_group(String groupTitle) {
    return 'Compartilhando “$groupTitle”';
  }

  @override
  String sync_qr_expires_in(String time) {
    return 'Expira em $time';
  }

  @override
  String get sync_qr_expired_title => 'Código expirado';

  @override
  String get sync_qr_expired_desc =>
      'Gere um novo código para continuar o pareamento';

  @override
  String get sync_qr_regenerate_button => 'Gerar novo código';

  @override
  String get sync_qr_no_network =>
      'Conecte-se ao Wi-Fi para gerar o código de pareamento';

  @override
  String get sync_qr_scan_title => 'Escaneie o código de pareamento';

  @override
  String get sync_qr_scan_description => 'Lê o QR do outro dispositivo';

  @override
  String sync_qr_pair_success(String deviceName) {
    return 'Pareado com $deviceName';
  }

  @override
  String get sync_qr_pair_failed =>
      'Falha no pareamento — verifique se ambos os dispositivos estão na mesma rede Wi-Fi';

  @override
  String get sync_qr_pair_expired =>
      'Este código de pareamento expirou — peça ao outro dispositivo para mostrar um novo';

  @override
  String get sync_qr_pair_emulator_host =>
      'Este código foi gerado em um emulador Android, que não pode ser alcançado a partir de outros dispositivos — pareie usando dois dispositivos físicos na mesma rede Wi-Fi';

  @override
  String get sync_qr_emulator_warning =>
      'Este dispositivo é um emulador Android — seu endereço normalmente não é alcançável a partir de outros dispositivos, então o pareamento pode falhar';

  @override
  String get sync_paired_devices_title => 'Dispositivos pareados';

  @override
  String get sync_paired_devices_empty => 'Ainda não há dispositivos pareados';

  @override
  String get sync_paired_devices_remove => 'Remover pareamento';

  @override
  String get search_expenses => 'Pesquisar despesas';

  @override
  String search_in_group(String groupName) {
    return 'Pesquisar em $groupName';
  }

  @override
  String get has_attachment => 'Com anexo';

  @override
  String get has_location => 'Com localização';

  @override
  String get search_no_results => 'Nenhuma despesa encontrada';

  @override
  String get search_no_results_hint =>
      'Tente termos diferentes ou ajuste os filtros';

  @override
  String get voice_input_button => 'Adicionar por voz';

  @override
  String get voice_input_listening => 'Ouvindo…';

  @override
  String get voice_input_tap_to_speak => 'Toque para falar';

  @override
  String get voice_input_processing => 'Processando…';

  @override
  String get voice_input_error => 'Erro de reconhecimento de voz';

  @override
  String get voice_input_permission_denied => 'Permissão do microfone negada';

  @override
  String get voice_input_not_available =>
      'Reconhecimento de voz não disponível';

  @override
  String get voice_input_no_speech => 'Não ouvi nada. Tente novamente.';

  @override
  String get voice_input_hint =>
      'Tente dizer: “50 reais pelo jantar no restaurante”';

  @override
  String get voice_add_expense => 'Adicionar por voz';

  @override
  String get voice_expense_saved => 'Despesa salva';

  @override
  String get voice_expense_needs_more_info =>
      'Faltam alguns dados: complete a despesa';

  @override
  String get from_unsplash => 'Do Unsplash';

  @override
  String get unsplash_search_hint => 'Pesquisar fotos no Unsplash…';

  @override
  String get unsplash_no_results => 'Nenhuma imagem encontrada';

  @override
  String get unsplash_downloading => 'Baixando foto…';

  @override
  String get unsplash_error => 'Falha ao carregar as imagens';

  @override
  String get unsplash_photos_by => 'Fotos de';

  @override
  String get unsplash_use_photo => 'Usar esta foto';

  @override
  String get scan_receipt => 'Escanear recibo';

  @override
  String get scanning_receipt => 'Lendo o recibo…';

  @override
  String get receipt_scan_error => 'Não foi possível ler o recibo';

  @override
  String get receipt_scan_permission_denied =>
      'Câmera não permitida: ative-a nas configurações do telefone para ler recibos';

  @override
  String get no_text_found => 'Nenhum texto encontrado na imagem';

  @override
  String get receipt_scanned => 'Recibo escaneado';

  @override
  String get settings_group_templates_manage_title => 'Modelos de grupo';

  @override
  String get settings_group_templates_manage_desc =>
      'Crie e edite seus modelos';

  @override
  String get settings_group_templates_page_title => 'Modelos de grupo';

  @override
  String get settings_group_templates_empty_state => 'Nenhum modelo';

  @override
  String get settings_group_templates_add_title => 'Novo modelo';

  @override
  String get settings_group_templates_edit_title => 'Editar modelo';

  @override
  String get settings_group_templates_name_label => 'Nome do modelo';

  @override
  String get settings_group_templates_name_hint => 'Ex. Semana de esqui';

  @override
  String get settings_group_templates_icon_label => 'Ícone';

  @override
  String get settings_group_templates_categories_label => 'Categorias padrão';

  @override
  String get settings_group_templates_validation_error =>
      'Nome e pelo menos uma categoria são obrigatórios';

  @override
  String get settings_group_templates_delete_title => 'Excluir modelo';

  @override
  String settings_group_templates_delete_message(String templateName) {
    return 'Excluir o modelo “$templateName”?';
  }

  @override
  String get clear_dates => 'Remover datas';

  @override
  String accessibility_map_marker_expense(String name, String amount) {
    return '$name, $amount';
  }

  @override
  String accessibility_map_marker_group(int count, String place) {
    return '$count despesas, $place';
  }

  @override
  String get nav_home => 'Início';

  @override
  String get nav_groups => 'Grupos';

  @override
  String get quick_action_map => 'Mapa';

  @override
  String get quick_action_search => 'Buscar';

  @override
  String new_expense_in_group(String group) {
    return 'Nova despesa em $group';
  }

  @override
  String groups_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos ativos',
      one: '1 grupo ativo',
      zero: 'Nenhum grupo ativo',
    );
    return '$_temp0';
  }

  @override
  String get get_started_title => 'Primeiros passos';

  @override
  String get_started_progress(int done, int total) {
    return '$done de $total concluídos';
  }

  @override
  String get get_started_create_group => 'Crie o grupo';

  @override
  String get get_started_first_expense => 'Adicione a primeira despesa';

  @override
  String get get_started_participants => 'Adicione os participantes';

  @override
  String get get_started_look => 'Escolha uma foto ou uma cor';

  @override
  String get_started_step_done(String step) {
    return '$step, concluído';
  }

  @override
  String get balances => 'Saldos';

  @override
  String get per_person => 'Por pessoa';

  @override
  String get settle_up => 'Para acertar';

  @override
  String get all_settled_up => 'Tudo acertado';

  @override
  String balance_gets_back(String name, String amount) {
    return '$name recebe $amount';
  }

  @override
  String balance_owes(String name, String amount) {
    return '$name deve $amount';
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
      other: '$count locais',
      one: '1 local',
    );
    return '$_temp0';
  }

  @override
  String get more_options => 'Mais opções';

  @override
  String get highest_expense => 'Maior despesa';

  @override
  String get most_expensive_day => 'Dia mais caro';

  @override
  String get chart_day_by_day => 'Dia a dia';

  @override
  String get this_week => 'Esta semana';

  @override
  String get last_week => 'Semana passada';

  @override
  String get quick_action_scan => 'Digitalizar';

  @override
  String get quick_action_voice => 'Voz';

  @override
  String get sync_state_syncing => 'sincronizando';

  @override
  String get sync_state_synced => 'atualizado';

  @override
  String get sync_state_error => 'falha na sincronização, toque para detalhes';

  @override
  String get share_balances => 'Compartilhar saldos';

  @override
  String balances_share_title(String group) {
    return '$group · saldos';
  }

  @override
  String balances_share_footer(String total, String perPerson) {
    return 'Total $total · $perPerson por pessoa';
  }

  @override
  String balance_reminder_message(
    String from,
    String group,
    String amount,
    String to,
  ) {
    return 'Oi $from! No grupo “$group” você deve $amount a $to.';
  }

  @override
  String get chart_week_by_week => 'Semana a semana';

  @override
  String get chart_month_by_month => 'Mês a mês';

  @override
  String get edit => 'Editar';

  @override
  String get recent_searches => 'Pesquisas recentes';

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
      zero: 'Nenhum resultado',
    );
    return '$_temp0';
  }

  @override
  String get expense_details_section => 'Detalhes';

  @override
  String get add_expense_button => 'Adicionar despesa';

  @override
  String auto_backup_last(String date) {
    return 'Último backup: $date';
  }

  @override
  String get auto_backup_never => 'Ainda sem backup';

  @override
  String get auto_backup_off => 'Desligado: dados fora do backup';

  @override
  String get drive_backup_connect => 'Ligar ao Google Drive';

  @override
  String get drive_backup_connect_desc => 'Backups numa pasta privada';

  @override
  String get drive_backup_now => 'Guardar no Drive agora';

  @override
  String get drive_backup_none => 'Ainda sem backups no Drive';

  @override
  String get drive_backup_restore => 'Restaurar do Drive';

  @override
  String get drive_backup_restore_desc => 'Escolhe um dos últimos 5 backups';

  @override
  String get drive_backup_weekly => 'Backup semanal';

  @override
  String get drive_backup_weekly_desc => 'Todas as semanas, ao abrir';

  @override
  String get drive_backup_disconnect => 'Desligar';

  @override
  String get drive_backup_saved => 'Backup guardado no Google Drive';

  @override
  String get drive_backup_error => 'Não foi possível aceder ao Google Drive';

  @override
  String get expense_more_details => 'Mais detalhes';

  @override
  String get quick_action_photo => 'Foto';

  @override
  String get photo_add_expense => 'Nova despesa com foto do recibo';

  @override
  String get receipt_photo_error => 'Não foi possível tirar a foto do recibo';

  @override
  String get crop_hint => 'Arraste e aperte para escolher a parte a manter';

  @override
  String get crop_preview => 'Pré-visualização';

  @override
  String get crop_use_photo => 'Usar esta foto';

  @override
  String get welcome_tagline =>
      'Despesas de viagens, casa e amigos, divididas de forma justa. Tudo fica no seu telefone.';

  @override
  String get wizard_name_title => 'Como você se chama?';

  @override
  String get wizard_name_note =>
      'Fica no seu telefone. Você será o primeiro participante dos seus grupos.';

  @override
  String get wizard_type_title => 'Que tipo de grupo?';

  @override
  String get wizard_type_note =>
      'Define as categorias iniciais: você pode mudá-las quando quiser.';

  @override
  String get group_type_personal_desc => 'Só os seus gastos';

  @override
  String get group_type_family_desc => 'Casa, família, colegas de quarto';

  @override
  String get group_type_travel_desc => 'Férias, fins de semana, passeios';

  @override
  String get group_type_other_desc => 'Jantares, eventos, presentes';

  @override
  String get wizard_details_title => 'Como vamos chamá-lo?';

  @override
  String get wizard_details_note =>
      'As datas alimentam o gráfico de gastos. Você pode mudar tudo depois.';

  @override
  String wizard_people_you(String name) {
    return '$name (você)';
  }

  @override
  String get wizard_people_add_hint => 'Nome de um amigo';

  @override
  String wizard_people_remove(String name) {
    return 'Remover $name';
  }

  @override
  String get wizard_dates_add => 'Datas';

  @override
  String get wizard_continue => 'Continuar';

  @override
  String get wizard_create => 'Criar grupo';

  @override
  String get attachment_take_photo => 'Tirar uma foto';

  @override
  String get attachment_record_video => 'Gravar um vídeo';

  @override
  String get place_search_action => 'Procurar um lugar';

  @override
  String get background_photo => 'Foto';

  @override
  String get background_none => 'Nenhum';

  @override
  String get stats_pace_title => 'Ritmo de gastos';

  @override
  String get stats_per_day => 'por dia';

  @override
  String get stats_per_month => 'por mês';

  @override
  String stats_pace_days(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Média de $count dias',
      one: 'Em 1 dia',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_pace_months(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Média de $count meses',
      one: 'Em 1 mês',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_per_expense(String amount) {
    return '$amount por despesa';
  }

  @override
  String stats_active_days(int active, int total) {
    return '$active de $total dias com despesas';
  }

  @override
  String stats_active_months(int active, int total) {
    return '$active de $total meses com despesas';
  }

  @override
  String get most_expensive_month => 'Mês mais caro';

  @override
  String get per_month => '/mês';

  @override
  String get map_location_off =>
      'Ative a localização automática para ver as despesas no mapa';

  @override
  String get map_no_places => 'Ainda não há despesas com um local';

  @override
  String get no_active_groups_subtitle =>
      'Crie um para uma viagem, uma casa compartilhada ou um evento.';

  @override
  String get export_options_empty => 'Ainda não há despesas para exportar';

  @override
  String get sync_badge_ok => 'sincronizado nas últimas 24 horas';

  @override
  String get sync_badge_failed => 'a última sincronização falhou';

  @override
  String get sync_badge_stale => 'não sincronizado nas últimas 24 horas';
}
