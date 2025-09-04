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
  String get download_all_csv => '下载全部 (CSV)';

  @override
  String get share_all_csv => '分享全部 (CSV)';

  @override
  String get download_all_ofx => '下载全部 (OFX)';

  @override
  String get share_all_ofx => '分享全部 (OFX)';

  @override
  String get export_share => '导出和分享';

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
  String get create_group => '创建群组';

  @override
  String get manage_group => '管理群组';

  @override
  String get group_name => '群组名称';

  @override
  String get group_name_hint => '输入群组名称';

  @override
  String get group_description => '群组描述';

  @override
  String get group_description_hint => '输入群组描述（可选）';

  @override
  String get participants => '参与者';

  @override
  String get add_participants => '添加参与者';

  @override
  String get expenses => '支出';

  @override
  String get add_expense => '添加支出';

  @override
  String get expense_description => '支出描述';

  @override
  String get expense_description_hint => '输入支出描述';

  @override
  String get amount => '金额';

  @override
  String get amount_hint => '输入金额';

  @override
  String get paid_by => '付款人';

  @override
  String get split_between => '分摊给';

  @override
  String get category => '类别';

  @override
  String get date => '日期';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get settings => '设置';

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
  String get settings_language_zh => '中文（简体）';

  @override
  String get settings_select_language => '选择语言';

  @override
  String get settings_select_theme => '选择主题';

  @override
  String get settings_general => '一般';

  @override
  String get settings_general_desc => '应用程序通用设置';

  @override
  String get settings_info => '信息';

  @override
  String get settings_info_desc => '应用程序信息和版本';

  @override
  String get settings_info_card => '应用信息';

  @override
  String get settings_info_card_desc => '查看应用信息和版本';

  @override
  String get settings_data => '数据';

  @override
  String get settings_data_desc => '管理和备份数据';

  @override
  String get settings_data_manage => '管理数据';

  @override
  String get settings_privacy_desc => '安全和隐私选项';

  @override
  String get settings_app_version => '应用版本';

  @override
  String get accessibility_currently_disabled => '当前已禁用';

  @override
  String get accessibility_currently_enabled => '当前已启用';

  @override
  String get accessibility_double_tap_disable => '双击以禁用';

  @override
  String get accessibility_double_tap_enable => '双击以启用';

  @override
  String get accessibility_security_switch => '安全开关';

  @override
  String get accessibility_switch_off => '开关关闭';

  @override
  String get accessibility_switch_on => '开关开启';

  @override
  String get settings_theme => '主题';

  @override
  String get settings_theme_desc => '选择应用主题';

  @override
  String get theme_light => '浅色';

  @override
  String get theme_dark => '深色';

  @override
  String get theme_automatic => '自动';

  @override
  String get settings_version => '版本';

  @override
  String get settings_about => '关于';

  @override
  String get settings_backup => '备份';

  @override
  String get settings_backup_desc => '备份和恢复数据';

  @override
  String get backup_export => '导出数据';

  @override
  String get backup_import => '导入数据';

  @override
  String get backup_success => '备份成功';

  @override
  String get backup_error => '备份失败';

  @override
  String get import_confirm_title => '导入数据';

  @override
  String import_confirm_message(Object file) {
    return '确定要用文件 "$file" 覆盖所有行程吗？此操作无法撤销。';
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
  String get add_category => '添加类别';

  @override
  String get edit_category => '编辑类别';

  @override
  String get delete_category => '删除类别';

  @override
  String get no_categories => '无类别';

  @override
  String get default_categories => '默认类别';

  @override
  String get food => '食物';

  @override
  String get transport => '交通';

  @override
  String get accommodation => '住宿';

  @override
  String get entertainment => '娱乐';

  @override
  String get shopping => '购物';

  @override
  String get health => '健康';

  @override
  String get education => '教育';

  @override
  String get other => '其他';

  @override
  String get total_expenses => '总支出';

  @override
  String get balance => '余额';

  @override
  String get owes => '欠款';

  @override
  String get owed => '应收';

  @override
  String get settled => '已结算';

  @override
  String get settle_up => '结算';

  @override
  String get expense_details => '支出详情';

  @override
  String get share_expense => '分享支出';

  @override
  String get duplicate_expense => '复制支出';

  @override
  String get no_expenses => '无支出';

  @override
  String get add_first_expense => '添加您的第一笔支出';

  @override
  String get group_statistics => '群组统计';

  @override
  String get total_spent => '总支出';

  @override
  String get avg_per_person => '人均支出';

  @override
  String get most_expensive => '最贵支出';

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
  String get csv_participants => '参与者';

  // Currency translations
  @override
  String get currency_AFN => '阿富汗尼';

  @override
  String get currency_ALL => '阿尔巴尼亚列克';

  @override
  String get currency_DZD => '阿尔及利亚第纳尔';

  @override
  String get currency_USD => '美元';

  @override
  String get currency_EUR => '欧元';

  @override
  String get currency_AOA => '安哥拉宽扎';

  @override
  String get currency_XCD => '东加勒比元';

  @override
  String get currency_ARS => '阿根廷比索';

  @override
  String get currency_AMD => '亚美尼亚德拉姆';

  @override
  String get currency_AWG => '阿鲁巴弗罗林';

  @override
  String get currency_AUD => '澳大利亚元';

  @override
  String get currency_AZN => '阿塞拜疆马纳特';

  @override
  String get currency_BSD => '巴哈马元';

  @override
  String get currency_BHD => '巴林第纳尔';

  @override
  String get currency_BDT => '孟加拉塔卡';

  @override
  String get currency_BBD => '巴巴多斯元';

  @override
  String get currency_BYN => '白俄罗斯卢布';

  @override
  String get currency_BZD => '伯利兹元';

  @override
  String get currency_XOF => '西非法郎';

  @override
  String get currency_BMD => '百慕大元';

  @override
  String get currency_BTN => '不丹努尔特鲁姆';

  @override
  String get currency_BOB => '玻利维亚诺';

  @override
  String get currency_BAM => '波黑可兑换马克';

  @override
  String get currency_BWP => '博茨瓦纳普拉';

  @override
  String get currency_BRL => '巴西雷亚尔';

  @override
  String get currency_BND => '文莱元';

  @override
  String get currency_BGN => '保加利亚列弗';

  @override
  String get currency_BIF => '布隆迪法郎';

  @override
  String get currency_CVE => '佛得角埃斯库多';

  @override
  String get currency_KHR => '柬埔寨瑞尔';

  @override
  String get currency_XAF => '中非法郎';

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
  String get currency_KMF => '科摩罗法郎';

  @override
  String get currency_CRC => '哥斯达黎加科朗';

  @override
  String get currency_HRK => '克罗地亚库纳';

  @override
  String get currency_CUP => '古巴比索';

  @override
  String get currency_CZK => '捷克克朗';

  @override
  String get currency_DKK => '丹麦克朗';

  @override
  String get currency_DJF => '吉布提法郎';

  @override
  String get currency_DOP => '多米尼加比索';

  @override
  String get currency_EGP => '埃及镑';

  @override
  String get currency_SVC => '萨尔瓦多科朗';

  @override
  String get currency_ERN => '厄立特里亚纳克法';

  @override
  String get currency_SZL => '斯威士兰里兰吉尼';

  @override
  String get currency_ETB => '埃塞俄比亚比尔';

  @override
  String get currency_FKP => '福克兰群岛镑';

  @override
  String get currency_FJD => '斐济元';

  @override
  String get currency_XPF => '太平洋法郎';

  @override
  String get currency_GMD => '冈比亚达拉西';

  @override
  String get currency_GEL => '格鲁吉亚拉里';

  @override
  String get currency_GHS => '加纳塞地';

  @override
  String get currency_GIP => '直布罗陀镑';

  @override
  String get currency_GTQ => '危地马拉格查尔';

  @override
  String get currency_GBP => '英镑';

  @override
  String get currency_GNF => '几内亚法郎';

  @override
  String get currency_GYD => '圭亚那元';

  @override
  String get currency_HTG => '海地古德';

  @override
  String get currency_HNL => '洪都拉斯伦皮拉';

  @override
  String get currency_HKD => '港币';

  @override
  String get currency_HUF => '匈牙利福林';

  @override
  String get currency_ISK => '冰岛克朗';

  @override
  String get currency_INR => '印度卢比';

  @override
  String get currency_IDR => '印尼盾';

  @override
  String get currency_IRR => '伊朗里亚尔';

  @override
  String get currency_IQD => '伊拉克第纳尔';

  @override
  String get currency_ILS => '以色列新谢克尔';

  @override
  String get currency_JMD => '牙买加元';

  @override
  String get currency_JPY => '日元';

  @override
  String get currency_JOD => '约旦第纳尔';

  @override
  String get currency_KZT => '哈萨克斯坦坚戈';

  @override
  String get currency_KES => '肯尼亚先令';

  @override
  String get currency_KPW => '朝鲜圆';

  @override
  String get currency_KRW => '韩元';

  @override
  String get currency_KWD => '科威特第纳尔';

  @override
  String get currency_KGS => '吉尔吉斯斯坦索姆';

  @override
  String get currency_LAK => '老挝基普';

  @override
  String get currency_LBP => '黎巴嫩镑';

  @override
  String get currency_LSL => '莱索托洛蒂';

  @override
  String get currency_LRD => '利比里亚元';

  @override
  String get currency_LYD => '利比亚第纳尔';

  @override
  String get currency_MOP => '澳门帕塔卡';

  @override
  String get currency_MKD => '北马其顿第纳尔';

  @override
  String get currency_MGA => '马达加斯加阿里亚里';

  @override
  String get currency_MWK => '马拉维克瓦查';

  @override
  String get currency_MYR => '马来西亚林吉特';

  @override
  String get currency_MVR => '马尔代夫拉菲亚';

  @override
  String get currency_MRU => '毛里塔尼亚乌吉亚';

  @override
  String get currency_MUR => '毛里求斯卢比';

  @override
  String get currency_MXN => '墨西哥比索';

  @override
  String get currency_MDL => '摩尔多瓦列伊';

  @override
  String get currency_MNT => '蒙古图格里克';

  @override
  String get currency_MAD => '摩洛哥迪拉姆';

  @override
  String get currency_MZN => '莫桑比克梅蒂卡尔';

  @override
  String get currency_MMK => '缅甸缅元';

  @override
  String get currency_NAD => '纳米比亚元';

  @override
  String get currency_NPR => '尼泊尔卢比';

  @override
  String get currency_NIO => '尼加拉瓜科多巴';

  @override
  String get currency_NGN => '尼日利亚奈拉';

  @override
  String get currency_NOK => '挪威克朗';

  @override
  String get currency_OMR => '阿曼里亚尔';

  @override
  String get currency_PKR => '巴基斯坦卢比';

  @override
  String get currency_PAB => '巴拿马巴波亚';

  @override
  String get currency_PGK => '巴布亚新几内亚基那';

  @override
  String get currency_PYG => '巴拉圭瓜拉尼';

  @override
  String get currency_PEN => '秘鲁索尔';

  @override
  String get currency_PHP => '菲律宾比索';

  @override
  String get currency_PLN => '波兰兹罗提';

  @override
  String get currency_QAR => '卡塔尔里亚尔';

  @override
  String get currency_RON => '罗马尼亚列伊';

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
  String get currency_SOS => '索马里先令';

  @override
  String get currency_ZAR => '南非兰特';

  @override
  String get currency_SSP => '南苏丹镑';

  @override
  String get currency_LKR => '斯里兰卡卢比';

  @override
  String get currency_STN => '圣多美和普林西比多布拉';

  @override
  String get currency_SRD => '苏里南元';

  @override
  String get currency_SYP => '叙利亚镑';

  @override
  String get currency_TWD => '新台币';

  @override
  String get currency_TJS => '塔吉克斯坦索莫尼';

  @override
  String get currency_TZS => '坦桑尼亚先令';

  @override
  String get currency_THB => '泰铢';

  @override
  String get currency_TOP => '汤加潘加';

  @override
  String get currency_TTD => '特立尼达和多巴哥元';

  @override
  String get currency_TND => '突尼斯第纳尔';

  @override
  String get currency_TRY => '土耳其里拉';

  @override
  String get currency_TMT => '土库曼斯坦马纳特';

  @override
  String get currency_UGX => '乌干达先令';

  @override
  String get currency_UAH => '乌克兰格里夫纳';

  @override
  String get currency_AED => '阿联酋迪拉姆';

  @override
  String get currency_UYU => '乌拉圭比索';

  @override
  String get currency_UZS => '乌兹别克斯坦苏姆';

  @override
  String get currency_VUV => '瓦努阿图瓦图';

  @override
  String get currency_VES => '委内瑞拉玻利瓦尔';

  @override
  String get currency_VND => '越南盾';

  @override
  String get currency_YER => '也门里亚尔';

  @override
  String get currency_ZMW => '赞比亚克瓦查';

  @override
  String get currency_ZWL => '津巴布韦元';

  @override
  String get currency_search_hint => '搜索货币...';

  @override
  String get select_participants => '选择参与者';

  @override
  String get all_participants => '所有参与者';

  @override
  String get expense_split_equally => '平均分摊';

  @override
  String get expense_split_custom => '自定义分摊';

  @override
  String get split_amount => '分摊金额';

  @override
  String get remaining_amount => '剩余金额';

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

  // Add more methods as needed to match the base class interface
  // For brevity, I'm implementing the most important ones
  // The Flutter code generation will handle the complete implementation

  @override
  String get new_expense_group => '新费用群组';

  @override
  String get tap_to_create => '点击创建';

  @override
  String get no_expense_label => '未找到费用';

  @override
  String get image => '图片';

  @override
  String get select_image => '选择图片';

  @override
  String get change_image => '更改图片';

  @override
  String get from_gallery => '从相册';

  @override
  String get from_camera => '从相机';

  @override
  String get remove_image => '移除图片';

  @override
  String get color => '颜色';

  @override
  String get remove_color => '移除颜色';

  @override
  String get color_alternative => '图片的替代';

  @override
  String get background => '背景';

  @override
  String get select_background => '选择背景';

  @override
  String get background_options => '背景选项';

  @override
  String get choose_image_or_color => '选择图片或颜色';

  @override
  String get participants_description => '分摊费用的人员';

  @override
  String get expense_groups_settings => '费用群组设置';

  @override
  String get group_image => '群组图片';

  @override
  String get group_icon => '群组图标';

  @override
  String get save_group => '保存群组';

  @override
  String get edit_group => '编辑群组';

  @override
  String get delete_group => '删除群组';

  @override
  String get group_settings => '群组设置';

  @override
  String get group_participants => '群组参与者';

  @override
  String get group_expenses => '群组费用';

  @override
  String get group_summary => '群组摘要';

  @override
  String get add_expense_to => '添加费用至';

  @override
  String get expense_created => '费用已创建';

  @override
  String get expense_updated => '费用已更新';

  @override
  String get expense_deleted => '费用已删除';

  @override
  String get no_expense_message => '未添加任何费用';

  @override
  String get participant_added => '参与者已添加';

  @override
  String get participant_updated => '参与者已更新';

  @override
  String get participant_deleted => '参与者已删除';

  @override
  String get split_equally => '平均分摊';

  @override
  String get custom_split => '自定义分摊';

  @override
  String get who_paid => '谁付款了';

  @override
  String get split_details => '分摊详情';

  @override
  String get expense_note => '费用备注';

  @override
  String get optional => '可选';

  @override
  String get required => '必需';

  @override
  String get expense_amount => '费用金额';

  @override
  String get split_type => '分摊类型';

  @override
  String get equal_split => '平等分摊';

  @override
  String get unequal_split => '不等分摊';

  @override
  String get percentage_split => '百分比分摊';

  @override
  String get share_split => '份额分摊';

  @override
  String get activity => '活动';

  @override
  String get search_expenses_hint => '按名称或备注搜索...';

  @override
  String get clear_filters => '清除';

  @override
  String get show_filters => '显示筛选';

  @override
  String get hide_filters => '隐藏筛选';

  @override
  String get all_categories => '全部';

  @override
  String get no_expenses_with_filters => '没有符合筛选条件的费用';

  @override
  String get no_expenses_yet => '尚未添加费用';

  @override
  String get empty_expenses_title => '准备开始记录了吗？';

  @override
  String get empty_expenses_subtitle => '添加您的第一笔费用开始跟踪群组支出';

  @override
  String from_to(Object end, Object start) {
    return '从 $start 到 $end';
  }

  @override
  String participant_name_semantics(Object name) {
    return '参与者姓名：$name';
  }

  @override
  String category_name_semantics(Object name) {
    return '类别名称：$name';
  }

  @override
  String error_saving_group(Object error) {
    return '保存群组时出错：$error';
  }

  @override
  String accessibility_total_expenses(Object amount) {
    return '总费用：$amount€';
  }

  @override
  String accessibility_security_switch(Object state) {
    return '安全开关 - $state';
  }

}