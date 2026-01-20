// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get developer_section_title => 'Desenvolvedor e Suporte';

  @override
  String get developer_section_desc => 'Apoie o desenvolvedor ou veja o perfil';

  @override
  String get repo_section_title => 'Código-fonte e Problemas';

  @override
  String get repo_section_desc => 'Veja o código-fonte ou reporte um problema';

  @override
  String get license_section_title => 'Licença';

  @override
  String get license_section_desc => 'Ver a licença open source';

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
  String get settings_flag_secure_desc =>
      'Impede capturas de tela e gravação da tela';

  @override
  String get settings_flag_secure_title => 'Tela segura';

  @override
  String get settings_privacy => 'Privacidade';

  @override
  String get select_currency => 'Selecionar moeda';

  @override
  String get select_period_hint_short => 'Definir datas';

  @override
  String get select_period_hint => 'Selecionar datas';

  @override
  String get suggested_duration => 'Duração sugerida';

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
  String get save_change_expense => 'Salvar alterações';

  @override
  String get group_total => 'Total';

  @override
  String get total_spent => 'Total gasto';

  @override
  String get download_all_csv => 'Baixar tudo (CSV)';

  @override
  String get share_all_csv => 'Compartilhar tudo (CSV)';

  @override
  String get download_all_ofx => 'Baixar tudo (OFX)';

  @override
  String get share_all_ofx => 'Compartilhar tudo (OFX)';

  @override
  String get download_all_markdown => 'Baixar tudo (Markdown)';

  @override
  String get share_all_markdown => 'Compartilhar tudo (Markdown)';

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
  String get share_text_label => 'Compartilhar texto';

  @override
  String get share_image_label => 'Compartilhar imagem';

  @override
  String get export_share => 'Exportar e Compartilhar';

  @override
  String get contribution_percentages => 'Percentuais';

  @override
  String get contribution_percentages_desc =>
      'Parcela do total paga por cada participante';

  @override
  String get export_options => 'Opções de exportação';

  @override
  String get welcome_v3_title => 'Organize.\nCompartilhe.\nQuite.\n ';

  @override
  String get good_morning => 'Bom dia';

  @override
  String get good_afternoon => 'Boa tarde';

  @override
  String get good_evening => 'Boa noite';

  @override
  String get your_groups => 'Seus grupos';

  @override
  String get no_active_groups => 'Nenhum grupo ativo';

  @override
  String get no_active_groups_subtitle => 'Crie um grupo de despesas';

  @override
  String get create_first_group => 'Criar um grupo';

  @override
  String get new_expense_group => 'Novo grupo de despesas';

  @override
  String get new_expense => 'New Expense';

  @override
  String get edit_expense => 'Editar despesa';

  @override
  String get tap_to_create => 'Toque para criar';

  @override
  String get no_expense_label => 'Nenhuma despesa encontrada';

  @override
  String get image => 'Imagem';

  @override
  String get select_image => 'Selecionar imagem';

  @override
  String get change_image => 'Alterar imagem';

  @override
  String get from_gallery => 'Da galeria';

  @override
  String get from_camera => 'Da câmera';

  @override
  String get remove_image => 'Remover imagem';

  @override
  String get cannot_delete_assigned_participant =>
      'Não é possível excluir o participante: ele está atribuído a uma ou mais despesas';

  @override
  String get cannot_delete_assigned_category =>
      'Não é possível excluir a categoria: ela está atribuída a uma ou mais despesas';

  @override
  String get color => 'Cor';

  @override
  String get remove_color => 'Remover cor';

  @override
  String get color_alternative => 'Alternativa à imagem';

  @override
  String get background => 'Fundo';

  @override
  String get select_background => 'Selecionar fundo';

  @override
  String get background_options => 'Opções de fundo';

  @override
  String get choose_image_or_color => 'Escolha imagem ou cor';

  @override
  String get participants_description => 'Pessoas que dividem os custos';

  @override
  String get categories_description => 'Agrupe despesas por tipo';

  @override
  String get dates_description => 'Início e fim opcionais';

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
  String get currency_description => 'Moeda base do grupo';

  @override
  String get background_color_selected => 'Cor selecionada';

  @override
  String get background_tap_to_replace => 'Toque para substituir';

  @override
  String get background_tap_to_change => 'Toque para alterar';

  @override
  String get background_select_image_or_color => 'Selecione imagem ou cor';

  @override
  String get background_random_color => 'Cor aleatória';

  @override
  String get background_remove => 'Remover fundo';

  @override
  String get crop_image_title => 'Cortar imagem';

  @override
  String get crop_confirm => 'Confirmar';

  @override
  String get saving => 'Salvando...';

  @override
  String get processing_image => 'Processando imagem...';

  @override
  String get no_trips_found => 'Para onde você quer ir?';

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
  String get last_7_days => '7 dias';

  @override
  String get recent_activity => 'Atividade recente';

  @override
  String get about => 'Sobre';

  @override
  String get license_hint => 'Este aplicativo é distribuído sob a licença MIT.';

  @override
  String get license_link => 'Ver Licença MIT no GitHub';

  @override
  String get license_section => 'Licença';

  @override
  String get add_trip => 'Adicionar grupo';

  @override
  String get new_group => 'Novo grupo';

  @override
  String get group => 'Group';

  @override
  String get create => 'Criar';

  @override
  String get group_name => 'Nome';

  @override
  String get enter_title => 'Digite um nome';

  @override
  String get enter_participant => 'Insira pelo menos um participante';

  @override
  String get select_start => 'Selecionar início';

  @override
  String get select_end => 'Selecionar fim';

  @override
  String get start_date_not_selected => 'Selecione o início';

  @override
  String get end_date_not_selected => 'Selecionar fim';

  @override
  String get select_from_date => 'Selecionar de';

  @override
  String get select_to_date => 'Selecionar até';

  @override
  String get date_range_not_selected => 'Selecione o período';

  @override
  String get date_range_partial => 'Selecione ambas as datas';

  @override
  String get save => 'Salvar';

  @override
  String get delete_trip => 'Excluir viagem';

  @override
  String get delete_trip_confirm =>
      'Tem certeza de que deseja excluir este grupo?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String from_to(Object end, Object start) {
    return '$start - $end';
  }

  @override
  String get add_expense => 'Nova despesa';

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
  String get no_categories => 'Sem categorias';

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
  String get select_both_dates_or_none =>
      'Selecione ambas as datas ou deixe ambas vazias';

  @override
  String get end_date_after_start => 'Data final deve ser após a inicial';

  @override
  String get start_date_optional => 'De';

  @override
  String get end_date_optional => 'Até';

  @override
  String get dates => 'Período';

  @override
  String get expenses_by_participant => 'Por participante';

  @override
  String get expenses_by_category => 'Por categoria';

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'Nenhum grupo para backup';

  @override
  String get backup_error => 'Falha no backup';

  @override
  String get backup_share_message => 'Aqui está o seu backup do Caravella';

  @override
  String get import => 'Importar';

  @override
  String get import_confirm_title => 'Importar dados';

  @override
  String import_confirm_message(Object file) {
    return 'Tem certeza de que deseja substituir todas as viagens pelo arquivo \"$file\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get import_success => 'Importação concluída! Dados recarregados.';

  @override
  String get import_error =>
      'Falha na importação. Verifique o formato do arquivo.';

  @override
  String get categories => 'Categorias';

  @override
  String get other_settings => 'Outras configurações';

  @override
  String get other_settings_desc =>
      'Moeda, plano de fundo e localização automática';

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
  String get participant_name_hint => 'Insira o nome do participante';

  @override
  String get edit_participant => 'Editar participante';

  @override
  String get delete_participant => 'Excluir participante';

  @override
  String get add_participant => 'Adicionar participante';

  @override
  String get no_participants => 'Sem participantes';

  @override
  String get category_name_hint => 'Digite o nome da categoria';

  @override
  String get edit_category => 'Editar categoria';

  @override
  String get delete_category => 'Excluir categoria';

  @override
  String participant_name_semantics(Object name) {
    return 'Participante: $name';
  }

  @override
  String category_name_semantics(Object name) {
    return 'Categoria: $name';
  }

  @override
  String get currency => 'Moeda';

  @override
  String get settings_tab => 'Configurações';

  @override
  String get basic_info => 'Informações Básicas';

  @override
  String get settings => 'Configurações';

  @override
  String get history => 'Histórico';

  @override
  String get all => 'Todos';

  @override
  String get search_groups => 'Pesquisar grupos...';

  @override
  String get no_search_results => 'Nenhum grupo encontrado para';

  @override
  String get try_different_search => 'Tente pesquisar com palavras diferentes';

  @override
  String get active => 'Ativo';

  @override
  String get archived => 'Arquivado';

  @override
  String get archive => 'Arquivar';

  @override
  String get unarchive => 'Desarquivar';

  @override
  String get pin => 'Favorito';

  @override
  String get unpin => 'Desfavorito';

  @override
  String get delete => 'Excluir';

  @override
  String get undo => 'DESFAZER';

  @override
  String get archived_with_undo => 'Arquivado';

  @override
  String get unarchived_with_undo => 'Desarquivado';

  @override
  String get pinned_with_undo => 'Marcado como favorito';

  @override
  String get unpinned_with_undo => 'Favorito removido';

  @override
  String get deleted_with_undo => 'Excluído';

  @override
  String get archive_confirm => 'Deseja arquivar';

  @override
  String get unarchive_confirm => 'Deseja desarquivar';

  @override
  String get overview => 'Visão geral';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get period => 'Período';

  @override
  String get total_expenses => 'Total de despesas';

  @override
  String get number_of_expenses => 'Número de despesas';

  @override
  String get options => 'Opções';

  @override
  String get show_overview => 'Mostrar visão geral';

  @override
  String get show_statistics => 'Mostrar estatísticas';

  @override
  String get no_expenses_to_display => 'Nenhuma despesa para exibir';

  @override
  String get no_expenses_to_analyze => 'Nenhuma despesa para analisar';

  @override
  String get select_expense_date => 'Selecionar data da despesa';

  @override
  String get select_expense_date_short => 'Selecionar data';

  @override
  String get date => 'Data';

  @override
  String get edit_group => 'Editar grupo';

  @override
  String get edit_group_desc =>
      'Modificar configurações, participantes e categorias do grupo';

  @override
  String get new_group_desc =>
      'Criar um novo grupo de despesas com configurações personalizadas';

  @override
  String get delete_group => 'Excluir grupo';

  @override
  String get delete_group_confirm =>
      'Tem certeza de que deseja excluir este grupo de despesas? Esta ação não pode ser desfeita.';

  @override
  String get add_expense_fab => 'Adicionar Despesa';

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
  String get developed_by => 'Desenvolvido por calca';

  @override
  String get links => 'Links';

  @override
  String get daily_expenses_chart => 'Despesas diárias';

  @override
  String get weekly_expenses_chart => 'Despesas semanais';

  @override
  String get daily_average_by_category => 'Média diária por categoria';

  @override
  String get per_day => '/dia';

  @override
  String get no_expenses_for_statistics => 'Sem despesas para estatísticas';

  @override
  String get settlement => 'Acerto';

  @override
  String get all_balanced => 'Todas as contas estão equilibradas!';

  @override
  String get owes_to => ' deve ';

  @override
  String get export_csv => 'Exportar CSV';

  @override
  String get no_expenses_to_export => 'Nenhuma despesa para exportar';

  @override
  String get export_csv_share_text => 'Despesas exportadas de ';

  @override
  String get export_csv_error => 'Erro ao exportar despesas';

  @override
  String get expense_name => 'Descrição';

  @override
  String get paid_by => 'Pago por';

  @override
  String get expense_added_success => 'Despesa adicionada';

  @override
  String get expense_updated_success => 'Despesa atualizada';

  @override
  String get data_refreshing => 'Atualizando…';

  @override
  String get data_refreshed => 'Atualizado';

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
  String get enter_location_manually => 'Inserir manualmente';

  @override
  String get location_permission_denied => 'Permissão de localização negada';

  @override
  String get location_service_disabled => 'Serviço de localização desativado';

  @override
  String get getting_location => 'Obtendo localização...';

  @override
  String get location_error => 'Erro ao obter localização';

  @override
  String get resolving_address => 'Resolvendo endereço…';

  @override
  String get address_resolved => 'Endereço resolvido';

  @override
  String get search_place => 'Procurar lugar';

  @override
  String get search_place_hint => 'Procurar um lugar ou endereço';

  @override
  String get settings_general => 'Geral';

  @override
  String get settings_general_desc => 'Idioma e aparência';

  @override
  String get settings_auto_location_section => 'Detecção de localização';

  @override
  String get settings_auto_location_section_desc =>
      'Configurar a detecção automática de localização';

  @override
  String get settings_auto_location_title => 'Ativar para detectar';

  @override
  String get settings_auto_location_desc =>
      'Detectar GPS ao adicionar uma despesa';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_language_desc => 'Escolha o idioma preferido';

  @override
  String get settings_language_it => 'Italiano';

  @override
  String get settings_language_en => 'Inglês';

  @override
  String get settings_language_es => 'Espanhol';

  @override
  String get settings_language_pt => 'Português';

  @override
  String get settings_language_zh => 'Chinês (Simplificado)';

  @override
  String get settings_select_language => 'Selecionar idioma';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_theme_desc => 'Claro, escuro ou sistema';

  @override
  String get settings_select_theme => 'Selecionar tema';

  @override
  String get settings_dynamic_color => 'Cor dinâmica';

  @override
  String get settings_dynamic_color_desc => 'Usar cores do papel de parede';

  @override
  String get settings_privacy_desc => 'Opções de segurança e privacidade';

  @override
  String get settings_data => 'Dados';

  @override
  String get settings_data_desc => 'Gerencie suas informações';

  @override
  String get settings_data_manage => 'Gerenciamento de dados';

  @override
  String get settings_info => 'Informações';

  @override
  String get settings_info_desc => 'Detalhes e suporte do app';

  @override
  String get settings_app_version => 'Versão do app';

  @override
  String get settings_info_card => 'Informações';

  @override
  String get settings_info_card_desc => 'Desenvolvedor, código-fonte e licença';

  @override
  String get terms_github_title => 'Website: calca';

  @override
  String get terms_github_desc => 'Website pessoal do desenvolvedor.';

  @override
  String get terms_repo_title => 'Repositório GitHub';

  @override
  String get terms_repo_desc => 'Código-fonte da aplicação.';

  @override
  String get terms_issue_title => 'Reportar um problema';

  @override
  String get terms_issue_desc => 'Ir para a página de issues no GitHub.';

  @override
  String get terms_license_desc => 'Ver a licença open source.';

  @override
  String get support_developer_title => 'Pague um café';

  @override
  String get support_developer_desc => 'Apoie o desenvolvimento deste app.';

  @override
  String get data_title => 'Backup e Restauração';

  @override
  String get data_backup_title => 'Backup';

  @override
  String get data_backup_desc =>
      'Crie um arquivo de backup dos seus grupos e despesas.';

  @override
  String get data_restore_title => 'Restaurar';

  @override
  String get data_restore_desc =>
      'Importe um backup para restaurar seus dados.';

  @override
  String get auto_backup_title => 'Backup automático';

  @override
  String get auto_backup_desc => 'Ativar backup automático do sistema';

  @override
  String get settings_user_name_title => 'Seu nome';

  @override
  String get settings_user_name_desc =>
      'Nome ou apelido para usar no aplicativo';

  @override
  String get settings_user_name_hint => 'Insira seu nome';

  @override
  String get default_participant_me => 'Eu';

  @override
  String get info_tab => 'Informações';

  @override
  String get select_paid_by => 'Selecionar pagador';

  @override
  String get select_category => 'Selecionar categoria';

  @override
  String get check_form => 'Verifique os dados inseridos';

  @override
  String get delete_expense => 'Excluir despesa';

  @override
  String get delete_expense_confirm =>
      'Tem certeza de que deseja excluir esta despesa?';

  @override
  String get no_results_found => 'Nenhum resultado encontrado.';

  @override
  String get try_adjust_filter_or_search =>
      'Tente ajustar o filtro ou a pesquisa.';

  @override
  String get general_statistics => 'Estatísticas gerais';

  @override
  String get add_first_expense => 'Adicione a primeira despesa para começar';

  @override
  String get overview_and_statistics => 'Resumo e estatísticas';

  @override
  String get daily_average => 'Diário';

  @override
  String get spent_today => 'Hoje';

  @override
  String get monthly_average => 'Mensal';

  @override
  String get average_expense => 'Despesa média';

  @override
  String get welcome_v3_cta => 'Começar!';

  @override
  String get discard_changes_title => 'Descartar alterações?';

  @override
  String get discard_changes_message =>
      'Tem certeza de que deseja descartar alterações não salvas?';

  @override
  String get discard => 'Descartar';

  @override
  String get category_placeholder => 'Categoria';

  @override
  String get image_requirements => 'PNG, JPG, GIF (máx 10MB)';

  @override
  String error_saving_group(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get error_selecting_image => 'Erro ao selecionar imagem';

  @override
  String get error_saving_image => 'Erro ao salvar imagem';

  @override
  String get already_exists => 'já existe';

  @override
  String get status_all => 'Todos';

  @override
  String get status_active => 'Ativos';

  @override
  String get status_archived => 'Arquivados';

  @override
  String get no_archived_groups => 'Nenhum grupo arquivado';

  @override
  String get no_archived_groups_subtitle =>
      'Você ainda não arquivou nenhum grupo';

  @override
  String get all_groups_archived_info =>
      'Todos os seus grupos estão arquivados. Você pode restaurá-los na seção Arquivo ou criar novos.';

  @override
  String get filter_status_tooltip => 'Filtrar grupos';

  @override
  String get welcome_logo_semantic => 'Logo do app Caravella';

  @override
  String get create_new_group => 'Criar novo grupo';

  @override
  String get accessibility_add_new_item => 'Adicionar novo item';

  @override
  String get accessibility_navigation_bar => 'Barra de navegação';

  @override
  String get accessibility_back_button => 'Voltar';

  @override
  String get accessibility_loading_groups => 'Carregando grupos';

  @override
  String get accessibility_loading_your_groups => 'Carregando seus grupos';

  @override
  String get accessibility_groups_list => 'Lista de grupos';

  @override
  String get accessibility_welcome_screen => 'Tela de boas-vindas';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Despesas totais: $amount€';
  }

  @override
  String get accessibility_add_expense => 'Adicionar despesa';

  @override
  String accessibility_security_switch(Object state) {
    return 'Interruptor de segurança - $state';
  }

  @override
  String get accessibility_switch_on => 'Ligado';

  @override
  String get accessibility_switch_off => 'Desligado';

  @override
  String get accessibility_image_source_dialog =>
      'Diálogo de seleção de origem da imagem';

  @override
  String get accessibility_currently_enabled => 'Atualmente ativado';

  @override
  String get accessibility_currently_disabled => 'Atualmente desativado';

  @override
  String get accessibility_double_tap_disable =>
      'Toque duas vezes para desativar a segurança da tela';

  @override
  String get accessibility_double_tap_enable =>
      'Toque duas vezes para ativar a segurança da tela';

  @override
  String get accessibility_toast_success => 'Sucesso';

  @override
  String get accessibility_toast_error => 'Erro';

  @override
  String get accessibility_toast_info => 'Informação';

  @override
  String get color_suggested_title => 'Cores sugeridas';

  @override
  String get color_suggested_subtitle =>
      'Escolha uma das cores compatíveis com o tema';

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
  String get search_currency => 'Search currency...';

  @override
  String get activity => 'Activity';

  @override
  String get search_expenses_hint => 'Search by name or note...';

  @override
  String get clear_filters => 'Clear';

  @override
  String get show_filters => 'Show filters';

  @override
  String get hide_filters => 'Hide filters';

  @override
  String get all_categories => 'All';

  @override
  String get all_participants => 'All';

  @override
  String get no_expenses_with_filters =>
      'No expenses match the selected filters';

  @override
  String get no_expenses_yet => 'No expenses added yet';

  @override
  String get empty_expenses_title => 'Ready to start tracking?';

  @override
  String get empty_expenses_subtitle =>
      'Add your first expense to get started with this group!';

  @override
  String get add_first_expense_button => 'Add First Expense';

  @override
  String get show_search => 'Show search bar';

  @override
  String get hide_search => 'Hide search bar';

  @override
  String get expense_groups_title => 'Expense Groups';

  @override
  String get expense_groups_desc => 'Manage your expense groups';

  @override
  String get whats_new_title => 'Novidades';

  @override
  String get whats_new_desc =>
      'Descubra os recursos e atualizações mais recentes';

  @override
  String get whats_new_subtitle => 'Destaques recentes';

  @override
  String get whats_new_latest => 'Fique por dentro das melhorias mais recentes';

  @override
  String get changelog_title => 'Histórico de versões';

  @override
  String get changelog_desc => 'Histórico de versões e melhorias';

  @override
  String get average_per_person => 'Média por pessoa';

  @override
  String get more => 'mais';

  @override
  String get less => 'menos';

  @override
  String get debt_prefix_to => 'a ';

  @override
  String get view_on_map => 'View on map';

  @override
  String get expenses_map => 'Expenses Map';

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
  String get check_for_updates => 'Verificar atualizações';

  @override
  String get check_for_updates_desc =>
      'Verificar disponibilidade de nova versão';

  @override
  String get update_available => 'Atualização disponível';

  @override
  String get update_available_desc =>
      'Uma nova versão do aplicativo está disponível';

  @override
  String get no_update_available => 'App atualizado';

  @override
  String get no_update_available_desc =>
      'Você está usando a versão mais recente';

  @override
  String get update_now => 'Atualizar agora';

  @override
  String get update_later => 'Mais tarde';

  @override
  String get checking_for_updates => 'Verificando atualizações...';

  @override
  String get update_error => 'Erro ao verificar atualizações';

  @override
  String get update_downloading => 'Baixando...';

  @override
  String get update_installing => 'Instalando...';

  @override
  String get update_feature_android_only =>
      'Recurso disponível apenas no Android com Google Play Store';

  @override
  String get update_recommendation_title => 'Atualização recomendada';

  @override
  String get update_recommendation_desc =>
      'Uma nova versão do Caravella está disponível. Atualize o aplicativo para ter sempre os recursos e melhorias mais recentes!';

  @override
  String get update_install => 'Instalar atualização';

  @override
  String get update_remind_later => 'Lembrar mais tarde';

  @override
  String get send_reminder => 'Enviar lembrete';

  @override
  String reminder_message_single(
    Object participantName,
    Object amount,
    Object creditorName,
    Object groupName,
  ) {
    return 'Oi $participantName! 👋\n\nGostaria de lembrar que você deve $amount a $creditorName para o grupo \"$groupName\".\n\nObrigado! 😊';
  }

  @override
  String reminder_message_multiple(
    Object participantName,
    Object groupName,
    Object debtsList,
  ) {
    return 'Oi $participantName! 👋\n\nGostaria de lembrar seus pagamentos para o grupo \"$groupName\":\n\n$debtsList\n\nObrigado! 😊';
  }

  @override
  String get notification_enabled => 'Notificação persistente';

  @override
  String get notification_enabled_desc =>
      'Mostra as despesas de hoje em uma notificação sempre visível';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Despesas de hoje: $amount $currency';
  }

  @override
  String notification_total_spent(String amount, String currency) {
    return 'Total: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Adicionar Despesa';

  @override
  String get notification_close => 'Fechar';

  @override
  String get group_type => 'Tipo';

  @override
  String get group_type_description => 'Escolha o tipo de grupo';

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
  String get category_other_utilities => 'Utilidades';

  @override
  String get category_other_services => 'Serviços';

  @override
  String get attachments => 'Anexos';

  @override
  String get add_attachment => 'Adicionar anexo';

  @override
  String get attachment_limit_reached => 'Limite máximo de 5 anexos atingido';

  @override
  String get delete_attachment => 'Excluir anexo';

  @override
  String get share_attachment => 'Compartilhar anexo';

  @override
  String get delete_attachment_confirm_title => 'Excluir anexo';

  @override
  String get delete_attachment_confirm_message =>
      'Tem certeza de que deseja excluir este anexo?';

  @override
  String get attachment_source => 'Escolher fonte';

  @override
  String get from_files => 'Dos arquivos';

  @override
  String get archived_group_readonly => 'Grupo arquivado - Somente leitura';

  @override
  String get archived_group_readonly_desc =>
      'Este grupo está arquivado. Você não pode modificá-lo ou adicionar novas despesas.';

  @override
  String get expense_readonly => 'Despesa - Somente leitura';

  @override
  String get expense_readonly_archived =>
      'Esta despesa pertence a um grupo arquivado e não pode ser modificada.';

  @override
  String get expense => 'Despesa';

  @override
  String get notification_disable => 'Desativar';

  @override
  String get load_more_expenses => 'Carregar mais despesas';

  @override
  String get wizard_group_creation_title => 'Novo Grupo';

  @override
  String get wizard_step_name => 'Nome';

  @override
  String get wizard_step_type_and_name => 'Tipo e Nome';

  @override
  String get wizard_type_and_name_description => 'Para que é este grupo?';

  @override
  String get wizard_step_participants => 'Participantes';

  @override
  String get wizard_step_categories => 'Categorias';

  @override
  String get wizard_step_period => 'Período';

  @override
  String get wizard_step_background => 'Fundo';

  @override
  String get wizard_step_congratulations => 'Parabéns!';

  @override
  String get wizard_step_of => 'de';

  @override
  String get wizard_next => 'Próximo';

  @override
  String get wizard_previous => 'Anterior';

  @override
  String get wizard_skip => 'Pular';

  @override
  String get wizard_finish => 'Criar Grupo';

  @override
  String get wizard_name_description => 'Nome';

  @override
  String get wizard_participants_description =>
      'Adicione pessoas que compartilharão despesas';

  @override
  String get wizard_categories_description =>
      'Crie categorias para organizar despesas';

  @override
  String get wizard_period_description =>
      'Defina datas de início e fim (opcional)';

  @override
  String get wizard_background_description =>
      'Escolha uma cor de fundo para o grupo';

  @override
  String wizard_congratulations_message(String groupName) {
    return 'Seu grupo \'$groupName\' foi criado com sucesso!';
  }

  @override
  String get wizard_group_summary => 'Resumo do grupo:';

  @override
  String wizard_created_participants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '1 participante',
    );
    return '$_temp0';
  }

  @override
  String wizard_created_categories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categorias',
      one: '1 categoria',
    );
    return '$_temp0';
  }

  @override
  String get wizard_step_user_name => 'Seu nome';

  @override
  String get wizard_user_name_welcome => 'Bem-vindo!';

  @override
  String get wizard_user_name_description =>
      'Antes de começar, diga-nos seu nome para personalizar sua experiência';

  @override
  String get wizard_user_name_local_storage_note =>
      'Seus dados permanecem privados no seu dispositivo';

  @override
  String get wizard_user_name_label => 'Seu nome (opcional)';

  @override
  String get wizard_user_name_hint => 'ex. Pedro';

  @override
  String get wizard_step_participants_and_categories => 'Quem e o quê';

  @override
  String get wizard_participants_and_categories_description =>
      'Defina quem participa e quais despesas serão compartilhadas';

  @override
  String get wizard_participants_section_title => 'Quem está participando?';

  @override
  String get wizard_participants_section_hint =>
      'Adicione amigos ou colegas de quarto. Você pode modificá-los depois.';

  @override
  String get wizard_categories_section_title => 'O que será compartilhado?';

  @override
  String get wizard_categories_section_hint =>
      'Ex. Comida, Acomodação, Transporte. Você pode adicionar ou renomear depois.';

  @override
  String get wizard_step_color_and_final => 'Cor e confirmar';

  @override
  String get wizard_color_and_final_description =>
      'Escolha uma cor para o grupo e revise o resumo';

  @override
  String get wizard_preview_title => 'Visualização do grupo';

  @override
  String get wizard_success_title => 'Parabéns!';

  @override
  String get wizard_go_to_group => 'Ir para o grupo';

  @override
  String get wizard_go_to_settings => 'Configurações do grupo';

  @override
  String get wizard_completion_what_next => 'O que você pode fazer agora:';

  @override
  String get wizard_completion_add_expenses => 'Adicionar despesas';

  @override
  String get wizard_completion_add_expenses_description =>
      'Comece a rastrear as despesas do grupo';

  @override
  String get wizard_completion_customize_group => 'Personalizar grupo';

  @override
  String get wizard_completion_customize_group_description =>
      'Editar participantes, categorias e configurações';

  @override
  String get danger_zone => 'Zona Perigosa';

  @override
  String get danger_zone_desc => 'Arquivar ou excluir este grupo';

  @override
  String get export_options_desc =>
      'Baixar ou compartilhar despesas em vários formatos';

  @override
  String get export_csv_description => 'Formato planilha';

  @override
  String get export_ofx_description => 'Formato bancário';

  @override
  String get export_markdown_description => 'Formato documento';

  @override
  String get save_label => 'Salvar';
}
