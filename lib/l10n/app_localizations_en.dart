// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get developer_section_title => 'Developer & Support';

  @override
  String get developer_section_desc => 'Support the developer or view profile';

  @override
  String get repo_section_title => 'Source & Issues';

  @override
  String get repo_section_desc => 'View source code or report a problem';

  @override
  String get license_section_title => 'License';

  @override
  String get license_section_desc => 'View the open source license';

  @override
  String get weeklyChartBadge => 'W';

  @override
  String get monthlyChartBadge => 'M';

  @override
  String get weeklyExpensesChart => 'Weekly expenses';

  @override
  String get monthlyExpensesChart => 'Monthly expenses';

  @override
  String get settings_flag_secure_desc =>
      'Prevents screenshots and screen recording';

  @override
  String get settings_flag_secure_title => 'Secure screen';

  @override
  String get settings_privacy => 'Privacy';

  @override
  String get select_currency => 'Select currency';

  @override
  String get select_period_hint_short => 'Set dates';

  @override
  String get select_period_hint => 'Select dates';

  @override
  String get suggested_duration => 'Suggested duration';

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
  String get save_change_expense => 'Save changes';

  @override
  String get group_total => 'Total';

  @override
  String get total_spent => 'Total spent';

  @override
  String get download_all_csv => 'Download all (CSV)';

  @override
  String get share_all_csv => 'Share all (CSV)';

  @override
  String get download_all_ofx => 'Download all (OFX)';

  @override
  String get share_all_ofx => 'Share all (OFX)';

  @override
  String get share_label => 'Share';

  @override
  String get share_text_label => 'Share text';

  @override
  String get share_image_label => 'Share image';

  @override
  String get export_share => 'Export & Share';

  @override
  String get contribution_percentages => 'Percentages';

  @override
  String get contribution_percentages_desc =>
      'Share of total paid by each participant';

  @override
  String get export_options => 'Export Options';

  @override
  String get welcome_v3_title => 'Organize.\nShare.\nSettle.\n ';

  @override
  String get good_morning => 'Good morning';

  @override
  String get good_afternoon => 'Good afternoon';

  @override
  String get good_evening => 'Good evening';

  @override
  String get your_groups => 'Your groups';

  @override
  String get no_active_groups => 'No active groups';

  @override
  String get no_active_groups_subtitle => 'Create an expense group';

  @override
  String get create_first_group => 'Create a group';

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
  String get group_name => 'Name';

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
  String get save => 'Save';

  @override
  String get delete_trip => 'Delete trip';

  @override
  String get delete_trip_confirm =>
      'Are you sure you want to delete this trip?';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String from_to(Object end, Object start) {
    return '$start - $end';
  }

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
  String get no_categories => 'No categories';

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
  String get backup_error => 'Backup failed';

  @override
  String get backup_share_message => 'Here is your Caravella backup';

  @override
  String get import => 'Import';

  @override
  String get import_confirm_title => 'Import data';

  @override
  String import_confirm_message(Object file) {
    return 'Are you sure you want to overwrite all trips with the file \"$file\"? This action cannot be undone.';
  }

  @override
  String get import_success => 'Import successful! Data reloaded.';

  @override
  String get import_error => 'Import failed. Check the file format.';

  @override
  String get categories => 'Categories';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get add => 'Add';

  @override
  String get participant_name => 'Participant name';

  @override
  String get participant_name_hint => 'Enter participant name';

  @override
  String get edit_participant => 'Edit participant';

  @override
  String get delete_participant => 'Delete participant';

  @override
  String get add_participant => 'Add participant';

  @override
  String get no_participants => 'No participants';

  @override
  String get category_name_hint => 'Enter category name';

  @override
  String get edit_category => 'Edit category';

  @override
  String get delete_category => 'Delete category';

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
  String get settings => 'Settings';

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
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'UNDO';

  @override
  String get archived_with_undo => 'Archived';

  @override
  String get unarchived_with_undo => 'Unarchived';

  @override
  String get pinned_with_undo => 'Pinned';

  @override
  String get unpinned_with_undo => 'Unpinned';

  @override
  String get deleted_with_undo => 'Deleted';

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
  String get date => 'Date';

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
  String get theme_automatic => 'Automatic';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

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
  String get paid_by => 'Paid by';

  @override
  String get expense_added_success => 'Expense added';

  @override
  String get expense_updated_success => 'Expense updated';

  @override
  String get data_refreshing => 'Refreshing…';

  @override
  String get data_refreshed => 'Updated';

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
  String get settings_general => 'General';

  @override
  String get settings_general_desc => 'Language and appearance settings';

  @override
  String get settings_auto_location_title => 'Detect location';

  @override
  String get settings_auto_location_desc =>
      'Enable to automatically detect GPS';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_desc => 'Choose your preferred language';

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
  String get settings_select_language => 'Select language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_desc => 'Light, dark or system';

  @override
  String get settings_select_theme => 'Select theme';

  @override
  String get settings_dynamic_color => 'Dynamic color';

  @override
  String get settings_dynamic_color_desc => 'Use colors from your wallpaper';

  @override
  String get settings_privacy_desc => 'Security and privacy options';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_data_desc => 'Manage your information';

  @override
  String get settings_data_manage => 'Data management';

  @override
  String get settings_info => 'Information';

  @override
  String get settings_info_desc => 'App details and support';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_info_card => 'Information';

  @override
  String get settings_info_card_desc => 'Developer, Source code and License';

  @override
  String get terms_github_title => 'Website: calca';

  @override
  String get terms_github_desc => 'Developer\'s personal website.';

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
  String get no_results_found => 'No results found.';

  @override
  String get try_adjust_filter_or_search =>
      'Try adjusting the filter or search.';

  @override
  String get general_statistics => 'General statistics';

  @override
  String get add_first_expense => 'Add the first expense to get started';

  @override
  String get overview_and_statistics => 'Overview and statistics';

  @override
  String get daily_average => 'Daily';

  @override
  String get spent_today => 'Today';

  @override
  String get monthly_average => 'Monthly';

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
    return 'Security switch - $state';
  }

  @override
  String get accessibility_switch_on => 'On';

  @override
  String get accessibility_switch_off => 'Off';

  @override
  String get accessibility_image_source_dialog =>
      'Image source selection dialog';

  @override
  String get accessibility_currently_enabled => 'Currently enabled';

  @override
  String get accessibility_currently_disabled => 'Currently disabled';

  @override
  String get accessibility_double_tap_disable =>
      'Double tap to disable screen security';

  @override
  String get accessibility_double_tap_enable =>
      'Double tap to enable screen security';

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
  String get whats_new_title => 'What\'s New';

  @override
  String get whats_new_desc => 'Discover the latest features and updates';

  @override
  String get whats_new_subtitle => 'Latest highlights';

  @override
  String get whats_new_latest => 'Stay up to date with recent improvements';

  @override
  String get changelog_title => 'Changelog';

  @override
  String get changelog_desc => 'Version history and improvements';

  @override
  String get average_per_person => 'Average per person';

  @override
  String get more => 'more';

  @override
  String get less => 'less';

  @override
  String get debt_prefix_to => 'to ';

  @override
  String get check_for_updates => 'Check for updates';

  @override
  String get check_for_updates_desc => 'Check for new version availability';

  @override
  String get update_available => 'Update available';

  @override
  String get update_available_desc => 'A new version of the app is available';

  @override
  String get no_update_available => 'App up to date';

  @override
  String get no_update_available_desc => 'You\'re using the latest version';

  @override
  String get update_now => 'Update now';

  @override
  String get update_later => 'Later';

  @override
  String get checking_for_updates => 'Checking for updates...';

  @override
  String get update_error => 'Update check error';

  @override
  String get update_downloading => 'Downloading...';

  @override
  String get update_installing => 'Installing...';

  @override
  String get update_feature_android_only =>
      'Feature only available on Android with Google Play Store';

  @override
  String get update_recommendation_title => 'Update recommended';

  @override
  String get update_recommendation_desc =>
      'A new version of Caravella is available. Update the app to always have the latest features and improvements!';

  @override
  String get update_install => 'Install update';

  @override
  String get update_remind_later => 'Remind me later';

  @override
  String get send_reminder => 'Send reminder';

  @override
  String reminder_message_single(
    Object participantName,
    Object amount,
    Object creditorName,
    Object groupName,
  ) {
    return 'Hi $participantName! 👋\n\nJust a friendly reminder that you owe $amount to $creditorName for the group \"$groupName\".\n\nThank you! 😊';
  }

  @override
  String reminder_message_multiple(
    Object participantName,
    Object groupName,
    Object debtsList,
  ) {
    return 'Hi $participantName! 👋\n\nJust a friendly reminder of your payments for the group \"$groupName\":\n\n$debtsList\n\nThank you! 😊';
  }
}
