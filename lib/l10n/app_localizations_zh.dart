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
  String get repo_section_title => '代码和问题反馈';

  @override
  String get license_section_title => '许可证';

  @override
  String get weeklyChartBadge => '周';

  @override
  String get monthlyChartBadge => '月';

  @override
  String get dateRangeChartBadge => '日';

  @override
  String get weeklyExpensesChart => '每周支出';

  @override
  String get monthlyExpensesChart => '每月支出';

  @override
  String get dateRangeExpensesChart => '期间支出';

  @override
  String get settings_flag_secure_desc => '禁止截屏和录屏';

  @override
  String get settings_flag_secure_title => '安全屏幕';

  @override
  String get settings_app_functions_title => 'AI助手访问';

  @override
  String get settings_app_functions_desc => '使用 Gemini 等 AI 助手';

  @override
  String get select_currency => '货币';

  @override
  String days_count(int count) {
    return '$count天';
  }

  @override
  String get weekday_mon => '一';

  @override
  String get weekday_tue => '二';

  @override
  String get weekday_wed => '三';

  @override
  String get weekday_thu => '四';

  @override
  String get weekday_fri => '五';

  @override
  String get weekday_sat => '六';

  @override
  String get weekday_sun => '日';

  @override
  String get month_january => '一月';

  @override
  String get month_february => '二月';

  @override
  String get month_march => '三月';

  @override
  String get month_april => '四月';

  @override
  String get month_may => '五月';

  @override
  String get month_june => '六月';

  @override
  String get month_july => '七月';

  @override
  String get month_august => '八月';

  @override
  String get month_september => '九月';

  @override
  String get month_october => '十月';

  @override
  String get month_november => '十一月';

  @override
  String get month_december => '十二月';

  @override
  String get in_group_prefix => '在';

  @override
  String get group_total => '总计';

  @override
  String get markdown_select_directory_title => '选择保存 Markdown 的文件夹';

  @override
  String markdown_saved_in(String path) {
    return 'Markdown 已保存至: $path';
  }

  @override
  String get markdown_save_cancelled => 'Markdown 导出已取消';

  @override
  String get markdown_save_error => '保存 Markdown 文件时出错';

  @override
  String get share_label => '分享';

  @override
  String get export_share => '分享和导出';

  @override
  String get export_options => '导出支出';

  @override
  String get welcome_v3_title => '组织。\n分享。\n结算。\n ';

  @override
  String get good_morning => '早上好';

  @override
  String get good_afternoon => '下午好';

  @override
  String get good_evening => '晚上好';

  @override
  String get see_all => '查看全部';

  @override
  String get view_all_groups => '查看所有群组';

  @override
  String get no_active_groups => '没有活跃的群组';

  @override
  String get create_first_group => '创建您的第一个群组';

  @override
  String get new_expense_group => '新建';

  @override
  String get new_expense => '新建支出';

  @override
  String get image => '照片';

  @override
  String get change_image => '更换照片';

  @override
  String get from_gallery => '从图库选择';

  @override
  String get from_camera => '拍照';

  @override
  String get cannot_delete_assigned_participant => '无法删除参与者: 已分配给一个或多个支出';

  @override
  String get cannot_delete_assigned_category => '无法删除类别: 已分配给一个或多个支出';

  @override
  String get color => '颜色';

  @override
  String get background => '背景';

  @override
  String get participants_description => '共享费用的人员';

  @override
  String get categories_description => '按类型对群组支出进行分组';

  @override
  String get dates_description => '开始和结束日期（可选）';

  @override
  String get select_period => '期间';

  @override
  String get suggested_duration => '建议时长';

  @override
  String get confirm => '确认';

  @override
  String get clear => '移除';

  @override
  String get background_color_selected => '颜色已选择';

  @override
  String get background_tap_to_replace => '点击替换';

  @override
  String get background_tap_to_change => '点击更换';

  @override
  String get background_select_image_or_color => '选择照片或颜色';

  @override
  String get background_random_color => '随机颜色';

  @override
  String get background_remove => '删除背景';

  @override
  String get crop_image_title => '裁剪照片';

  @override
  String get crop_confirm => '确认';

  @override
  String get saving => '正在保存…';

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
  String get participants_label => '参与者';

  @override
  String get last_7_days => '最近7天';

  @override
  String get today => '今天';

  @override
  String get this_month => '本月';

  @override
  String get recent_expenses => '最近支出';

  @override
  String get license_link => '在GitHub上查看MIT许可证';

  @override
  String get add_trip => '添加群组';

  @override
  String get group => '群组';

  @override
  String get create => '创建';

  @override
  String get group_name => '群组名称';

  @override
  String get enter_title => '输入名称';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get add_expense => '添加支出';

  @override
  String get edit_expense => '编辑支出';

  @override
  String get expand_form => '展开表单';

  @override
  String get expand_form_tooltip => '添加日期, 位置和备注';

  @override
  String get category => '类别';

  @override
  String get amount => '金额';

  @override
  String get invalid_amount => '无效金额';

  @override
  String get add_category => '添加类别';

  @override
  String get category_name => '类别名称';

  @override
  String get note => '备注';

  @override
  String get note_hint => '备注';

  @override
  String get select_both_dates => '如果选择一个日期, 则必须选择两个日期';

  @override
  String get end_date_after_start => '结束日期必须在开始日期之后';

  @override
  String get expenses_by_participant => '按参与者';

  @override
  String get expenses_by_category => '按类别分类的支出';

  @override
  String get uncategorized => '未分类';

  @override
  String get backup => '备份';

  @override
  String get no_trips_to_backup => '没有可备份的群组';

  @override
  String get backup_error => '备份失败';

  @override
  String get backup_share_message => '这是您的Caravella备份';

  @override
  String get import_confirm_title => '导入数据';

  @override
  String import_confirm_message(Object file) {
    return '从文件“$file”恢复？当前群组将被替换，且无法撤销。';
  }

  @override
  String get import_success => '数据已恢复';

  @override
  String get import_error => '恢复失败：请检查文件';

  @override
  String get settings_flag_secure_error => '无法更改屏幕保护设置';

  @override
  String get settings_debug_logs_title => '调试日志';

  @override
  String get settings_debug_logs_desc => '应用日志和错误';

  @override
  String get developer_link_error => '无法打开链接';

  @override
  String get whats_new_load_error => '无法加载新功能介绍';

  @override
  String get categories => '类别';

  @override
  String get other_settings_desc => '通知、位置';

  @override
  String get segment_general => '常规';

  @override
  String get segment_other => '其他';

  @override
  String get from => '从';

  @override
  String get to => '到';

  @override
  String get add => '添加';

  @override
  String get participant_name => '参与者姓名';

  @override
  String get edit_participant => '编辑参与者';

  @override
  String get add_participant => '添加参与者';

  @override
  String get edit_category => '编辑类别';

  @override
  String get currency => '货币';

  @override
  String get settings_tab => '设置';

  @override
  String get settings => '设置';

  @override
  String get history => '历史记录';

  @override
  String get all => '全部';

  @override
  String get search_groups => '搜索群组和支出…';

  @override
  String get no_search_results => '没有结果';

  @override
  String get try_different_search => '尝试使用不同的词搜索';

  @override
  String get active => '活跃';

  @override
  String get archived => '已归档';

  @override
  String get archive => '归档';

  @override
  String get unarchive => '移出归档';

  @override
  String get pin => '收藏';

  @override
  String get unpin => '取消收藏';

  @override
  String get archived_with_undo => '已归档';

  @override
  String get unarchived_with_undo => '已移出归档';

  @override
  String get pinned_with_undo => '已标记为收藏';

  @override
  String get unpinned_with_undo => '已移除收藏';

  @override
  String get deleted_with_undo => '已删除';

  @override
  String get statistics => '统计';

  @override
  String get period => '期间';

  @override
  String get total_expenses => '总支出';

  @override
  String get number_of_expenses => '支出数量';

  @override
  String get select_expense_date => '选择支出日期';

  @override
  String get select_expense_date_short => '选择日期';

  @override
  String get date => '日期';

  @override
  String get delete_group => '删除群组';

  @override
  String get delete_group_confirm => '该群组及其所有支出将被删除，且无法撤销。';

  @override
  String get add_expense_fab => '添加支出';

  @override
  String get pin_group => '标记为收藏';

  @override
  String get unpin_group => '移除收藏';

  @override
  String get theme_automatic => '自动';

  @override
  String get theme_light => '浅色';

  @override
  String get theme_dark => '深色';

  @override
  String get per_day => '/天';

  @override
  String get no_expenses_for_statistics => '没有可用于统计的支出';

  @override
  String get settlement => '结清';

  @override
  String get all_balanced => '大家已两清';

  @override
  String get no_expenses_to_export => '没有可导出的支出';

  @override
  String get expense_name => '描述';

  @override
  String get paid_by => '付款人';

  @override
  String get added_by => '添加者';

  @override
  String get edited_by => '编辑者';

  @override
  String get expense_added_success => '已添加支出';

  @override
  String get expense_updated_success => '支出已更新';

  @override
  String get refresh => '刷新';

  @override
  String get group_added_success => '群组已添加';

  @override
  String get group_deleted_success => '群组已删除';

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
  String get csv_note => '备注';

  @override
  String get csv_location => '位置';

  @override
  String get location => '位置';

  @override
  String get location_hint => '位置';

  @override
  String get get_current_location => '使用当前位置';

  @override
  String get getting_location => '正在获取位置…';

  @override
  String get location_error => '无法获取位置';

  @override
  String get address_resolved => '地址已解析';

  @override
  String get settings_general => '常规';

  @override
  String get settings_auto_location_title => '自动定位';

  @override
  String get settings_auto_location_desc => '记录新支出的地点';

  @override
  String get settings_language => '语言';

  @override
  String get settings_language_it => '意大利语';

  @override
  String get settings_language_en => '英语';

  @override
  String get settings_language_es => '西班牙语';

  @override
  String get settings_language_pt => '葡萄牙语';

  @override
  String get settings_language_zh => '中文（简体）';

  @override
  String get settings_select_language => '语言';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_appearance => '外观';

  @override
  String get settings_appearance_desc => '语言、主题和动态颜色';

  @override
  String get settings_dynamic_color => '动态颜色';

  @override
  String get settings_dynamic_color_desc => '使用壁纸颜色';

  @override
  String get settings_privacy => '隐私';

  @override
  String get settings_data => '数据';

  @override
  String get settings_data_manage => '管理数据';

  @override
  String get settings_info => '信息';

  @override
  String get settings_app_version => '应用版本';

  @override
  String get settings_info_card => '应用信息';

  @override
  String get settings_info_card_desc => '开发者、源代码和许可证';

  @override
  String get settings_invite_friends => '邀请好友';

  @override
  String get settings_invite_friends_desc => '把 Caravella 分享给你的朋友';

  @override
  String get invite_friends_message =>
      '嗨！我在用 Caravella 和朋友们一起记账分摊费用，非常方便 🎒💸 你也来试试吧：https://play.google.com/store/apps/details?id=io.caravella.egm';

  @override
  String get terms_github_title => '网站: calca';

  @override
  String get terms_github_desc => '开发者网站';

  @override
  String get terms_repo_title => 'GitHub仓库';

  @override
  String get terms_repo_desc => '应用源代码';

  @override
  String get terms_issue_title => '报告问题';

  @override
  String get terms_issue_desc => '在 GitHub 上报告问题';

  @override
  String get terms_license_desc => 'MIT 开源许可证';

  @override
  String get support_developer_title => '请我喝杯咖啡';

  @override
  String get support_developer_desc => '支持应用的开发';

  @override
  String get data_title => '备份与恢复';

  @override
  String get data_backup_desc => '将支出保存为文件';

  @override
  String get data_restore_title => '恢复';

  @override
  String get data_restore_desc => '从备份文件恢复';

  @override
  String get auto_backup_title => '自动备份';

  @override
  String get auto_backup_desc => '系统备份';

  @override
  String get settings_user_name_title => '您的名称';

  @override
  String get settings_user_name_desc => '你在应用中的名字';

  @override
  String get settings_user_name_hint => '输入您的名称';

  @override
  String get default_participant_me => '我';

  @override
  String get select_category => '类别';

  @override
  String get delete_expense => '删除支出';

  @override
  String get delete_expense_confirm => '该支出将被删除，且无法撤销。';

  @override
  String get delete => '删除';

  @override
  String get spent_today => '今日支出';

  @override
  String get welcome_v3_cta => '开始';

  @override
  String get discard_changes_title => '不保存就离开？';

  @override
  String get discard_changes_message => '未保存的更改将会丢失。';

  @override
  String get discard => '舍弃';

  @override
  String error_saving_group(Object error) {
    return '保存错误: $error';
  }

  @override
  String get already_exists => '已存在';

  @override
  String get status_active => '活跃';

  @override
  String get status_archived => '已归档';

  @override
  String get no_archived_groups => '没有已归档的群组';

  @override
  String get no_archived_groups_subtitle => '长按群组并选择“归档”，即可在这里找到它。';

  @override
  String get all_groups_archived_info => '你的所有群组都已归档。你可以从归档中恢复，或新建一个群组。';

  @override
  String get welcome_logo_semantic => 'Caravella应用标志';

  @override
  String get create_new_group => '创建新群组';

  @override
  String get accessibility_back_button => '返回';

  @override
  String get accessibility_groups_list => '群组列表';

  @override
  String get accessibility_welcome_screen => '欢迎屏幕';

  @override
  String accessibility_total_expenses(Object amount) {
    return '总支出：$amount';
  }

  @override
  String get accessibility_add_expense => '添加支出';

  @override
  String get accessibility_currently_disabled => '当前已禁用';

  @override
  String get accessibility_previous_month => '上个月';

  @override
  String get accessibility_next_month => '下个月';

  @override
  String get color_suggested_title => '建议的颜色';

  @override
  String get color_suggested_subtitle => '柔和的色调，适配浅色和深色主题';

  @override
  String get color_random_subtitle => '让应用为您选择颜色';

  @override
  String get currency_AED => '阿联酋迪拉姆';

  @override
  String get currency_AFN => '阿富汗尼';

  @override
  String get currency_ALL => '阿尔巴尼亚列克';

  @override
  String get currency_AMD => '亚美尼亚德拉姆';

  @override
  String get currency_ANG => '荷属安的列斯盾';

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
  String get currency_KID => '基里巴斯元';

  @override
  String get currency_KMF => '科摩罗法郎';

  @override
  String get currency_KPW => '朝鲜圆';

  @override
  String get currency_KRW => '韩元';

  @override
  String get currency_KWD => '科威特第纳尔';

  @override
  String get currency_KYD => '开曼群岛元';

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
  String get currency_NZD => '新西兰元';

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
  String get currency_RSD => '塞尔维亚第纳尔';

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
  String get currency_SLL => '塞拉利昂利昂(旧)';

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
  String get currency_TVD => '图瓦卢元';

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
  String get currency_VED => '委内瑞拉数字玻利瓦尔';

  @override
  String get currency_VES => '委内瑞拉玻利瓦尔';

  @override
  String get currency_VND => '越南盾';

  @override
  String get currency_VUV => '瓦努阿图瓦图';

  @override
  String get currency_WST => '萨摩亚塔拉';

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
  String get search_currency => '搜索货币…';

  @override
  String get clear_filters => '重置';

  @override
  String get filters => '筛选器';

  @override
  String get empty_expenses_title => '还没有支出';

  @override
  String get empty_expenses_subtitle => '添加第一笔支出，它会显示在这里。';

  @override
  String get add_first_expense_button => '添加支出';

  @override
  String get show_search => '显示搜索栏';

  @override
  String get whats_new_title => '新功能';

  @override
  String get changelog_title => '更新日志';

  @override
  String get expenses_map => '支出地图';

  @override
  String get no_locations_available => '暂无地点';

  @override
  String get no_locations_subtitle => '为支出添加地点即可在地图上查看';

  @override
  String expense_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 笔支出',
      one: '1 笔支出',
    );
    return '$_temp0';
  }

  @override
  String get check_for_updates => '检查更新';

  @override
  String get check_for_updates_desc => '查找新版本';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_available_desc => '应用的新版本已可用';

  @override
  String get no_update_available => '应用已是最新';

  @override
  String get update_now => '立即更新';

  @override
  String get update_later => '稍后';

  @override
  String get checking_for_updates => '正在检查更新…';

  @override
  String get update_error => '无法检查更新';

  @override
  String get update_downloading => '正在下载…';

  @override
  String get update_ready_to_install => '更新已就绪，可以安装';

  @override
  String get update_ready_to_install_desc => '更新已下载完成，安装以完成本次更新。';

  @override
  String get update_installing => '正在安装…';

  @override
  String get update_install => '安装更新';

  @override
  String get send_reminder => '发送提醒';

  @override
  String get notification_enabled_desc => '在通知中显示今日支出';

  @override
  String get group_type => '类型';

  @override
  String get group_type_travel => '旅行';

  @override
  String get group_type_personal => '个人';

  @override
  String get group_type_family => '家庭';

  @override
  String get group_type_other => '其他';

  @override
  String get category_travel_transport => '交通';

  @override
  String get category_travel_accommodation => '住宿';

  @override
  String get category_travel_restaurants => '餐厅';

  @override
  String get category_personal_shopping => '购物';

  @override
  String get category_personal_health => '健康';

  @override
  String get category_personal_entertainment => '娱乐';

  @override
  String get category_family_groceries => '食品杂货';

  @override
  String get category_family_home => '家居';

  @override
  String get category_family_bills => '账单';

  @override
  String get category_other_misc => '杂项';

  @override
  String get category_other_utilities => '水电燃气';

  @override
  String get category_other_services => '服务';

  @override
  String get attachments => '附件';

  @override
  String get delete_attachment => '删除附件';

  @override
  String get share_attachment => '分享附件';

  @override
  String get delete_attachment_confirm_title => '删除附件？';

  @override
  String get delete_attachment_confirm_message => '该附件将从支出中删除。';

  @override
  String get attachment_source => '添加附件';

  @override
  String get from_files => '从文件';

  @override
  String get expense => '费用';

  @override
  String get notification_enabled => '持久通知';

  @override
  String notification_daily_spent(String amount, String currency) {
    return '今日消费: $amount $currency';
  }

  @override
  String get notification_add_expense => '添加支出';

  @override
  String get notification_disable => '禁用';

  @override
  String get wizard_group_creation_title => '新建群组';

  @override
  String get wizard_skip => '跳过';

  @override
  String get wizard_user_name_welcome => '你好！';

  @override
  String get wizard_user_name_label => '您的名字（可选）';

  @override
  String get wizard_user_name_hint => '例如 小明';

  @override
  String get wizard_participants_section_title => '谁在参与？';

  @override
  String get wizard_participants_section_hint => '添加朋友或室友。您可以稍后修改。';

  @override
  String get danger_zone => '危险区域';

  @override
  String get export_options_desc => '下载或分享支出';

  @override
  String get export_csv_description => '电子表格格式';

  @override
  String get export_ofx_description => '银行格式';

  @override
  String get export_markdown_description => '文档格式';

  @override
  String get save_label => '保存';

  @override
  String get sync_title => '同步';

  @override
  String get sync_settings_desc => 'Wi-Fi、蓝牙或 Google 云端硬盘';

  @override
  String get sync_multiuser_title => '与他人同步';

  @override
  String get sync_multiuser_description => '通过 Wi-Fi 或蓝牙共享群组';

  @override
  String get sync_multidevice_title => '同步你的设备';

  @override
  String get sync_multidevice_description => '通过云端硬盘同步你的设备';

  @override
  String get sync_local_title => 'Wi-Fi';

  @override
  String get sync_local_description => '同一 Wi-Fi 下自动同步';

  @override
  String get sync_cloud_title => 'Google Drive';

  @override
  String get sync_cloud_description => '通过Google Drive同步';

  @override
  String get sync_cloud_scope_description => '同时同步你的所有群组（Wi-Fi 和蓝牙则可按群组选择）';

  @override
  String get sync_cloud_enable => '开启 Google Drive 同步';

  @override
  String get sync_cloud_privacy => '您的数据保存在您的个人Google Drive中，而非第三方服务器。';

  @override
  String sync_cloud_signed_in_as(String email) {
    return '已使用 $email 登录';
  }

  @override
  String get sync_cloud_sign_in_failed => 'Google 登录失败或已取消';

  @override
  String get sync_history_title => '同步记录';

  @override
  String sync_history_group_desc(String groupTitle) {
    return '“$groupTitle”的同步记录';
  }

  @override
  String get sync_status_syncing => '正在同步…';

  @override
  String get sync_now => '立即同步';

  @override
  String sync_last_sync(String time) {
    return '上次同步：$time';
  }

  @override
  String get sync_bt_title => '蓝牙';

  @override
  String get sync_bt_description => '手动同步附近设备';

  @override
  String get sync_bt_searching => '正在搜索附近设备…';

  @override
  String get sync_bt_advertise_waiting => '正在等待附近设备…';

  @override
  String get sync_bt_sync_with => '同步';

  @override
  String get sync_bt_completed => '同步完成';

  @override
  String sync_bt_received_sent(int received, int sent) {
    return '已接收 $received 项更改，已发送 $sent 项';
  }

  @override
  String get sync_bt_error => '同步失败';

  @override
  String get sync_bt_error_detail => '连接过程中出现问题，请重试。';

  @override
  String get sync_bt_retry => '重试';

  @override
  String get sync_bt_permission_denied => '未允许蓝牙：请在手机设置中开启';

  @override
  String get sync_history_empty => '暂无同步记录';

  @override
  String get sync_channel_lan => '局域网';

  @override
  String get sync_channel_bluetooth => '蓝牙';

  @override
  String get sync_channel_cloud => '云端';

  @override
  String sync_records_exchanged(int sent, int received) {
    return '已发送 $sent 项，已接收 $received 项';
  }

  @override
  String get sync_group_shared => '共享';

  @override
  String get sync_group_enable => '共享此群组';

  @override
  String get sync_group_enable_desc => '与已配对设备同步';

  @override
  String get sync_group_needs_channel => '请在“同步”中开启 Wi-Fi 或蓝牙以共享群组';

  @override
  String get sync_qr_show_button => '显示二维码';

  @override
  String get sync_qr_scan_button => '扫描二维码';

  @override
  String get sync_qr_show_title => '配对设备';

  @override
  String get sync_qr_show_description => '在同一 Wi-Fi 网络下的另一设备上扫描此码以配对同步';

  @override
  String sync_qr_sharing_group(String groupTitle) {
    return '正在共享「$groupTitle」';
  }

  @override
  String sync_qr_expires_in(String time) {
    return '$time 后过期';
  }

  @override
  String get sync_qr_expired_title => '二维码已过期';

  @override
  String get sync_qr_expired_desc => '生成新的二维码以继续配对';

  @override
  String get sync_qr_regenerate_button => '生成新二维码';

  @override
  String get sync_qr_no_network => '请连接 Wi-Fi 以生成配对码';

  @override
  String get sync_qr_scan_title => '扫描配对码';

  @override
  String get sync_qr_scan_description => '扫描另一台设备上的二维码';

  @override
  String sync_qr_pair_success(String deviceName) {
    return '已与 $deviceName 配对';
  }

  @override
  String get sync_qr_pair_failed => '配对失败 — 请确认两台设备在同一 Wi-Fi 网络下';

  @override
  String get sync_qr_pair_expired => '此配对码已过期 — 请让对方设备重新显示一个新的配对码';

  @override
  String get sync_qr_pair_emulator_host =>
      '此二维码是在Android模拟器上生成的，其他设备无法访问该地址 — 请使用同一Wi-Fi网络下的两台真实设备进行配对';

  @override
  String get sync_qr_emulator_warning =>
      '此设备是Android模拟器 — 其地址通常无法被其他设备访问，配对可能会失败';

  @override
  String get sync_paired_devices_title => '已配对设备';

  @override
  String get sync_paired_devices_empty => '尚无已配对设备';

  @override
  String get sync_paired_devices_remove => '取消配对';

  @override
  String get search_expenses => '搜索费用';

  @override
  String search_in_group(String groupName) {
    return '在 $groupName 中搜索';
  }

  @override
  String get has_attachment => '有附件';

  @override
  String get has_location => '有位置';

  @override
  String get search_no_results => '未找到费用';

  @override
  String get search_no_results_hint => '尝试不同的搜索词或调整过滤条件';

  @override
  String get voice_input_button => '语音输入';

  @override
  String get voice_input_listening => '正在聆听…';

  @override
  String get voice_input_tap_to_speak => '点击说话';

  @override
  String get voice_input_processing => '正在处理…';

  @override
  String get voice_input_error => '语音识别错误';

  @override
  String get voice_input_permission_denied => '麦克风权限被拒绝';

  @override
  String get voice_input_not_available => '语音识别不可用';

  @override
  String get voice_input_no_speech => '没有听到任何内容，请重试。';

  @override
  String get voice_input_hint => '试着说：“餐厅晚饭 50 元”';

  @override
  String get voice_add_expense => '语音添加';

  @override
  String get voice_expense_saved => '支出已保存';

  @override
  String get voice_expense_needs_more_info => '缺少部分信息：请完善支出';

  @override
  String get from_unsplash => '从Unsplash搜索';

  @override
  String get unsplash_search_hint => '在 Unsplash 上搜索照片…';

  @override
  String get unsplash_no_results => '未找到图片';

  @override
  String get unsplash_downloading => '正在下载照片…';

  @override
  String get unsplash_error => '加载图片失败';

  @override
  String get unsplash_photos_by => '照片来自';

  @override
  String get unsplash_use_photo => '使用此照片';

  @override
  String get scan_receipt => '扫描收据';

  @override
  String get scanning_receipt => '正在读取收据…';

  @override
  String get receipt_scan_error => '无法读取收据';

  @override
  String get receipt_scan_permission_denied => '未允许相机：请在手机设置中开启以读取收据';

  @override
  String get no_text_found => '图像中未找到文本';

  @override
  String get receipt_scanned => '收据已扫描';

  @override
  String get settings_group_templates_manage_title => '群组模板';

  @override
  String get settings_group_templates_manage_desc => '创建和编辑你的模板';

  @override
  String get settings_group_templates_page_title => '群组模板';

  @override
  String get settings_group_templates_empty_state => '暂无模板';

  @override
  String get settings_group_templates_add_title => '新建模板';

  @override
  String get settings_group_templates_edit_title => '编辑模板';

  @override
  String get settings_group_templates_name_label => '模板名称';

  @override
  String get settings_group_templates_name_hint => '例如：滑雪周';

  @override
  String get settings_group_templates_icon_label => '图标';

  @override
  String get settings_group_templates_categories_label => '默认分类';

  @override
  String get settings_group_templates_validation_error => '必须填写名称且至少添加一个分类';

  @override
  String get settings_group_templates_delete_title => '删除模板';

  @override
  String settings_group_templates_delete_message(String templateName) {
    return '删除模板“$templateName”？';
  }

  @override
  String get clear_dates => '移除日期';

  @override
  String accessibility_map_marker_expense(String name, String amount) {
    return '$name，$amount';
  }

  @override
  String accessibility_map_marker_group(int count, String place) {
    return '$count 笔费用，$place';
  }

  @override
  String get nav_home => '首页';

  @override
  String get nav_groups => '群组';

  @override
  String get quick_action_map => '地图';

  @override
  String get quick_action_search => '搜索';

  @override
  String new_expense_in_group(String group) {
    return '在$group中新增支出';
  }

  @override
  String groups_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个活跃群组',
    );
    return '$_temp0';
  }

  @override
  String get get_started_title => '开始使用';

  @override
  String get_started_progress(int done, int total) {
    return '已完成 $done/$total';
  }

  @override
  String get get_started_create_group => '创建群组';

  @override
  String get get_started_first_expense => '添加第一笔支出';

  @override
  String get get_started_participants => '添加参与者';

  @override
  String get get_started_look => '选择照片或颜色';

  @override
  String get_started_step_done(String step) {
    return '$step，已完成';
  }

  @override
  String get balances => '余额';

  @override
  String get per_person => '人均';

  @override
  String get settle_up => '结清方式';

  @override
  String get all_settled_up => '已全部结清';

  @override
  String balance_gets_back(String name, String amount) {
    return '$name 应收回 $amount';
  }

  @override
  String balance_owes(String name, String amount) {
    return '$name 应付 $amount';
  }

  @override
  String settlement_pays(String from, String to, String amount) {
    return '$from 付给 $to $amount';
  }

  @override
  String places_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个地点',
    );
    return '$_temp0';
  }

  @override
  String get more_options => '更多选项';

  @override
  String get highest_expense => '最高支出';

  @override
  String get most_expensive_day => '花费最多的一天';

  @override
  String get chart_day_by_day => '每日支出';

  @override
  String get this_week => '本周';

  @override
  String get last_week => '上周';

  @override
  String get quick_action_scan => '扫描';

  @override
  String get quick_action_voice => '语音';

  @override
  String get sync_state_syncing => '正在同步';

  @override
  String get sync_state_error => '同步失败，点按查看详情';

  @override
  String get share_balances => '分享余额';

  @override
  String balances_share_title(String group) {
    return '$group · 余额';
  }

  @override
  String balances_share_footer(String total, String perPerson) {
    return '总计 $total · 人均 $perPerson';
  }

  @override
  String balance_reminder_message(
    String from,
    String group,
    String amount,
    String to,
  ) {
    return '$from你好！在“$group”中你需要支付 $amount 给 $to。';
  }

  @override
  String get chart_week_by_week => '每周支出';

  @override
  String get chart_month_by_month => '每月支出';

  @override
  String get edit => '编辑';

  @override
  String get recent_searches => '最近搜索';

  @override
  String get by_type => '按类型';

  @override
  String get favorites => '收藏';

  @override
  String get all_groups => '全部';

  @override
  String get status_label => '状态';

  @override
  String show_results(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '显示 $count 个结果',
      zero: '无结果',
    );
    return '$_temp0';
  }

  @override
  String get expense_details_section => '详情';

  @override
  String get add_expense_button => '添加支出';

  @override
  String auto_backup_last(String date) {
    return '上次备份：$date';
  }

  @override
  String get auto_backup_never => '尚无备份';

  @override
  String get auto_backup_off => '已关闭：数据不备份';

  @override
  String get drive_backup_connect => '连接 Google 云端硬盘';

  @override
  String get drive_backup_connect_desc => '备份保存在私有文件夹中';

  @override
  String get drive_backup_now => '立即备份到云端硬盘';

  @override
  String get drive_backup_none => '云端硬盘中还没有备份';

  @override
  String get drive_backup_restore => '从云端硬盘恢复';

  @override
  String get drive_backup_restore_desc => '从最近 5 个备份中选择';

  @override
  String get drive_backup_weekly => '每周备份';

  @override
  String get drive_backup_weekly_desc => '每周打开应用时备份';

  @override
  String get drive_backup_disconnect => '断开连接';

  @override
  String get drive_backup_saved => '备份已保存到 Google 云端硬盘';

  @override
  String get drive_backup_error => '无法连接 Google 云端硬盘';

  @override
  String get expense_more_details => '更多详情';

  @override
  String get quick_action_photo => '拍照';

  @override
  String get photo_add_expense => '用收据照片新建支出';

  @override
  String get receipt_photo_error => '无法拍摄收据照片';

  @override
  String get crop_hint => '拖动和双指缩放，选择要保留的部分';

  @override
  String get crop_preview => '预览';

  @override
  String get crop_use_photo => '使用这张照片';

  @override
  String get welcome_tagline => '旅行、家庭和朋友的开销，公平分摊。所有数据都留在你的手机上。';

  @override
  String get wizard_name_title => '你叫什么名字？';

  @override
  String get wizard_name_note => '只保存在你的手机上。你将是你群组的第一个成员。';

  @override
  String get wizard_type_title => '这是什么群组？';

  @override
  String get wizard_type_note => '它决定初始类别，你可以随时修改。';

  @override
  String get group_type_personal_desc => '只记录你自己的支出';

  @override
  String get group_type_family_desc => '家庭、家人、室友';

  @override
  String get group_type_travel_desc => '度假、周末、出游';

  @override
  String get group_type_other_desc => '聚餐、活动、礼物';

  @override
  String get wizard_details_title => '给它起个名字';

  @override
  String get wizard_details_note => '日期用于支出图表。之后都可以修改。';

  @override
  String wizard_people_you(String name) {
    return '$name（你）';
  }

  @override
  String get wizard_people_add_hint => '朋友的名字';

  @override
  String wizard_people_remove(String name) {
    return '移除 $name';
  }

  @override
  String get wizard_dates_add => '日期';

  @override
  String get wizard_continue => '继续';

  @override
  String get wizard_create => '创建群组';

  @override
  String get attachment_take_photo => '拍照';

  @override
  String get attachment_record_video => '录制视频';

  @override
  String get place_search_action => '搜索地点';

  @override
  String get background_photo => '照片';

  @override
  String get background_none => '无';

  @override
  String get stats_pace_title => '消费节奏';

  @override
  String get stats_per_day => '每天';

  @override
  String get stats_per_month => '每月';

  @override
  String stats_pace_days(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天平均',
      one: '共 1 天',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_pace_months(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个月平均',
      one: '共 1 个月',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_per_expense(String amount) {
    return '每笔 $amount';
  }

  @override
  String stats_active_days(int active, int total) {
    return '$total 天中有 $active 天有支出';
  }

  @override
  String stats_active_months(int active, int total) {
    return '$total 个月中有 $active 个月有支出';
  }

  @override
  String get most_expensive_month => '花费最多的月份';

  @override
  String get per_month => '/月';

  @override
  String get map_location_off => '开启自动定位，即可在地图上查看支出';

  @override
  String get map_no_places => '还没有带地点的支出';

  @override
  String get no_active_groups_subtitle => '为一次旅行、合租公寓或活动创建一个群组。';

  @override
  String get export_options_empty => '还没有可导出的支出';

  @override
  String get sync_badge_ok => '过去 24 小时内已同步';

  @override
  String get sync_badge_failed => '上次同步失败';

  @override
  String get sync_badge_stale => '过去 24 小时内未同步';

  @override
  String sync_group_received(String from, String title) {
    return '$from 与你共享了“$title”';
  }

  @override
  String sync_group_received_anon(String title) {
    return '有人与你共享了“$title”';
  }

  @override
  String get group_welcome_title => '你已加入该群组';

  @override
  String group_welcome_body(
    String from,
    String people,
    String expenses,
    String total,
  ) {
    return '由 $from 共享：$people，$expenses，目前共 $total。你在这里添加的支出也会同步到其他设备。';
  }

  @override
  String group_welcome_body_anon(String people, String expenses, String total) {
    return '$people，$expenses，目前共 $total。你在这里添加的支出也会同步到其他设备。';
  }
}
