// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get developer_section_title => '开发者和支持';

  @override
  String get developer_section_desc => '支持开发者或查看个人资料';

  @override
  String get repo_section_title => '源代码和问题';

  @override
  String get repo_section_desc => '查看源代码或报告问题';

  @override
  String get license_section_title => '许可证';

  @override
  String get license_section_desc => '查看开源许可证';

  @override
  String get weeklyChartBadge => '周';

  @override
  String get monthlyChartBadge => '月';

  @override
  String get weeklyExpensesChart => '每周支出';

  @override
  String get monthlyExpensesChart => '每月支出';

  @override
  String get settings_flag_secure_desc => '防止截屏和录屏';

  @override
  String get settings_flag_secure_title => '安全屏幕';

  @override
  String get settings_privacy => '隐私';

  @override
  String get select_currency => '选择货币';

  @override
  String get select_period_hint_short => '设置日期';

  @override
  String get select_period_hint => '选择日期范围';

  @override
  String get in_group_prefix => '在';

  @override
  String get save_change_expense => '保存更改';

  @override
  String get group_total => '总计';

  @override
  String get total_spent => '总支出';

  @override
  String get download_all_csv => '下载全部 (CSV)';

  @override
  String get share_all_csv => '分享全部 (CSV)';

  @override
  String get download_all_ofx => '下载全部 (OFX)';

  @override
  String get share_all_ofx => '分享全部 (OFX)';

  @override
  String get share_label => '分享';

  @override
  String get share_text_label => '分享文本';

  @override
  String get share_image_label => '分享图片';

  @override
  String get export_share => '导出和分享';

  @override
  String get contribution_percentages => '百分比';

  @override
  String get contribution_percentages_desc => '每位成员支付的总额占比';

  @override
  String get export_options => '导出选项';

  @override
  String get welcome_v3_title => '组织。\n分享。\n结算。\n ';

  @override
  String get good_morning => '早上好';

  @override
  String get good_afternoon => '下午好';

  @override
  String get good_evening => '晚上好';

  @override
  String get your_groups => '您的群组';

  @override
  String get no_active_groups => '没有活跃的群组';

  @override
  String get no_active_groups_subtitle => '创建费用群组';

  @override
  String get create_first_group => '创建您的第一个群组';

  @override
  String get new_expense_group => 'New Expense Group';

  @override
  String get tap_to_create => 'Tap to create';

  @override
  String get no_expense_label => 'No expenses found';

  @override
  String get image => 'Image';

  @override
  String get select_image => 'Select Image';

  @override
  String get change_image => 'Change Image';

  @override
  String get from_gallery => 'From Gallery';

  @override
  String get from_camera => 'From Camera';

  @override
  String get remove_image => 'Remove Image';

  @override
  String get cannot_delete_assigned_participant =>
      'Cannot delete participant: it\'s assigned to one or more expenses';

  @override
  String get cannot_delete_assigned_category =>
      'Cannot delete category: it\'s assigned to one or more expenses';

  @override
  String get color => 'Color';

  @override
  String get remove_color => 'Remove Color';

  @override
  String get color_alternative => 'Alternative to image';

  @override
  String get background => 'Background';

  @override
  String get select_background => 'Select Background';

  @override
  String get background_options => 'Background Options';

  @override
  String get choose_image_or_color => 'Choose image or color';

  @override
  String get participants_description => 'People sharing costs';

  @override
  String get categories_description => 'Group expenses by type';

  @override
  String get dates_description => 'Optional start and end';

  @override
  String get currency_description => 'Base currency for group';

  @override
  String get background_color_selected => 'Color selected';

  @override
  String get background_tap_to_replace => 'Tap to replace';

  @override
  String get background_tap_to_change => 'Tap to change';

  @override
  String get background_select_image_or_color => 'Select image or color';

  @override
  String get background_random_color => 'Random color';

  @override
  String get background_remove => 'Remove background';

  @override
  String get crop_image_title => 'Crop image';

  @override
  String get crop_confirm => 'Confirm';

  @override
  String get saving => 'Saving...';

  @override
  String get processing_image => 'Processing image...';

  @override
  String get no_trips_found => 'Where do you want to go?';

  @override
  String get expenses => '支出';

  @override
  String get participants => '参与者';

  @override
  String participant_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 名参与者',
    );
    return '$_temp0';
  }

  @override
  String get participants_label => 'Participants';

  @override
  String get last_7_days => '7 days';

  @override
  String get recent_activity => 'Recent activity';

  @override
  String get about => 'About';

  @override
  String get license_hint => 'This app is released under the MIT license.';

  @override
  String get license_link => 'View MIT License on GitHub';

  @override
  String get license_section => 'License';

  @override
  String get add_trip => 'Add group';

  @override
  String get new_group => 'New Group';

  @override
  String get group_name => '群组名称';

  @override
  String get enter_title => 'Enter a name';

  @override
  String get enter_participant => 'Enter at least one participant';

  @override
  String get select_start => 'Select start';

  @override
  String get select_end => 'Select end';

  @override
  String get start_date_not_selected => 'Select start';

  @override
  String get end_date_not_selected => 'Select end';

  @override
  String get select_from_date => 'Select from';

  @override
  String get select_to_date => 'Select to';

  @override
  String get date_range_not_selected => 'Select period';

  @override
  String get date_range_partial => 'Select both dates';

  @override
  String get save => '保存';

  @override
  String get delete_trip => 'Delete trip';

  @override
  String get delete_trip_confirm =>
      'Are you sure you want to delete this trip?';

  @override
  String get cancel => '取消';

  @override
  String get ok => 'OK';

  @override
  String from_to(Object end, Object start) {
    return '$start - $end';
  }

  @override
  String get add_expense => '添加支出';

  @override
  String get edit_expense => 'Edit expense';

  @override
  String get expand_form => 'Expand form';

  @override
  String get expand_form_tooltip => 'Add date, location and notes';

  @override
  String get category => '类别';

  @override
  String get amount => '金额';

  @override
  String get invalid_amount => 'Invalid amount';

  @override
  String get no_categories => '无类别';

  @override
  String get add_category => '添加类别';

  @override
  String get category_name => 'Category name';

  @override
  String get note => 'Note';

  @override
  String get note_hint => 'Note';

  @override
  String get select_both_dates =>
      'If you select one date, you must select both';

  @override
  String get select_both_dates_or_none =>
      'Select both dates or leave both empty';

  @override
  String get end_date_after_start => 'End date must be after start date';

  @override
  String get start_date_optional => 'From';

  @override
  String get end_date_optional => 'To';

  @override
  String get dates => 'Period';

  @override
  String get expenses_by_participant => 'By participant';

  @override
  String get expenses_by_category => 'By category';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'No trips to backup';

  @override
  String get backup_error => '备份失败';

  @override
  String get backup_share_message => 'Here is your Caravella backup';

  @override
  String get import => 'Import';

  @override
  String get import_confirm_title => '导入数据';

  @override
  String import_confirm_message(Object file) {
    return '确定要用文件 \"$file\" 覆盖所有行程吗？此操作无法撤销。';
  }

  @override
  String get import_success => '导入成功！数据已重新加载。';

  @override
  String get import_error => '导入失败。请检查文件格式。';

  @override
  String get categories => '类别';

  @override
  String get from => '从';

  @override
  String get to => '到';

  @override
  String get add => '添加';

  @override
  String get participant_name => '参与者姓名';

  @override
  String get participant_name_hint => '输入参与者姓名';

  @override
  String get edit_participant => '编辑参与者';

  @override
  String get delete_participant => '删除参与者';

  @override
  String get add_participant => '添加参与者';

  @override
  String get no_participants => '无参与者';

  @override
  String get category_name_hint => '输入类别名称';

  @override
  String get edit_category => '编辑类别';

  @override
  String get delete_category => '删除类别';

  @override
  String participant_name_semantics(Object name) {
    return 'Participant: $name';
  }

  @override
  String category_name_semantics(Object name) {
    return 'Category: $name';
  }

  @override
  String get currency => 'Currency';

  @override
  String get settings_tab => 'Settings';

  @override
  String get basic_info => 'Basic Information';

  @override
  String get settings => '设置';

  @override
  String get history => 'History';

  @override
  String get all => 'ALL';

  @override
  String get search_groups => 'Search groups...';

  @override
  String get no_search_results => 'No groups found for';

  @override
  String get try_different_search => 'Try searching with different words';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get archive_confirm => 'Do you want to archive';

  @override
  String get unarchive_confirm => 'Do you want to unarchive';

  @override
  String get overview => 'Overview';

  @override
  String get statistics => 'Statistics';

  @override
  String get options => 'Options';

  @override
  String get show_overview => 'Show overview';

  @override
  String get show_statistics => 'Show statistics';

  @override
  String get no_expenses_to_display => 'No expenses to display';

  @override
  String get no_expenses_to_analyze => 'No expenses to analyze';

  @override
  String get select_expense_date => 'Select expense date';

  @override
  String get select_expense_date_short => 'Select date';

  @override
  String get date => '日期';

  @override
  String get edit_group => 'Edit Group';

  @override
  String get delete_group => 'Delete group';

  @override
  String get delete_group_confirm =>
      'Are you sure you want to delete this expense group? This action cannot be undone.';

  @override
  String get add_expense_fab => 'Add Expense';

  @override
  String get pin_group => 'Pin group';

  @override
  String get unpin_group => 'Unpin group';

  @override
  String get pin => 'Pin';

  @override
  String get theme_automatic => '自动';

  @override
  String get theme_light => '浅色';

  @override
  String get theme_dark => '深色';

  @override
  String get developed_by => 'Developed by calca';

  @override
  String get links => 'Links';

  @override
  String get daily_expenses_chart => 'Daily expenses';

  @override
  String get weekly_expenses_chart => 'Weekly expenses';

  @override
  String get daily_average_by_category => 'Daily average by category';

  @override
  String get per_day => '/day';

  @override
  String get no_expenses_for_statistics =>
      'No expenses available for statistics';

  @override
  String get settlement => 'Settlement';

  @override
  String get all_balanced => 'All accounts are balanced!';

  @override
  String get owes_to => ' owes ';

  @override
  String get export_csv => 'Export CSV';

  @override
  String get no_expenses_to_export => 'No expenses to export';

  @override
  String get export_csv_share_text => 'Expenses exported from ';

  @override
  String get export_csv_error => 'Error exporting expenses';

  @override
  String get expense_name => 'Description';

  @override
  String get paid_by => '付款人';

  @override
  String get expense_added_success => 'Expense added';

  @override
  String get expense_updated_success => 'Expense updated';

  @override
  String get data_refreshing => 'Refreshing…';

  @override
  String get data_refreshed => 'Updated';

  @override
  String get refresh => '刷新';

  @override
  String get group_added_success => '群组已添加';

  @override
  String get csv_select_directory_title => '选择保存 CSV 的文件夹';

  @override
  String csv_saved_in(Object path) {
    return 'CSV 已保存在：$path';
  }

  @override
  String get csv_save_cancelled => '导出已取消';

  @override
  String get csv_save_error => '保存 CSV 文件时出错';

  @override
  String get ofx_select_directory_title => '选择保存 OFX 的文件夹';

  @override
  String ofx_saved_in(Object path) {
    return 'OFX 已保存在：$path';
  }

  @override
  String get ofx_save_cancelled => 'OFX 导出已取消';

  @override
  String get ofx_save_error => '保存 OFX 文件时出错';

  @override
  String get csv_expense_name => '描述';

  @override
  String get csv_amount => '金额';

  @override
  String get csv_paid_by => '付款人';

  @override
  String get csv_category => '类别';

  @override
  String get csv_date => '日期';

  @override
  String get csv_note => 'Note';

  @override
  String get csv_location => 'Location';

  @override
  String get location => 'Location';

  @override
  String get location_hint => 'Location';

  @override
  String get get_current_location => 'Use current location';

  @override
  String get enter_location_manually => 'Enter manually';

  @override
  String get location_permission_denied => 'Location permission denied';

  @override
  String get location_service_disabled => 'Location service disabled';

  @override
  String get getting_location => 'Getting location...';

  @override
  String get location_error => 'Error getting location';

  @override
  String get resolving_address => 'Resolving address…';

  @override
  String get address_resolved => 'Address resolved';

  @override
  String get settings_general => '一般';

  @override
  String get settings_general_desc => '应用程序通用设置';

  @override
  String get settings_language => '语言';

  @override
  String get settings_language_desc => '选择您的首选语言';

  @override
  String get settings_language_it => '意大利语';

  @override
  String get settings_language_en => '英语';

  @override
  String get settings_language_es => '西班牙语';

  @override
  String get settings_language_pt => 'Portuguese';

  @override
  String get settings_language_zh => '中文（简体）';

  @override
  String get settings_select_language => '选择语言';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_theme_desc => '选择应用主题';

  @override
  String get settings_select_theme => '选择主题';

  @override
  String get settings_privacy_desc => '安全和隐私选项';

  @override
  String get settings_data => '数据';

  @override
  String get settings_data_desc => '管理和备份数据';

  @override
  String get settings_data_manage => '管理数据';

  @override
  String get settings_info => '信息';

  @override
  String get settings_info_desc => '应用程序信息和版本';

  @override
  String get settings_app_version => '应用版本';

  @override
  String get settings_info_card => '应用信息';

  @override
  String get settings_info_card_desc => '查看应用信息和版本';

  @override
  String get terms_github_title => 'GitHub: calca';

  @override
  String get terms_github_desc => 'Developer profile on GitHub.';

  @override
  String get terms_repo_title => 'GitHub Repository';

  @override
  String get terms_repo_desc => 'Application source code.';

  @override
  String get terms_issue_title => 'Report a problem';

  @override
  String get terms_issue_desc => 'Go to the GitHub issues page.';

  @override
  String get terms_license_desc => 'View the open source license.';

  @override
  String get support_developer_title => 'Buy me a coffee';

  @override
  String get support_developer_desc => 'Support the development of this app.';

  @override
  String get data_title => 'Backup & Restore';

  @override
  String get data_backup_title => 'Backup';

  @override
  String get data_backup_desc => 'Create a backup file of your expenses.';

  @override
  String get data_restore_title => 'Restore';

  @override
  String get data_restore_desc => 'Import a backup to restore your data.';

  @override
  String get auto_backup_title => 'Automatic backup';

  @override
  String get auto_backup_desc => 'Enable operating system automatic backup';

  @override
  String get settings_user_name_title => 'Your name';

  @override
  String get settings_user_name_desc => 'Name or nickname to use in the app';

  @override
  String get settings_user_name_hint => 'Enter your name';

  @override
  String get info_tab => 'Info';

  @override
  String get select_paid_by => 'Select payer';

  @override
  String get select_category => 'Select a category';

  @override
  String get check_form => 'Check the entered data';

  @override
  String get delete_expense => 'Delete expense';

  @override
  String get delete_expense_confirm =>
      'Are you sure you want to delete this expense?';

  @override
  String get delete => '删除';

  @override
  String get no_results_found => 'No results found.';

  @override
  String get try_adjust_filter_or_search =>
      'Try adjusting the filter or search.';

  @override
  String get general_statistics => 'General statistics';

  @override
  String get add_first_expense => '添加您的第一笔支出';

  @override
  String get overview_and_statistics => 'Overview and statistics';

  @override
  String get daily_average => '每日';

  @override
  String get spent_today => 'Today';

  @override
  String get monthly_average => '每月';

  @override
  String get average_expense => 'Average expense';

  @override
  String get welcome_v3_cta => 'Get started!';

  @override
  String get discard_changes_title => 'Discard changes?';

  @override
  String get discard_changes_message =>
      'Are you sure you want to discard unsaved changes?';

  @override
  String get discard => 'Discard';

  @override
  String get category_placeholder => 'Category';

  @override
  String get image_requirements => 'PNG, JPG, GIF (max 10MB)';

  @override
  String error_saving_group(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get error_selecting_image => 'Error selecting image';

  @override
  String get error_saving_image => 'Error saving image';

  @override
  String get already_exists => 'already exists';

  @override
  String get status_all => 'All';

  @override
  String get status_active => 'Active';

  @override
  String get status_archived => 'Archived';

  @override
  String get no_archived_groups => 'No archived groups';

  @override
  String get no_archived_groups_subtitle =>
      'You have not archived any groups yet';

  @override
  String get all_groups_archived_info =>
      'All your groups are archived. You can restore them from the Archive section or create new ones.';

  @override
  String get filter_status_tooltip => 'Filter groups';

  @override
  String get welcome_logo_semantic => 'Caravella app logo';

  @override
  String get create_new_group => 'Create new group';

  @override
  String get accessibility_add_new_item => 'Add new item';

  @override
  String get accessibility_navigation_bar => 'Navigation bar';

  @override
  String get accessibility_back_button => 'Back';

  @override
  String get accessibility_loading_groups => 'Loading groups';

  @override
  String get accessibility_loading_your_groups => 'Loading your groups';

  @override
  String get accessibility_groups_list => 'Groups list';

  @override
  String get accessibility_welcome_screen => 'Welcome screen';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Total expenses: $amount€';
  }

  @override
  String get accessibility_add_expense => 'Add expense';

  @override
  String accessibility_security_switch(Object state) {
    return '安全开关';
  }

  @override
  String get accessibility_switch_on => '开关开启';

  @override
  String get accessibility_switch_off => '开关关闭';

  @override
  String get accessibility_image_source_dialog =>
      'Image source selection dialog';

  @override
  String get accessibility_currently_enabled => '当前已启用';

  @override
  String get accessibility_currently_disabled => '当前已禁用';

  @override
  String get accessibility_double_tap_disable => '双击以禁用';

  @override
  String get accessibility_double_tap_enable => '双击以启用';

  @override
  String get accessibility_toast_success => 'Success';

  @override
  String get accessibility_toast_error => 'Error';

  @override
  String get accessibility_toast_info => 'Information';

  @override
  String get color_suggested_title => 'Suggested colors';

  @override
  String get color_suggested_subtitle =>
      'Pick one of the theme compatible colors';

  @override
  String get color_random_subtitle => 'Let the app pick a color for you';

  @override
  String get currency_AED => '阿联酋迪拉姆';

  @override
  String get currency_AFN => '阿富汗尼';

  @override
  String get currency_ALL => '阿尔巴尼亚列克';

  @override
  String get currency_AMD => '亚美尼亚德拉姆';

  @override
  String get currency_ANG => 'Netherlands Antillean Guilder';

  @override
  String get currency_AOA => '安哥拉宽扎';

  @override
  String get currency_ARS => '阿根廷比索';

  @override
  String get currency_AUD => '澳大利亚元';

  @override
  String get currency_AWG => '阿鲁巴弗罗林';

  @override
  String get currency_AZN => '阿塞拜疆马纳特';

  @override
  String get currency_BAM => '波黑可兑换马克';

  @override
  String get currency_BBD => '巴巴多斯元';

  @override
  String get currency_BDT => '孟加拉塔卡';

  @override
  String get currency_BGN => '保加利亚列弗';

  @override
  String get currency_BHD => '巴林第纳尔';

  @override
  String get currency_BIF => '布隆迪法郎';

  @override
  String get currency_BMD => '百慕大元';

  @override
  String get currency_BND => '文莱元';

  @override
  String get currency_BOB => '玻利维亚诺';

  @override
  String get currency_BRL => '巴西雷亚尔';

  @override
  String get currency_BSD => '巴哈马元';

  @override
  String get currency_BTN => '不丹努尔特鲁姆';

  @override
  String get currency_BWP => '博茨瓦纳普拉';

  @override
  String get currency_BYN => '白俄罗斯卢布';

  @override
  String get currency_BZD => '伯利兹元';

  @override
  String get currency_CAD => '加拿大元';

  @override
  String get currency_CDF => '刚果法郎';

  @override
  String get currency_CHF => '瑞士法郎';

  @override
  String get currency_CLP => '智利比索';

  @override
  String get currency_CNY => '人民币';

  @override
  String get currency_COP => '哥伦比亚比索';

  @override
  String get currency_CRC => '哥斯达黎加科朗';

  @override
  String get currency_CUP => '古巴比索';

  @override
  String get currency_CVE => '佛得角埃斯库多';

  @override
  String get currency_CZK => '捷克克朗';

  @override
  String get currency_DJF => '吉布提法郎';

  @override
  String get currency_DKK => '丹麦克朗';

  @override
  String get currency_DOP => '多米尼加比索';

  @override
  String get currency_DZD => '阿尔及利亚第纳尔';

  @override
  String get currency_EGP => '埃及镑';

  @override
  String get currency_ERN => '厄立特里亚纳克法';

  @override
  String get currency_ETB => '埃塞俄比亚比尔';

  @override
  String get currency_EUR => '欧元';

  @override
  String get currency_FJD => '斐济元';

  @override
  String get currency_FKP => '福克兰群岛镑';

  @override
  String get currency_GBP => '英镑';

  @override
  String get currency_GEL => '格鲁吉亚拉里';

  @override
  String get currency_GHS => '加纳塞地';

  @override
  String get currency_GIP => '直布罗陀镑';

  @override
  String get currency_GMD => '冈比亚达拉西';

  @override
  String get currency_GNF => '几内亚法郎';

  @override
  String get currency_GTQ => '危地马拉格查尔';

  @override
  String get currency_GYD => '圭亚那元';

  @override
  String get currency_HKD => '港币';

  @override
  String get currency_HNL => '洪都拉斯伦皮拉';

  @override
  String get currency_HTG => '海地古德';

  @override
  String get currency_HUF => '匈牙利福林';

  @override
  String get currency_IDR => '印尼盾';

  @override
  String get currency_ILS => '以色列新谢克尔';

  @override
  String get currency_INR => '印度卢比';

  @override
  String get currency_IQD => '伊拉克第纳尔';

  @override
  String get currency_IRR => '伊朗里亚尔';

  @override
  String get currency_ISK => '冰岛克朗';

  @override
  String get currency_JMD => '牙买加元';

  @override
  String get currency_JOD => '约旦第纳尔';

  @override
  String get currency_JPY => '日元';

  @override
  String get currency_KES => '肯尼亚先令';

  @override
  String get currency_KGS => '吉尔吉斯斯坦索姆';

  @override
  String get currency_KHR => '柬埔寨瑞尔';

  @override
  String get currency_KID => 'Kiribati Dollar';

  @override
  String get currency_KMF => '科摩罗法郎';

  @override
  String get currency_KPW => '朝鲜圆';

  @override
  String get currency_KRW => '韩元';

  @override
  String get currency_KWD => '科威特第纳尔';

  @override
  String get currency_KYD => 'Cayman Islands Dollar';

  @override
  String get currency_KZT => '哈萨克斯坦坚戈';

  @override
  String get currency_LAK => '老挝基普';

  @override
  String get currency_LBP => '黎巴嫩镑';

  @override
  String get currency_LKR => '斯里兰卡卢比';

  @override
  String get currency_LRD => '利比里亚元';

  @override
  String get currency_LSL => '莱索托洛蒂';

  @override
  String get currency_LYD => '利比亚第纳尔';

  @override
  String get currency_MAD => '摩洛哥迪拉姆';

  @override
  String get currency_MDL => '摩尔多瓦列伊';

  @override
  String get currency_MGA => '马达加斯加阿里亚里';

  @override
  String get currency_MKD => '北马其顿第纳尔';

  @override
  String get currency_MMK => '缅甸缅元';

  @override
  String get currency_MNT => '蒙古图格里克';

  @override
  String get currency_MOP => '澳门帕塔卡';

  @override
  String get currency_MRU => '毛里塔尼亚乌吉亚';

  @override
  String get currency_MUR => '毛里求斯卢比';

  @override
  String get currency_MVR => '马尔代夫拉菲亚';

  @override
  String get currency_MWK => '马拉维克瓦查';

  @override
  String get currency_MXN => '墨西哥比索';

  @override
  String get currency_MYR => '马来西亚林吉特';

  @override
  String get currency_MZN => '莫桑比克梅蒂卡尔';

  @override
  String get currency_NAD => '纳米比亚元';

  @override
  String get currency_NGN => '尼日利亚奈拉';

  @override
  String get currency_NIO => '尼加拉瓜科多巴';

  @override
  String get currency_NOK => '挪威克朗';

  @override
  String get currency_NPR => '尼泊尔卢比';

  @override
  String get currency_NZD => 'New Zealand Dollar';

  @override
  String get currency_OMR => '阿曼里亚尔';

  @override
  String get currency_PAB => '巴拿马巴波亚';

  @override
  String get currency_PEN => '秘鲁索尔';

  @override
  String get currency_PGK => '巴布亚新几内亚基那';

  @override
  String get currency_PHP => '菲律宾比索';

  @override
  String get currency_PKR => '巴基斯坦卢比';

  @override
  String get currency_PLN => '波兰兹罗提';

  @override
  String get currency_PYG => '巴拉圭瓜拉尼';

  @override
  String get currency_QAR => '卡塔尔里亚尔';

  @override
  String get currency_RON => '罗马尼亚列伊';

  @override
  String get currency_RSD => 'Serbian Dinar';

  @override
  String get currency_RUB => '俄罗斯卢布';

  @override
  String get currency_RWF => '卢旺达法郎';

  @override
  String get currency_SAR => '沙特里亚尔';

  @override
  String get currency_SBD => '所罗门群岛元';

  @override
  String get currency_SCR => '塞舌尔卢比';

  @override
  String get currency_SDG => '苏丹镑';

  @override
  String get currency_SEK => '瑞典克朗';

  @override
  String get currency_SGD => '新加坡元';

  @override
  String get currency_SHP => '圣赫勒拿镑';

  @override
  String get currency_SLE => '塞拉利昂利昂';

  @override
  String get currency_SLL => 'Sierra Leonean Leone (old)';

  @override
  String get currency_SOS => '索马里先令';

  @override
  String get currency_SRD => '苏里南元';

  @override
  String get currency_SSP => '南苏丹镑';

  @override
  String get currency_STN => '圣多美和普林西比多布拉';

  @override
  String get currency_SVC => '萨尔瓦多科朗';

  @override
  String get currency_SYP => '叙利亚镑';

  @override
  String get currency_SZL => '斯威士兰里兰吉尼';

  @override
  String get currency_THB => '泰铢';

  @override
  String get currency_TJS => '塔吉克斯坦索莫尼';

  @override
  String get currency_TMT => '土库曼斯坦马纳特';

  @override
  String get currency_TND => '突尼斯第纳尔';

  @override
  String get currency_TOP => '汤加潘加';

  @override
  String get currency_TRY => '土耳其里拉';

  @override
  String get currency_TTD => '特立尼达和多巴哥元';

  @override
  String get currency_TVD => 'Tuvaluan Dollar';

  @override
  String get currency_TWD => '新台币';

  @override
  String get currency_TZS => '坦桑尼亚先令';

  @override
  String get currency_UAH => '乌克兰格里夫纳';

  @override
  String get currency_UGX => '乌干达先令';

  @override
  String get currency_USD => '美元';

  @override
  String get currency_UYU => '乌拉圭比索';

  @override
  String get currency_UZS => '乌兹别克斯坦苏姆';

  @override
  String get currency_VED => 'Venezuelan Digital Bolívar';

  @override
  String get currency_VES => '委内瑞拉玻利瓦尔';

  @override
  String get currency_VND => '越南盾';

  @override
  String get currency_VUV => '瓦努阿图瓦图';

  @override
  String get currency_WST => 'Samoan Tala';

  @override
  String get currency_XAF => '中非法郎';

  @override
  String get currency_XOF => '西非法郎';

  @override
  String get currency_XPF => '太平洋法郎';

  @override
  String get currency_YER => '也门里亚尔';

  @override
  String get currency_ZAR => '南非兰特';

  @override
  String get currency_ZMW => '赞比亚克瓦查';

  @override
  String get currency_ZWL => '津巴布韦元';

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
  String get all_participants => '所有参与者';

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
  String get add_first_expense_button => '添加支出';

  @override
  String get show_search => '显示搜索栏';

  @override
  String get hide_search => '隐藏搜索栏';

  @override
  String get expense_groups_title => '支出群组';

  @override
  String get expense_groups_desc => '管理您的支出群组';

  @override
  String get whats_new_title => '新功能';

  @override
  String get whats_new_desc => '了解最新功能和更新';
}
