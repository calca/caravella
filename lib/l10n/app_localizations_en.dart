// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get developer_section_title => 'Developer and support';

  @override
  String get repo_section_title => 'Code and issues';

  @override
  String get license_section_title => 'License';

  @override
  String get weeklyChartBadge => 'W';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get dateRangeChartBadge => 'D';

  @override
  String get weeklyExpensesChart => 'Weekly expenses';

  @override
  String get monthlyExpensesChart => 'Monthly expenses';

  @override
  String get dateRangeExpensesChart => 'Date range expenses';

  @override
  String get settings_flag_secure_desc => 'Block screenshots and recording';

  @override
  String get settings_flag_secure_title => 'Secure screen';

  @override
  String get settings_app_functions_title => 'AI agent access';

  @override
  String get settings_app_functions_desc =>
      'Use Gemini and other AI assistants';

  @override
  String get select_currency => 'Currency';

  @override
  String days_count(int count) {
    return '$count days';
  }

  @override
  String get weekday_mon => 'M';

  @override
  String get weekday_tue => 'T';

  @override
  String get weekday_wed => 'W';

  @override
  String get weekday_thu => 'T';

  @override
  String get weekday_fri => 'F';

  @override
  String get weekday_sat => 'S';

  @override
  String get weekday_sun => 'S';

  @override
  String get month_january => 'January';

  @override
  String get month_february => 'February';

  @override
  String get month_march => 'March';

  @override
  String get month_april => 'April';

  @override
  String get month_may => 'May';

  @override
  String get month_june => 'June';

  @override
  String get month_july => 'July';

  @override
  String get month_august => 'August';

  @override
  String get month_september => 'September';

  @override
  String get month_october => 'October';

  @override
  String get month_november => 'November';

  @override
  String get month_december => 'December';

  @override
  String get in_group_prefix => 'in';

  @override
  String get group_total => 'Total';

  @override
  String get markdown_select_directory_title =>
      'Select folder to save Markdown';

  @override
  String markdown_saved_in(String path) {
    return 'Markdown saved in: $path';
  }

  @override
  String get markdown_save_cancelled => 'Markdown export cancelled';

  @override
  String get markdown_save_error => 'Error saving Markdown file';

  @override
  String get share_label => 'Share';

  @override
  String get export_share => 'Share and export';

  @override
  String get export_options => 'Export expenses';

  @override
  String get welcome_v3_title => 'Organize.\nShare.\nSettle.\n ';

  @override
  String get good_morning => 'Good morning';

  @override
  String get good_afternoon => 'Good afternoon';

  @override
  String get good_evening => 'Good evening';

  @override
  String get see_all => 'See all';

  @override
  String get view_all_groups => 'View all groups';

  @override
  String get no_active_groups => 'No active groups';

  @override
  String get create_first_group => 'Create a group';

  @override
  String get new_expense_group => 'New';

  @override
  String get new_expense => 'New Expense';

  @override
  String get image => 'Photo';

  @override
  String get change_image => 'Change photo';

  @override
  String get from_gallery => 'From gallery';

  @override
  String get from_camera => 'From camera';

  @override
  String get cannot_delete_assigned_participant =>
      'Cannot delete participant: it\'s assigned to one or more expenses';

  @override
  String get cannot_delete_assigned_category =>
      'Cannot delete category: it\'s assigned to one or more expenses';

  @override
  String get color => 'Color';

  @override
  String get background => 'Background';

  @override
  String get participants_description => 'People sharing costs';

  @override
  String get categories_description => 'Group expenses by type';

  @override
  String get dates_description => 'Start and end, optional';

  @override
  String get select_period => 'Period';

  @override
  String get suggested_duration => 'Suggested duration';

  @override
  String get confirm => 'Confirm';

  @override
  String get clear => 'Remove';

  @override
  String get background_color_selected => 'Color selected';

  @override
  String get background_tap_to_replace => 'Tap to replace';

  @override
  String get background_tap_to_change => 'Tap to change';

  @override
  String get background_select_image_or_color => 'Choose a photo or a color';

  @override
  String get background_random_color => 'Random color';

  @override
  String get background_remove => 'Remove background';

  @override
  String get crop_image_title => 'Crop the photo';

  @override
  String get crop_confirm => 'Confirm';

  @override
  String get saving => 'Saving…';

  @override
  String get expenses => 'Expenses';

  @override
  String get participants => 'Participants';

  @override
  String participant_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '$count participant',
    );
    return '$_temp0';
  }

  @override
  String get participants_label => 'Participants';

  @override
  String get last_7_days => 'Last 7 days';

  @override
  String get today => 'Today';

  @override
  String get this_month => 'This month';

  @override
  String get recent_expenses => 'Recent expenses';

  @override
  String get license_link => 'View MIT License on GitHub';

  @override
  String get add_trip => 'Add a group';

  @override
  String get group => 'Group';

  @override
  String get create => 'Create';

  @override
  String get group_name => 'Name';

  @override
  String get enter_title => 'Enter a name';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get add_expense => 'New expense';

  @override
  String get edit_expense => 'Edit expense';

  @override
  String get expand_form => 'Expand form';

  @override
  String get expand_form_tooltip => 'Add date, location and notes';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get invalid_amount => 'Invalid amount';

  @override
  String get add_category => 'Add category';

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
  String get end_date_after_start => 'End date must be after start date';

  @override
  String get expenses_by_participant => 'By participant';

  @override
  String get expenses_by_category => 'By category';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get backup => 'Backup';

  @override
  String get no_trips_to_backup => 'No groups to back up';

  @override
  String get backup_error => 'Backup failed';

  @override
  String get backup_share_message => 'Here is your Caravella backup';

  @override
  String get import_confirm_title => 'Import data';

  @override
  String import_confirm_message(Object file) {
    return 'Restore from the file “$file”? Your current groups will be replaced and this can’t be undone.';
  }

  @override
  String get import_success => 'Data restored';

  @override
  String get import_error => 'Restore failed: check the file';

  @override
  String get settings_flag_secure_error => 'Couldn\'t change screen security';

  @override
  String get settings_debug_logs_title => 'Debug Logs';

  @override
  String get settings_debug_logs_desc => 'App logs and errors';

  @override
  String get developer_link_error => 'Couldn\'t open the link';

  @override
  String get whats_new_load_error => 'Couldn’t load what’s new';

  @override
  String get categories => 'Categories';

  @override
  String get other_settings_desc => 'Notification, location';

  @override
  String get segment_general => 'General';

  @override
  String get segment_other => 'Other';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get add => 'Add';

  @override
  String get participant_name => 'Participant name';

  @override
  String get edit_participant => 'Edit participant';

  @override
  String get add_participant => 'Add participant';

  @override
  String get edit_category => 'Edit category';

  @override
  String get currency => 'Currency';

  @override
  String get settings_tab => 'Settings';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get all => 'All';

  @override
  String get search_groups => 'Search groups…';

  @override
  String get no_search_results => 'No groups found';

  @override
  String get try_different_search => 'Try searching with different words';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Remove from archive';

  @override
  String get pin => 'Favorite';

  @override
  String get unpin => 'Unfavorite';

  @override
  String get archived_with_undo => 'Archived';

  @override
  String get unarchived_with_undo => 'Removed from archive';

  @override
  String get pinned_with_undo => 'Marked as favorite';

  @override
  String get unpinned_with_undo => 'Favorite removed';

  @override
  String get deleted_with_undo => 'Deleted';

  @override
  String get statistics => 'Statistics';

  @override
  String get period => 'Period';

  @override
  String get total_expenses => 'Total expenses';

  @override
  String get number_of_expenses => 'Number of expenses';

  @override
  String get select_expense_date => 'Select expense date';

  @override
  String get select_expense_date_short => 'Select date';

  @override
  String get date => 'Date';

  @override
  String get delete_group => 'Delete group';

  @override
  String get delete_group_confirm =>
      'The group and all its expenses will be deleted. This can’t be undone.';

  @override
  String get add_expense_fab => 'Add expense';

  @override
  String get pin_group => 'Mark as favorite';

  @override
  String get unpin_group => 'Remove favorite';

  @override
  String get theme_automatic => 'Automatic';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get per_day => '/day';

  @override
  String get no_expenses_for_statistics =>
      'No expenses available for statistics';

  @override
  String get settlement => 'Settle up';

  @override
  String get all_balanced => 'You’re all square';

  @override
  String get no_expenses_to_export => 'No expenses to export';

  @override
  String get expense_name => 'Description';

  @override
  String get paid_by => 'Paid by';

  @override
  String get added_by => 'Added by';

  @override
  String get edited_by => 'Edited by';

  @override
  String get expense_added_success => 'Expense added';

  @override
  String get expense_updated_success => 'Expense updated';

  @override
  String get refresh => 'Refresh';

  @override
  String get group_added_success => 'Group added';

  @override
  String get group_deleted_success => 'Group deleted';

  @override
  String get csv_select_directory_title => 'Select folder to save CSV';

  @override
  String csv_saved_in(Object path) {
    return 'CSV saved in: $path';
  }

  @override
  String get csv_save_cancelled => 'Export cancelled';

  @override
  String get csv_save_error => 'Error saving CSV file';

  @override
  String get ofx_select_directory_title => 'Select folder to save OFX';

  @override
  String ofx_saved_in(Object path) {
    return 'OFX saved in: $path';
  }

  @override
  String get ofx_save_cancelled => 'OFX export cancelled';

  @override
  String get ofx_save_error => 'Error saving OFX file';

  @override
  String get csv_expense_name => 'Description';

  @override
  String get csv_amount => 'Amount';

  @override
  String get csv_paid_by => 'Paid by';

  @override
  String get csv_category => 'Category';

  @override
  String get csv_date => 'Date';

  @override
  String get csv_note => 'Note';

  @override
  String get csv_location => 'Location';

  @override
  String get location => 'Place';

  @override
  String get location_hint => 'Place';

  @override
  String get get_current_location => 'Use current location';

  @override
  String get getting_location => 'Finding location…';

  @override
  String get location_error => 'Couldn’t find your location';

  @override
  String get address_resolved => 'Address resolved';

  @override
  String get settings_general => 'General';

  @override
  String get settings_auto_location_title => 'Automatic location';

  @override
  String get settings_auto_location_desc => 'Saves where new expenses are made';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_it => 'Italian';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_language_es => 'Spanish';

  @override
  String get settings_language_pt => 'Portuguese';

  @override
  String get settings_language_zh => 'Chinese (Simplified)';

  @override
  String get settings_select_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_appearance_desc => 'Language, theme and dynamic color';

  @override
  String get settings_dynamic_color => 'Dynamic color';

  @override
  String get settings_dynamic_color_desc => 'Use colors from your wallpaper';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_data_manage => 'Data management';

  @override
  String get settings_info => 'Information';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_info_card => 'Information';

  @override
  String get settings_info_card_desc => 'Developer, source code and license';

  @override
  String get settings_invite_friends => 'Invite your friends';

  @override
  String get settings_invite_friends_desc => 'Share Caravella with anyone';

  @override
  String get invite_friends_message =>
      'Hey! I use Caravella to split group expenses with friends, it\'s super handy 🎒💸 Give it a try: https://play.google.com/store/apps/details?id=io.caravella.egm';

  @override
  String get terms_github_title => 'Website: calca';

  @override
  String get terms_github_desc => 'Developer\'s website';

  @override
  String get terms_repo_title => 'GitHub Repository';

  @override
  String get terms_repo_desc => 'The app’s source code';

  @override
  String get terms_issue_title => 'Report a problem';

  @override
  String get terms_issue_desc => 'Report a problem on GitHub';

  @override
  String get terms_license_desc => 'MIT open source license';

  @override
  String get support_developer_title => 'Buy me a coffee';

  @override
  String get support_developer_desc => 'Support the app’s development';

  @override
  String get data_title => 'Backup and restore';

  @override
  String get data_backup_desc => 'Save your expenses to a file';

  @override
  String get data_restore_title => 'Restore';

  @override
  String get data_restore_desc => 'From a backup file';

  @override
  String get auto_backup_title => 'Automatic backup';

  @override
  String get auto_backup_desc => 'Your phone\'s system backup';

  @override
  String get settings_user_name_title => 'Your name';

  @override
  String get settings_user_name_desc => 'Your name in the app';

  @override
  String get settings_user_name_hint => 'Enter your name';

  @override
  String get default_participant_me => 'Me';

  @override
  String get select_category => 'Category';

  @override
  String get delete_expense => 'Delete expense';

  @override
  String get delete_expense_confirm =>
      'The expense will be deleted. This can’t be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get spent_today => 'Today';

  @override
  String get welcome_v3_cta => 'Get started';

  @override
  String get discard_changes_title => 'Leave without saving?';

  @override
  String get discard_changes_message =>
      'Changes you haven’t saved will be lost.';

  @override
  String get discard => 'Discard';

  @override
  String error_saving_group(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get already_exists => 'already exists';

  @override
  String get status_active => 'Active';

  @override
  String get status_archived => 'Archived';

  @override
  String get no_archived_groups => 'No archived groups';

  @override
  String get no_archived_groups_subtitle =>
      'Long-press a group and choose Archive: you’ll find it here.';

  @override
  String get all_groups_archived_info =>
      'All your groups are archived. You can bring them back from there or create a new one.';

  @override
  String get welcome_logo_semantic => 'Caravella app logo';

  @override
  String get create_new_group => 'Create new group';

  @override
  String get accessibility_back_button => 'Back';

  @override
  String get accessibility_groups_list => 'Groups list';

  @override
  String get accessibility_welcome_screen => 'Welcome screen';

  @override
  String accessibility_total_expenses(Object amount) {
    return 'Total expenses: $amount';
  }

  @override
  String get accessibility_add_expense => 'Add expense';

  @override
  String get accessibility_currently_disabled => 'Currently disabled';

  @override
  String get accessibility_previous_month => 'Previous month';

  @override
  String get accessibility_next_month => 'Next month';

  @override
  String get color_suggested_title => 'Suggested colors';

  @override
  String get color_suggested_subtitle =>
      'Soft tints that adapt to the light and dark theme';

  @override
  String get color_random_subtitle => 'Let the app pick a color for you';

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
  String get search_currency => 'Search currency…';

  @override
  String get clear_filters => 'Reset';

  @override
  String get filters => 'Filters';

  @override
  String get empty_expenses_title => 'No expenses yet';

  @override
  String get empty_expenses_subtitle =>
      'Add the first one: you’ll find it here.';

  @override
  String get add_first_expense_button => 'Add expense';

  @override
  String get show_search => 'Show search bar';

  @override
  String get whats_new_title => 'What\'s New';

  @override
  String get changelog_title => 'Changelog';

  @override
  String get expenses_map => 'Expenses Map';

  @override
  String get no_locations_available => 'No places';

  @override
  String get no_locations_subtitle =>
      'Add a place to your expenses to see them on the map';

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
  String get check_for_updates => 'Check for updates';

  @override
  String get check_for_updates_desc => 'Look for a new version';

  @override
  String get update_available => 'Update available';

  @override
  String get update_available_desc => 'A new version of the app is available';

  @override
  String get no_update_available => 'App up to date';

  @override
  String get update_now => 'Update now';

  @override
  String get update_later => 'Later';

  @override
  String get checking_for_updates => 'Checking for updates…';

  @override
  String get update_error => 'Couldn’t check for updates';

  @override
  String get update_downloading => 'Downloading…';

  @override
  String get update_ready_to_install => 'Update ready to install';

  @override
  String get update_ready_to_install_desc =>
      'The update finished downloading. Install it to finish updating.';

  @override
  String get update_installing => 'Installing…';

  @override
  String get update_install => 'Install update';

  @override
  String get send_reminder => 'Send reminder';

  @override
  String get notification_enabled_desc => 'Today\'s expenses in a notification';

  @override
  String get group_type => 'Type';

  @override
  String get group_type_travel => 'Travel';

  @override
  String get group_type_personal => 'Personal';

  @override
  String get group_type_family => 'Family';

  @override
  String get group_type_other => 'Other';

  @override
  String get category_travel_transport => 'Transport';

  @override
  String get category_travel_accommodation => 'Accommodation';

  @override
  String get category_travel_restaurants => 'Restaurants';

  @override
  String get category_personal_shopping => 'Shopping';

  @override
  String get category_personal_health => 'Health';

  @override
  String get category_personal_entertainment => 'Entertainment';

  @override
  String get category_family_groceries => 'Groceries';

  @override
  String get category_family_home => 'Home';

  @override
  String get category_family_bills => 'Bills';

  @override
  String get category_other_misc => 'Miscellaneous';

  @override
  String get category_other_utilities => 'Utilities';

  @override
  String get category_other_services => 'Services';

  @override
  String get attachments => 'Attachments';

  @override
  String get delete_attachment => 'Delete attachment';

  @override
  String get share_attachment => 'Share attachment';

  @override
  String get delete_attachment_confirm_title => 'Delete the attachment?';

  @override
  String get delete_attachment_confirm_message =>
      'The attachment will be deleted from the expense.';

  @override
  String get attachment_source => 'Add attachment';

  @override
  String get from_files => 'From a file';

  @override
  String get expense => 'Expense';

  @override
  String get notification_enabled => 'Persistent notification';

  @override
  String notification_daily_spent(String amount, String currency) {
    return 'Today\'s expenses: $amount $currency';
  }

  @override
  String get notification_add_expense => 'Add expense';

  @override
  String get notification_disable => 'Disable';

  @override
  String get wizard_group_creation_title => 'New group';

  @override
  String get wizard_skip => 'Skip';

  @override
  String get wizard_user_name_welcome => 'Hi!';

  @override
  String get wizard_user_name_label => 'Your name (optional)';

  @override
  String get wizard_user_name_hint => 'e.g. Alex';

  @override
  String get wizard_participants_section_title => 'Who\'s participating?';

  @override
  String get wizard_participants_section_hint =>
      'Add friends or roommates. You can modify them later.';

  @override
  String get danger_zone => 'Danger zone';

  @override
  String get export_options_desc => 'Download or share the expenses';

  @override
  String get export_csv_description => 'Spreadsheet format';

  @override
  String get export_ofx_description => 'Banking format';

  @override
  String get export_markdown_description => 'Document format';

  @override
  String get save_label => 'Save';

  @override
  String get sync_title => 'Synchronization';

  @override
  String get sync_settings_desc => 'Wi-Fi, Bluetooth or Google Drive';

  @override
  String get sync_multiuser_title => 'Sync with others';

  @override
  String get sync_multiuser_description => 'Groups over Wi-Fi or Bluetooth';

  @override
  String get sync_multidevice_title => 'Sync your devices';

  @override
  String get sync_multidevice_description =>
      'Keep your devices in step via Drive';

  @override
  String get sync_local_title => 'Wi-Fi';

  @override
  String get sync_local_description => 'Automatic on the same Wi-Fi';

  @override
  String get sync_cloud_title => 'Google Drive';

  @override
  String get sync_cloud_description => 'Sync via Google Drive';

  @override
  String get sync_cloud_scope_description =>
      'Syncs all your groups together (with Wi-Fi and Bluetooth you choose group by group)';

  @override
  String get sync_cloud_enable => 'Turn on synchronization with Google Drive';

  @override
  String get sync_cloud_privacy =>
      'Your data is saved in your personal Google Drive, not on third-party servers.';

  @override
  String sync_cloud_signed_in_as(String email) {
    return 'Signed in as $email';
  }

  @override
  String get sync_cloud_sign_in_failed =>
      'Google sign-in failed or was cancelled';

  @override
  String get sync_history_title => 'Synchronization history';

  @override
  String sync_history_group_desc(String groupTitle) {
    return 'Synchronizations of “$groupTitle”';
  }

  @override
  String get sync_status_syncing => 'Synchronizing…';

  @override
  String get sync_now => 'Sync now';

  @override
  String sync_last_sync(String time) {
    return 'Last synchronization: $time';
  }

  @override
  String get sync_bt_title => 'Bluetooth';

  @override
  String get sync_bt_description => 'Manual, with nearby devices';

  @override
  String get sync_bt_searching => 'Looking for nearby devices…';

  @override
  String get sync_bt_advertise_waiting => 'Waiting for a nearby device…';

  @override
  String get sync_bt_sync_with => 'Sync';

  @override
  String get sync_bt_completed => 'Sync completed';

  @override
  String sync_bt_received_sent(int received, int sent) {
    return 'Received $received changes, sent $sent';
  }

  @override
  String get sync_bt_error => 'Sync failed';

  @override
  String get sync_bt_error_detail =>
      'Something went wrong during the connection. Please try again.';

  @override
  String get sync_bt_retry => 'Retry';

  @override
  String get sync_bt_permission_denied =>
      'Bluetooth not allowed: turn it on in your phone settings';

  @override
  String get sync_history_empty => 'No synchronizations';

  @override
  String get sync_channel_lan => 'LAN';

  @override
  String get sync_channel_bluetooth => 'Bluetooth';

  @override
  String get sync_channel_cloud => 'Cloud';

  @override
  String sync_records_exchanged(int sent, int received) {
    return '$sent sent, $received received';
  }

  @override
  String get sync_group_shared => 'Shared';

  @override
  String get sync_group_enable => 'Share this group';

  @override
  String get sync_group_enable_desc => 'With your paired devices';

  @override
  String get sync_group_needs_channel =>
      'Turn on Wi-Fi or Bluetooth in Synchronization to share the group';

  @override
  String get sync_qr_show_button => 'Show QR code';

  @override
  String get sync_qr_scan_button => 'Scan QR code';

  @override
  String get sync_qr_show_title => 'Pair a device';

  @override
  String get sync_qr_show_description =>
      'Scan this code from another device on the same Wi-Fi network to pair it for sync';

  @override
  String sync_qr_sharing_group(String groupTitle) {
    return 'Sharing “$groupTitle”';
  }

  @override
  String sync_qr_expires_in(String time) {
    return 'Expires in $time';
  }

  @override
  String get sync_qr_expired_title => 'Code expired';

  @override
  String get sync_qr_expired_desc => 'Generate a new code to keep pairing';

  @override
  String get sync_qr_regenerate_button => 'Generate new code';

  @override
  String get sync_qr_no_network =>
      'Connect to Wi-Fi to generate the pairing code';

  @override
  String get sync_qr_scan_title => 'Scan the pairing code';

  @override
  String get sync_qr_scan_description => 'Scan the QR on the other device';

  @override
  String sync_qr_pair_success(String deviceName) {
    return 'Paired with $deviceName';
  }

  @override
  String get sync_qr_pair_failed =>
      'Pairing failed — make sure both devices are on the same Wi-Fi network';

  @override
  String get sync_qr_pair_expired =>
      'This pairing code has expired — ask the other device to show a new one';

  @override
  String get sync_qr_pair_emulator_host =>
      'This code was generated on an Android emulator, which can\'t be reached from other devices — pair using two physical devices on the same Wi-Fi network instead';

  @override
  String get sync_qr_emulator_warning =>
      'This device is an Android emulator — its address usually isn\'t reachable from other devices, so pairing may fail';

  @override
  String get sync_paired_devices_title => 'Paired devices';

  @override
  String get sync_paired_devices_empty => 'No paired devices yet';

  @override
  String get sync_paired_devices_remove => 'Remove pairing';

  @override
  String get search_expenses => 'Search expenses';

  @override
  String search_in_group(String groupName) {
    return 'Search in $groupName';
  }

  @override
  String get has_attachment => 'Has attachment';

  @override
  String get has_location => 'Has location';

  @override
  String get search_no_results => 'No expenses found';

  @override
  String get search_no_results_hint =>
      'Try different search terms or adjust filters';

  @override
  String get voice_input_button => 'Add by voice';

  @override
  String get voice_input_listening => 'Listening…';

  @override
  String get voice_input_tap_to_speak => 'Tap to speak';

  @override
  String get voice_input_processing => 'Processing…';

  @override
  String get voice_input_error => 'Voice recognition error';

  @override
  String get voice_input_permission_denied => 'Microphone permission denied';

  @override
  String get voice_input_not_available => 'Voice recognition not available';

  @override
  String get voice_input_no_speech => 'I didn\'t catch that. Try again.';

  @override
  String get voice_input_hint =>
      'Try saying: “50 dollars for dinner at the restaurant”';

  @override
  String get voice_add_expense => 'Add by voice';

  @override
  String get voice_expense_saved => 'Expense saved';

  @override
  String get voice_expense_needs_more_info =>
      'Some details are missing: complete the expense';

  @override
  String get from_unsplash => 'From Unsplash';

  @override
  String get unsplash_search_hint => 'Search photos on Unsplash…';

  @override
  String get unsplash_no_results => 'No images found';

  @override
  String get unsplash_downloading => 'Downloading photo…';

  @override
  String get unsplash_error => 'Failed to load images';

  @override
  String get unsplash_photos_by => 'Photos by';

  @override
  String get unsplash_use_photo => 'Use this photo';

  @override
  String get scan_receipt => 'Scan receipt';

  @override
  String get scanning_receipt => 'Reading receipt…';

  @override
  String get receipt_scan_error => 'Couldn’t read the receipt';

  @override
  String get receipt_scan_permission_denied =>
      'Camera not allowed: turn it on in your phone settings to read receipts';

  @override
  String get no_text_found => 'No text found in image';

  @override
  String get receipt_scanned => 'Receipt scanned';

  @override
  String get settings_group_templates_manage_title => 'Group templates';

  @override
  String get settings_group_templates_manage_desc =>
      'Create and edit your templates';

  @override
  String get settings_group_templates_page_title => 'Group templates';

  @override
  String get settings_group_templates_empty_state => 'No templates';

  @override
  String get settings_group_templates_add_title => 'New template';

  @override
  String get settings_group_templates_edit_title => 'Edit template';

  @override
  String get settings_group_templates_name_label => 'Template name';

  @override
  String get settings_group_templates_name_hint => 'E.g. Ski week';

  @override
  String get settings_group_templates_icon_label => 'Icon';

  @override
  String get settings_group_templates_categories_label => 'Default categories';

  @override
  String get settings_group_templates_validation_error =>
      'Name and at least one category are required';

  @override
  String get settings_group_templates_delete_title => 'Delete template';

  @override
  String settings_group_templates_delete_message(String templateName) {
    return 'Delete the template “$templateName”?';
  }

  @override
  String get clear_dates => 'Remove dates';

  @override
  String accessibility_map_marker_expense(String name, String amount) {
    return '$name, $amount';
  }

  @override
  String accessibility_map_marker_group(int count, String place) {
    return '$count expenses, $place';
  }

  @override
  String get nav_home => 'Home';

  @override
  String get nav_groups => 'Groups';

  @override
  String get quick_action_map => 'Map';

  @override
  String get quick_action_search => 'Search';

  @override
  String new_expense_in_group(String group) {
    return 'New expense in $group';
  }

  @override
  String groups_active_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active groups',
      one: '1 active group',
      zero: 'No active groups',
    );
    return '$_temp0';
  }

  @override
  String get get_started_title => 'Get started';

  @override
  String get_started_progress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get get_started_create_group => 'Create the group';

  @override
  String get get_started_first_expense => 'Add the first expense';

  @override
  String get get_started_participants => 'Add the participants';

  @override
  String get get_started_look => 'Choose a photo or a color';

  @override
  String get_started_step_done(String step) {
    return '$step, done';
  }

  @override
  String get balances => 'Balances';

  @override
  String get per_person => 'Per person';

  @override
  String get settle_up => 'Settle up';

  @override
  String get all_settled_up => 'All settled up';

  @override
  String balance_gets_back(String name, String amount) {
    return '$name gets back $amount';
  }

  @override
  String balance_owes(String name, String amount) {
    return '$name owes $amount';
  }

  @override
  String settlement_pays(String from, String to, String amount) {
    return '$from pays $to $amount';
  }

  @override
  String places_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get more_options => 'More options';

  @override
  String get highest_expense => 'Highest expense';

  @override
  String get most_expensive_day => 'Most expensive day';

  @override
  String get chart_day_by_day => 'Day by day';

  @override
  String get this_week => 'This week';

  @override
  String get last_week => 'Last week';

  @override
  String get quick_action_scan => 'Scan';

  @override
  String get quick_action_voice => 'Voice';

  @override
  String get sync_state_syncing => 'syncing';

  @override
  String get sync_state_synced => 'up to date';

  @override
  String get sync_state_error => 'sync failed, tap for details';

  @override
  String get share_balances => 'Share balances';

  @override
  String balances_share_title(String group) {
    return '$group · balances';
  }

  @override
  String balances_share_footer(String total, String perPerson) {
    return 'Total $total · $perPerson per person';
  }

  @override
  String balance_reminder_message(
    String from,
    String group,
    String amount,
    String to,
  ) {
    return 'Hi $from! For “$group” you owe $amount to $to.';
  }

  @override
  String get chart_week_by_week => 'Week by week';

  @override
  String get chart_month_by_month => 'Month by month';

  @override
  String get edit => 'Edit';

  @override
  String get recent_searches => 'Recent searches';

  @override
  String get by_type => 'By type';

  @override
  String get favorites => 'Favorites';

  @override
  String get all_groups => 'All';

  @override
  String get status_label => 'Status';

  @override
  String show_results(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count results',
      one: 'Show 1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get expense_details_section => 'Details';

  @override
  String get add_expense_button => 'Add expense';

  @override
  String auto_backup_last(String date) {
    return 'Last backup: $date';
  }

  @override
  String get auto_backup_never => 'No backup yet';

  @override
  String get auto_backup_off => 'Off: data left out of backups';

  @override
  String get drive_backup_connect => 'Connect Google Drive';

  @override
  String get drive_backup_connect_desc => 'Backups in a private folder';

  @override
  String get drive_backup_now => 'Back up to Drive now';

  @override
  String get drive_backup_none => 'No backup on Drive yet';

  @override
  String get drive_backup_restore => 'Restore from Drive';

  @override
  String get drive_backup_restore_desc => 'Choose one of the last 5 backups';

  @override
  String get drive_backup_weekly => 'Weekly backup';

  @override
  String get drive_backup_weekly_desc => 'Every week, when you open the app';

  @override
  String get drive_backup_disconnect => 'Disconnect';

  @override
  String get drive_backup_saved => 'Backup saved to Google Drive';

  @override
  String get drive_backup_error => 'Couldn\'t reach Google Drive';

  @override
  String get expense_more_details => 'More details';

  @override
  String get quick_action_photo => 'Photo';

  @override
  String get photo_add_expense => 'New expense from a receipt photo';

  @override
  String get receipt_photo_error => 'Couldn\'t take the receipt photo';

  @override
  String get crop_hint => 'Drag and pinch to choose the part to keep';

  @override
  String get crop_preview => 'Preview';

  @override
  String get crop_use_photo => 'Use this photo';

  @override
  String get welcome_tagline =>
      'Expenses for trips, home and friends, split fairly. Everything stays on your phone.';

  @override
  String get wizard_name_title => 'What\'s your name?';

  @override
  String get wizard_name_note =>
      'It stays on your phone. You\'ll be the first participant of your groups.';

  @override
  String get wizard_type_title => 'What kind of group?';

  @override
  String get wizard_type_note =>
      'It sets the starting categories: you can change them anytime.';

  @override
  String get group_type_personal_desc => 'Just your own spending';

  @override
  String get group_type_family_desc => 'Home, family, flatmates';

  @override
  String get group_type_travel_desc => 'Holidays, weekends, trips';

  @override
  String get group_type_other_desc => 'Dinners, events, gifts';

  @override
  String get wizard_details_title => 'What shall we call it?';

  @override
  String get wizard_details_note =>
      'Dates feed the spending chart. You can change everything later.';

  @override
  String wizard_people_you(String name) {
    return '$name (you)';
  }

  @override
  String get wizard_people_add_hint => 'A friend\'s name';

  @override
  String wizard_people_remove(String name) {
    return 'Remove $name';
  }

  @override
  String get wizard_dates_add => 'Dates';

  @override
  String get wizard_continue => 'Continue';

  @override
  String get wizard_create => 'Create group';

  @override
  String get attachment_take_photo => 'Take a photo';

  @override
  String get attachment_record_video => 'Record a video';

  @override
  String get place_search_action => 'Search for a place';

  @override
  String get background_photo => 'Photo';

  @override
  String get background_none => 'None';

  @override
  String get stats_pace_title => 'Spending pace';

  @override
  String get stats_per_day => 'per day';

  @override
  String get stats_per_month => 'per month';

  @override
  String stats_pace_days(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Average over $count days',
      one: 'Over 1 day',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_pace_months(int count, String range) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Average over $count months',
      one: 'Over 1 month',
    );
    return '$_temp0 · $range';
  }

  @override
  String stats_per_expense(String amount) {
    return '$amount per expense';
  }

  @override
  String stats_active_days(int active, int total) {
    return '$active of $total days with expenses';
  }

  @override
  String stats_active_months(int active, int total) {
    return '$active of $total months with expenses';
  }

  @override
  String get most_expensive_month => 'Most expensive month';

  @override
  String get per_month => '/month';

  @override
  String get map_location_off =>
      'Turn on automatic location to see expenses on the map';

  @override
  String get map_no_places => 'No expenses with a place yet';

  @override
  String get no_active_groups_subtitle =>
      'Create one for a trip, a shared flat or an event.';

  @override
  String get export_options_empty => 'No expenses to export yet';
}
