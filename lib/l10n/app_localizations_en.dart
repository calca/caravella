// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get select_currency => 'Select currency';

  @override
  String get select_period_hint_short => 'Set dates';

  @override
  String get select_period_hint => 'Select a date range';

  @override
  String get save_change_expense => 'Save changes';

  @override
  String get group_total => 'Total';

  @override
  String get download_all_csv => 'Download all (CSV)';

  @override
  String get share_all_csv => 'Share all (CSV)';

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
  String get no_active_groups_subtitle =>
      'Create your first expense group to get started';

  @override
  String get create_first_group => 'Create first group';

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
  String get no_trips_found => 'Where do you want to go?';

  @override
  String get expenses => 'Expenses';

  @override
  String get participants => 'Participants';

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
  String get settings_general => 'General';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_it => 'Italian';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_select_language => 'Select language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_select_theme => 'Select theme';

  @override
  String get settings_data => 'Data';

  @override
  String get settings_data_manage => 'Data management';

  @override
  String get settings_data_desc => 'Backup and restore';

  @override
  String get settings_info => 'Information';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_info_card => 'Information';

  @override
  String get settings_info_card_desc => 'Developer, Source code and License';

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
  String get delete => 'Delete';

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
}
