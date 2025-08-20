import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @settings_flag_secure_desc.
  ///
  /// In en, this message translates to:
  /// **'Prevents screenshots and screen recording'**
  String get settings_flag_secure_desc;

  /// No description provided for @settings_flag_secure_title.
  ///
  /// In en, this message translates to:
  /// **'Secure screen'**
  String get settings_flag_secure_title;

  /// No description provided for @select_currency.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get select_currency;

  /// No description provided for @select_period_hint_short.
  ///
  /// In en, this message translates to:
  /// **'Set dates'**
  String get select_period_hint_short;

  /// No description provided for @select_period_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a date range'**
  String get select_period_hint;

  /// No description provided for @save_change_expense.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get save_change_expense;

  /// No description provided for @group_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get group_total;

  /// No description provided for @download_all_csv.
  ///
  /// In en, this message translates to:
  /// **'Download all (CSV)'**
  String get download_all_csv;

  /// No description provided for @share_all_csv.
  ///
  /// In en, this message translates to:
  /// **'Share all (CSV)'**
  String get share_all_csv;

  /// No description provided for @welcome_v3_title.
  ///
  /// In en, this message translates to:
  /// **'Organize.\nShare.\nSettle.\n '**
  String get welcome_v3_title;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get good_evening;

  /// No description provided for @your_groups.
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get your_groups;

  /// No description provided for @no_active_groups.
  ///
  /// In en, this message translates to:
  /// **'No active groups'**
  String get no_active_groups;

  /// No description provided for @no_active_groups_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first expense group to get started'**
  String get no_active_groups_subtitle;

  /// No description provided for @create_first_group.
  ///
  /// In en, this message translates to:
  /// **'Create first group'**
  String get create_first_group;

  /// No description provided for @new_expense_group.
  ///
  /// In en, this message translates to:
  /// **'New Expense Group'**
  String get new_expense_group;

  /// No description provided for @tap_to_create.
  ///
  /// In en, this message translates to:
  /// **'Tap to create'**
  String get tap_to_create;

  /// No description provided for @no_expense_label.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get no_expense_label;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @select_image.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get select_image;

  /// No description provided for @change_image.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get change_image;

  /// No description provided for @from_gallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get from_gallery;

  /// No description provided for @from_camera.
  ///
  /// In en, this message translates to:
  /// **'From Camera'**
  String get from_camera;

  /// No description provided for @remove_image.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get remove_image;

  /// No description provided for @no_trips_found.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to go?'**
  String get no_trips_found;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @participants_label.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants_label;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get last_7_days;

  /// No description provided for @recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recent_activity;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @license_hint.
  ///
  /// In en, this message translates to:
  /// **'This app is released under the MIT license.'**
  String get license_hint;

  /// No description provided for @license_link.
  ///
  /// In en, this message translates to:
  /// **'View MIT License on GitHub'**
  String get license_link;

  /// No description provided for @license_section.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license_section;

  /// No description provided for @add_trip.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get add_trip;

  /// No description provided for @new_group.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get new_group;

  /// No description provided for @group_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get group_name;

  /// No description provided for @enter_title.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enter_title;

  /// No description provided for @enter_participant.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one participant'**
  String get enter_participant;

  /// No description provided for @select_start.
  ///
  /// In en, this message translates to:
  /// **'Select start'**
  String get select_start;

  /// No description provided for @select_end.
  ///
  /// In en, this message translates to:
  /// **'Select end'**
  String get select_end;

  /// No description provided for @start_date_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Select start'**
  String get start_date_not_selected;

  /// No description provided for @end_date_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Select end'**
  String get end_date_not_selected;

  /// No description provided for @select_from_date.
  ///
  /// In en, this message translates to:
  /// **'Select from'**
  String get select_from_date;

  /// No description provided for @select_to_date.
  ///
  /// In en, this message translates to:
  /// **'Select to'**
  String get select_to_date;

  /// No description provided for @date_range_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get date_range_not_selected;

  /// No description provided for @date_range_partial.
  ///
  /// In en, this message translates to:
  /// **'Select both dates'**
  String get date_range_partial;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete_trip.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get delete_trip;

  /// No description provided for @delete_trip_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip?'**
  String get delete_trip_confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @from_to.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String from_to(Object end, Object start);

  /// No description provided for @add_expense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get add_expense;

  /// No description provided for @edit_expense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get edit_expense;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @invalid_amount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalid_amount;

  /// No description provided for @no_categories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get no_categories;

  /// No description provided for @add_category.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get add_category;

  /// No description provided for @category_name.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get category_name;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @note_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get note_hint;

  /// No description provided for @select_both_dates.
  ///
  /// In en, this message translates to:
  /// **'If you select one date, you must select both'**
  String get select_both_dates;

  /// No description provided for @select_both_dates_or_none.
  ///
  /// In en, this message translates to:
  /// **'Select both dates or leave both empty'**
  String get select_both_dates_or_none;

  /// No description provided for @end_date_after_start.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get end_date_after_start;

  /// No description provided for @start_date_optional.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get start_date_optional;

  /// No description provided for @end_date_optional.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get end_date_optional;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get dates;

  /// No description provided for @expenses_by_participant.
  ///
  /// In en, this message translates to:
  /// **'By participant'**
  String get expenses_by_participant;

  /// No description provided for @expenses_by_category.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get expenses_by_category;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @no_trips_to_backup.
  ///
  /// In en, this message translates to:
  /// **'No trips to backup'**
  String get no_trips_to_backup;

  /// No description provided for @backup_error.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backup_error;

  /// No description provided for @backup_share_message.
  ///
  /// In en, this message translates to:
  /// **'Here is your Caravella backup'**
  String get backup_share_message;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @import_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get import_confirm_title;

  /// No description provided for @import_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to overwrite all trips with the file \"{file}\"? This action cannot be undone.'**
  String import_confirm_message(Object file);

  /// No description provided for @import_success.
  ///
  /// In en, this message translates to:
  /// **'Import successful! Data reloaded.'**
  String get import_success;

  /// No description provided for @import_error.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check the file format.'**
  String get import_error;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @participant_name.
  ///
  /// In en, this message translates to:
  /// **'Participant name'**
  String get participant_name;

  /// No description provided for @participant_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter participant name'**
  String get participant_name_hint;

  /// No description provided for @edit_participant.
  ///
  /// In en, this message translates to:
  /// **'Edit participant'**
  String get edit_participant;

  /// No description provided for @delete_participant.
  ///
  /// In en, this message translates to:
  /// **'Delete participant'**
  String get delete_participant;

  /// No description provided for @add_participant.
  ///
  /// In en, this message translates to:
  /// **'Add participant'**
  String get add_participant;

  /// No description provided for @no_participants.
  ///
  /// In en, this message translates to:
  /// **'No participants'**
  String get no_participants;

  /// No description provided for @category_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get category_name_hint;

  /// No description provided for @edit_category.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get edit_category;

  /// No description provided for @delete_category.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get delete_category;

  /// No description provided for @participant_name_semantics.
  ///
  /// In en, this message translates to:
  /// **'Participant: {name}'**
  String participant_name_semantics(Object name);

  /// No description provided for @category_name_semantics.
  ///
  /// In en, this message translates to:
  /// **'Category: {name}'**
  String category_name_semantics(Object name);

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @settings_tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_tab;

  /// No description provided for @basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basic_info;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @search_groups.
  ///
  /// In en, this message translates to:
  /// **'Search groups...'**
  String get search_groups;

  /// No description provided for @no_search_results.
  ///
  /// In en, this message translates to:
  /// **'No groups found for'**
  String get no_search_results;

  /// No description provided for @try_different_search.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different words'**
  String get try_different_search;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @archive_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to archive'**
  String get archive_confirm;

  /// No description provided for @unarchive_confirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to unarchive'**
  String get unarchive_confirm;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @show_overview.
  ///
  /// In en, this message translates to:
  /// **'Show overview'**
  String get show_overview;

  /// No description provided for @show_statistics.
  ///
  /// In en, this message translates to:
  /// **'Show statistics'**
  String get show_statistics;

  /// No description provided for @no_expenses_to_display.
  ///
  /// In en, this message translates to:
  /// **'No expenses to display'**
  String get no_expenses_to_display;

  /// No description provided for @no_expenses_to_analyze.
  ///
  /// In en, this message translates to:
  /// **'No expenses to analyze'**
  String get no_expenses_to_analyze;

  /// No description provided for @select_expense_date.
  ///
  /// In en, this message translates to:
  /// **'Select expense date'**
  String get select_expense_date;

  /// No description provided for @select_expense_date_short.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get select_expense_date_short;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @edit_group.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get edit_group;

  /// No description provided for @delete_group.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get delete_group;

  /// No description provided for @delete_group_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense group? This action cannot be undone.'**
  String get delete_group_confirm;

  /// No description provided for @add_expense_fab.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get add_expense_fab;

  /// No description provided for @pin_group.
  ///
  /// In en, this message translates to:
  /// **'Pin group'**
  String get pin_group;

  /// No description provided for @unpin_group.
  ///
  /// In en, this message translates to:
  /// **'Unpin group'**
  String get unpin_group;

  /// No description provided for @theme_automatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get theme_automatic;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @developed_by.
  ///
  /// In en, this message translates to:
  /// **'Developed by calca'**
  String get developed_by;

  /// No description provided for @links.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get links;

  /// No description provided for @daily_expenses_chart.
  ///
  /// In en, this message translates to:
  /// **'Daily expenses'**
  String get daily_expenses_chart;

  /// No description provided for @weekly_expenses_chart.
  ///
  /// In en, this message translates to:
  /// **'Weekly expenses'**
  String get weekly_expenses_chart;

  /// No description provided for @daily_average_by_category.
  ///
  /// In en, this message translates to:
  /// **'Daily average by category'**
  String get daily_average_by_category;

  /// No description provided for @per_day.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get per_day;

  /// No description provided for @no_expenses_for_statistics.
  ///
  /// In en, this message translates to:
  /// **'No expenses available for statistics'**
  String get no_expenses_for_statistics;

  /// No description provided for @settlement.
  ///
  /// In en, this message translates to:
  /// **'Settlement'**
  String get settlement;

  /// No description provided for @all_balanced.
  ///
  /// In en, this message translates to:
  /// **'All accounts are balanced!'**
  String get all_balanced;

  /// No description provided for @owes_to.
  ///
  /// In en, this message translates to:
  /// **' owes '**
  String get owes_to;

  /// No description provided for @export_csv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get export_csv;

  /// No description provided for @no_expenses_to_export.
  ///
  /// In en, this message translates to:
  /// **'No expenses to export'**
  String get no_expenses_to_export;

  /// No description provided for @export_csv_share_text.
  ///
  /// In en, this message translates to:
  /// **'Expenses exported from '**
  String get export_csv_share_text;

  /// No description provided for @export_csv_error.
  ///
  /// In en, this message translates to:
  /// **'Error exporting expenses'**
  String get export_csv_error;

  /// No description provided for @expense_name.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expense_name;

  /// No description provided for @paid_by.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get paid_by;

  /// No description provided for @expense_added_success.
  ///
  /// In en, this message translates to:
  /// **'Expense added'**
  String get expense_added_success;

  /// No description provided for @expense_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Expense updated'**
  String get expense_updated_success;

  /// No description provided for @data_refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing…'**
  String get data_refreshing;

  /// No description provided for @data_refreshed.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get data_refreshed;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @group_added_success.
  ///
  /// In en, this message translates to:
  /// **'Group added'**
  String get group_added_success;

  /// No description provided for @csv_select_directory_title.
  ///
  /// In en, this message translates to:
  /// **'Select folder to save CSV'**
  String get csv_select_directory_title;

  /// No description provided for @csv_saved_in.
  ///
  /// In en, this message translates to:
  /// **'CSV saved in: {path}'**
  String csv_saved_in(Object path);

  /// No description provided for @csv_save_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled'**
  String get csv_save_cancelled;

  /// No description provided for @csv_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error saving CSV file'**
  String get csv_save_error;

  /// No description provided for @csv_expense_name.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get csv_expense_name;

  /// No description provided for @csv_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get csv_amount;

  /// No description provided for @csv_paid_by.
  ///
  /// In en, this message translates to:
  /// **'Paid by'**
  String get csv_paid_by;

  /// No description provided for @csv_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get csv_category;

  /// No description provided for @csv_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get csv_date;

  /// No description provided for @csv_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get csv_note;

  /// No description provided for @csv_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get csv_location;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @location_hint.
  ///
  /// In en, this message translates to:
  /// **'Add location (optional)'**
  String get location_hint;

  /// No description provided for @get_current_location.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get get_current_location;

  /// No description provided for @enter_location_manually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enter_location_manually;

  /// No description provided for @location_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get location_permission_denied;

  /// No description provided for @location_service_disabled.
  ///
  /// In en, this message translates to:
  /// **'Location service disabled'**
  String get location_service_disabled;

  /// No description provided for @getting_location.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get getting_location;

  /// No description provided for @location_error.
  ///
  /// In en, this message translates to:
  /// **'Error getting location'**
  String get location_error;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_it.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get settings_language_it;

  /// No description provided for @settings_language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_select_language.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settings_select_language;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settings_select_theme;

  /// No description provided for @settings_data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settings_data;

  /// No description provided for @settings_data_manage.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get settings_data_manage;

  /// No description provided for @settings_data_desc.
  ///
  /// In en, this message translates to:
  /// **'Backup and restore'**
  String get settings_data_desc;

  /// No description provided for @settings_info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get settings_info;

  /// No description provided for @settings_app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_app_version;

  /// No description provided for @settings_info_card.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get settings_info_card;

  /// No description provided for @settings_info_card_desc.
  ///
  /// In en, this message translates to:
  /// **'Developer, Source code and License'**
  String get settings_info_card_desc;

  /// No description provided for @terms_github_title.
  ///
  /// In en, this message translates to:
  /// **'GitHub: calca'**
  String get terms_github_title;

  /// No description provided for @terms_github_desc.
  ///
  /// In en, this message translates to:
  /// **'Developer profile on GitHub.'**
  String get terms_github_desc;

  /// No description provided for @terms_repo_title.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get terms_repo_title;

  /// No description provided for @terms_repo_desc.
  ///
  /// In en, this message translates to:
  /// **'Application source code.'**
  String get terms_repo_desc;

  /// No description provided for @terms_issue_title.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get terms_issue_title;

  /// No description provided for @terms_issue_desc.
  ///
  /// In en, this message translates to:
  /// **'Go to the GitHub issues page.'**
  String get terms_issue_desc;

  /// No description provided for @terms_license_desc.
  ///
  /// In en, this message translates to:
  /// **'View the open source license.'**
  String get terms_license_desc;

  /// No description provided for @data_title.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get data_title;

  /// No description provided for @data_backup_title.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get data_backup_title;

  /// No description provided for @data_backup_desc.
  ///
  /// In en, this message translates to:
  /// **'Create a backup file of your expenses.'**
  String get data_backup_desc;

  /// No description provided for @data_restore_title.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get data_restore_title;

  /// No description provided for @data_restore_desc.
  ///
  /// In en, this message translates to:
  /// **'Import a backup to restore your data.'**
  String get data_restore_desc;

  /// No description provided for @info_tab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info_tab;

  /// No description provided for @select_paid_by.
  ///
  /// In en, this message translates to:
  /// **'Select payer'**
  String get select_paid_by;

  /// No description provided for @select_category.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get select_category;

  /// No description provided for @check_form.
  ///
  /// In en, this message translates to:
  /// **'Check the entered data'**
  String get check_form;

  /// No description provided for @delete_expense.
  ///
  /// In en, this message translates to:
  /// **'Delete expense'**
  String get delete_expense;

  /// No description provided for @delete_expense_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get delete_expense_confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @no_results_found.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get no_results_found;

  /// No description provided for @try_adjust_filter_or_search.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the filter or search.'**
  String get try_adjust_filter_or_search;

  /// No description provided for @general_statistics.
  ///
  /// In en, this message translates to:
  /// **'General statistics'**
  String get general_statistics;

  /// No description provided for @average_expense.
  ///
  /// In en, this message translates to:
  /// **'Average expense'**
  String get average_expense;

  /// No description provided for @welcome_v3_cta.
  ///
  /// In en, this message translates to:
  /// **'Get started!'**
  String get welcome_v3_cta;

  /// No description provided for @discard_changes_title.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discard_changes_title;

  /// No description provided for @discard_changes_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard unsaved changes?'**
  String get discard_changes_message;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @category_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category_placeholder;

  /// No description provided for @image_requirements.
  ///
  /// In en, this message translates to:
  /// **'PNG, JPG, GIF (max 10MB)'**
  String get image_requirements;

  /// No description provided for @error_saving_group.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String error_saving_group(Object error);

  /// No description provided for @error_selecting_image.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get error_selecting_image;

  /// No description provided for @error_saving_image.
  ///
  /// In en, this message translates to:
  /// **'Error saving image'**
  String get error_saving_image;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
