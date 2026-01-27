import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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
    Locale('es'),
    Locale('it'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// Section title for developer and support links in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'Developer & Support'**
  String get developer_section_title;

  /// Section description for developer and support links in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'Support the developer or view profile'**
  String get developer_section_desc;

  /// Section title for repository and issues links in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'Source & Issues'**
  String get repo_section_title;

  /// Section description for repository and issues links in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'View source code or report a problem'**
  String get repo_section_desc;

  /// Section title for license link in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license_section_title;

  /// Section description for license link in DeveloperPage
  ///
  /// In en, this message translates to:
  /// **'View the open source license'**
  String get license_section_desc;

  /// Letter indicator for weekly chart badge
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weeklyChartBadge;

  /// Letter indicator for monthly chart badge
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get monthlyChartBadge;

  /// Letter indicator for date range chart badge
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get dateRangeChartBadge;

  /// Label for weekly expenses chart
  ///
  /// In en, this message translates to:
  /// **'Weekly expenses'**
  String get weeklyExpensesChart;

  /// Label for monthly expenses chart
  ///
  /// In en, this message translates to:
  /// **'Monthly expenses'**
  String get monthlyExpensesChart;

  /// Label for date range expenses chart
  ///
  /// In en, this message translates to:
  /// **'Date range expenses'**
  String get dateRangeExpensesChart;

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

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

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
  /// **'Select dates'**
  String get select_period_hint;

  /// No description provided for @suggested_duration.
  ///
  /// In en, this message translates to:
  /// **'Suggested duration'**
  String get suggested_duration;

  /// Number of days
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days_count(int count);

  /// No description provided for @weekday_mon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekday_mon;

  /// No description provided for @weekday_tue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday_tue;

  /// No description provided for @weekday_wed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekday_wed;

  /// No description provided for @weekday_thu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday_thu;

  /// No description provided for @weekday_fri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekday_fri;

  /// No description provided for @weekday_sat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday_sat;

  /// No description provided for @weekday_sun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday_sun;

  /// No description provided for @month_january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month_january;

  /// No description provided for @month_february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month_february;

  /// No description provided for @month_march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month_march;

  /// No description provided for @month_april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month_april;

  /// No description provided for @month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month_may;

  /// No description provided for @month_june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month_june;

  /// No description provided for @month_july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month_july;

  /// No description provided for @month_august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month_august;

  /// No description provided for @month_september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month_september;

  /// No description provided for @month_october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month_october;

  /// No description provided for @month_november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month_november;

  /// No description provided for @month_december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month_december;

  /// No description provided for @in_group_prefix.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get in_group_prefix;

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

  /// Label shown before the total amount spent in the group
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get total_spent;

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

  /// No description provided for @download_all_ofx.
  ///
  /// In en, this message translates to:
  /// **'Download all (OFX)'**
  String get download_all_ofx;

  /// No description provided for @share_all_ofx.
  ///
  /// In en, this message translates to:
  /// **'Share all (OFX)'**
  String get share_all_ofx;

  /// No description provided for @download_all_markdown.
  ///
  /// In en, this message translates to:
  /// **'Download all (Markdown)'**
  String get download_all_markdown;

  /// No description provided for @share_all_markdown.
  ///
  /// In en, this message translates to:
  /// **'Share all (Markdown)'**
  String get share_all_markdown;

  /// No description provided for @markdown_select_directory_title.
  ///
  /// In en, this message translates to:
  /// **'Select folder to save Markdown'**
  String get markdown_select_directory_title;

  /// Toast message when Markdown export is saved
  ///
  /// In en, this message translates to:
  /// **'Markdown saved in: {path}'**
  String markdown_saved_in(String path);

  /// No description provided for @markdown_save_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Markdown export cancelled'**
  String get markdown_save_cancelled;

  /// No description provided for @markdown_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error saving Markdown file'**
  String get markdown_save_error;

  /// No description provided for @share_label.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share_label;

  /// No description provided for @share_text_label.
  ///
  /// In en, this message translates to:
  /// **'Share text'**
  String get share_text_label;

  /// No description provided for @share_image_label.
  ///
  /// In en, this message translates to:
  /// **'Share image'**
  String get share_image_label;

  /// No description provided for @export_share.
  ///
  /// In en, this message translates to:
  /// **'Export & Share'**
  String get export_share;

  /// No description provided for @contribution_percentages.
  ///
  /// In en, this message translates to:
  /// **'Percentages'**
  String get contribution_percentages;

  /// No description provided for @contribution_percentages_desc.
  ///
  /// In en, this message translates to:
  /// **'Share of total paid by each participant'**
  String get contribution_percentages_desc;

  /// No description provided for @export_options.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get export_options;

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

  /// CTA label to open the history page and see all groups
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get see_all;

  /// No description provided for @no_active_groups.
  ///
  /// In en, this message translates to:
  /// **'No active groups'**
  String get no_active_groups;

  /// No description provided for @no_active_groups_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an expense group'**
  String get no_active_groups_subtitle;

  /// No description provided for @create_first_group.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get create_first_group;

  /// No description provided for @new_expense_group.
  ///
  /// In en, this message translates to:
  /// **'New Expense Group'**
  String get new_expense_group;

  /// No description provided for @new_expense.
  ///
  /// In en, this message translates to:
  /// **'New Expense'**
  String get new_expense;

  /// No description provided for @edit_expense.
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get edit_expense;

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

  /// Shown when attempting to delete a participant that is used by existing expenses
  ///
  /// In en, this message translates to:
  /// **'Cannot delete participant: it\'s assigned to one or more expenses'**
  String get cannot_delete_assigned_participant;

  /// Shown when attempting to delete a category that is used by existing expenses
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category: it\'s assigned to one or more expenses'**
  String get cannot_delete_assigned_category;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @remove_color.
  ///
  /// In en, this message translates to:
  /// **'Remove Color'**
  String get remove_color;

  /// No description provided for @color_alternative.
  ///
  /// In en, this message translates to:
  /// **'Alternative to image'**
  String get color_alternative;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @select_background.
  ///
  /// In en, this message translates to:
  /// **'Select Background'**
  String get select_background;

  /// No description provided for @background_options.
  ///
  /// In en, this message translates to:
  /// **'Background Options'**
  String get background_options;

  /// No description provided for @choose_image_or_color.
  ///
  /// In en, this message translates to:
  /// **'Choose image or color'**
  String get choose_image_or_color;

  /// No description provided for @participants_description.
  ///
  /// In en, this message translates to:
  /// **'People sharing costs'**
  String get participants_description;

  /// No description provided for @categories_description.
  ///
  /// In en, this message translates to:
  /// **'Group expenses by type'**
  String get categories_description;

  /// No description provided for @dates_description.
  ///
  /// In en, this message translates to:
  /// **'Optional start and end'**
  String get dates_description;

  /// No description provided for @select_period.
  ///
  /// In en, this message translates to:
  /// **'Select period'**
  String get select_period;

  /// No description provided for @select_period_dates.
  ///
  /// In en, this message translates to:
  /// **'Select the period dates'**
  String get select_period_dates;

  /// Label for duration in days
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String duration_days(int days);

  /// Formatted period
  ///
  /// In en, this message translates to:
  /// **'From {start} to {end} ({days} days)'**
  String period_from_to(String start, String end, int days);

  /// Period with only start date
  ///
  /// In en, this message translates to:
  /// **'From {start} - Select end'**
  String period_from_select_end(String start);

  /// Period with only end date
  ///
  /// In en, this message translates to:
  /// **'To {end} - Select start'**
  String period_to_select_start(String end);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @currency_description.
  ///
  /// In en, this message translates to:
  /// **'Base currency for group'**
  String get currency_description;

  /// No description provided for @background_color_selected.
  ///
  /// In en, this message translates to:
  /// **'Color selected'**
  String get background_color_selected;

  /// No description provided for @background_tap_to_replace.
  ///
  /// In en, this message translates to:
  /// **'Tap to replace'**
  String get background_tap_to_replace;

  /// No description provided for @background_tap_to_change.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get background_tap_to_change;

  /// No description provided for @background_select_image_or_color.
  ///
  /// In en, this message translates to:
  /// **'Select image or color'**
  String get background_select_image_or_color;

  /// No description provided for @background_random_color.
  ///
  /// In en, this message translates to:
  /// **'Random color'**
  String get background_random_color;

  /// No description provided for @background_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove background'**
  String get background_remove;

  /// No description provided for @crop_image_title.
  ///
  /// In en, this message translates to:
  /// **'Crop image'**
  String get crop_image_title;

  /// No description provided for @crop_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get crop_confirm;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @processing_image.
  ///
  /// In en, this message translates to:
  /// **'Processing image...'**
  String get processing_image;

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

  /// Pluralized participant count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} participant} other {{count} participants}}'**
  String participant_count(num count);

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

  /// Label for recent expenses section
  ///
  /// In en, this message translates to:
  /// **'Recent expenses'**
  String get recent_expenses;

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
  /// **'Add a group'**
  String get add_trip;

  /// No description provided for @new_group.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get new_group;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

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

  /// No description provided for @expand_form.
  ///
  /// In en, this message translates to:
  /// **'Expand form'**
  String get expand_form;

  /// No description provided for @expand_form_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add date, location and notes'**
  String get expand_form_tooltip;

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
  /// **'Note'**
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

  /// No description provided for @other_settings.
  ///
  /// In en, this message translates to:
  /// **'Other settings'**
  String get other_settings;

  /// No description provided for @other_settings_desc.
  ///
  /// In en, this message translates to:
  /// **'Currency, background, and automatic location'**
  String get other_settings_desc;

  /// No description provided for @segment_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get segment_general;

  /// No description provided for @segment_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get segment_other;

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

  /// Action to mark a group as favorite
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get pin;

  /// Action to remove favorite mark from a group
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unpin;

  /// Action to delete a group
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Undo action label for SnackBar
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// Snackbar message when group is archived
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived_with_undo;

  /// Snackbar message when group is unarchived
  ///
  /// In en, this message translates to:
  /// **'Unarchived'**
  String get unarchived_with_undo;

  /// Snackbar message when group is marked as favorite
  ///
  /// In en, this message translates to:
  /// **'Marked as favorite'**
  String get pinned_with_undo;

  /// Snackbar message when favorite mark is removed from group
  ///
  /// In en, this message translates to:
  /// **'Favorite removed'**
  String get unpinned_with_undo;

  /// Snackbar message when group is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted_with_undo;

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

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @total_expenses.
  ///
  /// In en, this message translates to:
  /// **'Total expenses'**
  String get total_expenses;

  /// No description provided for @number_of_expenses.
  ///
  /// In en, this message translates to:
  /// **'Number of expenses'**
  String get number_of_expenses;

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

  /// No description provided for @edit_group_desc.
  ///
  /// In en, this message translates to:
  /// **'Modify group settings, participants, and categories'**
  String get edit_group_desc;

  /// No description provided for @new_group_desc.
  ///
  /// In en, this message translates to:
  /// **'Create a new expense group with custom settings'**
  String get new_group_desc;

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
  /// **'Mark as favorite'**
  String get pin_group;

  /// No description provided for @unpin_group.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
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

  /// Toast shown after deleting an expense group
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get group_deleted_success;

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

  /// No description provided for @ofx_select_directory_title.
  ///
  /// In en, this message translates to:
  /// **'Select folder to save OFX'**
  String get ofx_select_directory_title;

  /// No description provided for @ofx_saved_in.
  ///
  /// In en, this message translates to:
  /// **'OFX saved in: {path}'**
  String ofx_saved_in(Object path);

  /// No description provided for @ofx_save_cancelled.
  ///
  /// In en, this message translates to:
  /// **'OFX export cancelled'**
  String get ofx_save_cancelled;

  /// No description provided for @ofx_save_error.
  ///
  /// In en, this message translates to:
  /// **'Error saving OFX file'**
  String get ofx_save_error;

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
  /// **'Place'**
  String get location;

  /// No description provided for @location_hint.
  ///
  /// In en, this message translates to:
  /// **'Place'**
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

  /// No description provided for @resolving_address.
  ///
  /// In en, this message translates to:
  /// **'Resolving address…'**
  String get resolving_address;

  /// No description provided for @address_resolved.
  ///
  /// In en, this message translates to:
  /// **'Address resolved'**
  String get address_resolved;

  /// No description provided for @search_place.
  ///
  /// In en, this message translates to:
  /// **'Search place'**
  String get search_place;

  /// No description provided for @search_place_hint.
  ///
  /// In en, this message translates to:
  /// **'Search for a place or address'**
  String get search_place_hint;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_general_desc.
  ///
  /// In en, this message translates to:
  /// **'Language and appearance settings'**
  String get settings_general_desc;

  /// No description provided for @settings_auto_location_section.
  ///
  /// In en, this message translates to:
  /// **'Location Detection'**
  String get settings_auto_location_section;

  /// No description provided for @settings_auto_location_section_desc.
  ///
  /// In en, this message translates to:
  /// **'Configure automatic location detection'**
  String get settings_auto_location_section_desc;

  /// No description provided for @settings_auto_location_title.
  ///
  /// In en, this message translates to:
  /// **'Enable to detect'**
  String get settings_auto_location_title;

  /// No description provided for @settings_auto_location_desc.
  ///
  /// In en, this message translates to:
  /// **'Detect GPS when adding an expense'**
  String get settings_auto_location_desc;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_language_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settings_language_desc;

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

  /// No description provided for @settings_language_es.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settings_language_es;

  /// No description provided for @settings_language_pt.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get settings_language_pt;

  /// No description provided for @settings_language_zh.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get settings_language_zh;

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

  /// No description provided for @settings_theme_desc.
  ///
  /// In en, this message translates to:
  /// **'Light, dark or system'**
  String get settings_theme_desc;

  /// No description provided for @settings_select_theme.
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get settings_select_theme;

  /// No description provided for @settings_dynamic_color.
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get settings_dynamic_color;

  /// No description provided for @settings_dynamic_color_desc.
  ///
  /// In en, this message translates to:
  /// **'Use colors from your wallpaper'**
  String get settings_dynamic_color_desc;

  /// No description provided for @settings_privacy_desc.
  ///
  /// In en, this message translates to:
  /// **'Security and privacy options'**
  String get settings_privacy_desc;

  /// No description provided for @settings_data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settings_data;

  /// No description provided for @settings_data_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your information'**
  String get settings_data_desc;

  /// No description provided for @settings_data_manage.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get settings_data_manage;

  /// No description provided for @settings_info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get settings_info;

  /// No description provided for @settings_info_desc.
  ///
  /// In en, this message translates to:
  /// **'App details and support'**
  String get settings_info_desc;

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
  /// **'Website: calca'**
  String get terms_github_title;

  /// No description provided for @terms_github_desc.
  ///
  /// In en, this message translates to:
  /// **'Developer\'s personal website.'**
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

  /// No description provided for @support_developer_title.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get support_developer_title;

  /// No description provided for @support_developer_desc.
  ///
  /// In en, this message translates to:
  /// **'Support the development of this app.'**
  String get support_developer_desc;

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

  /// No description provided for @auto_backup_title.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get auto_backup_title;

  /// No description provided for @auto_backup_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable operating system automatic backup'**
  String get auto_backup_desc;

  /// No description provided for @settings_user_name_title.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settings_user_name_title;

  /// No description provided for @settings_user_name_desc.
  ///
  /// In en, this message translates to:
  /// **'Name or nickname to use in the app'**
  String get settings_user_name_desc;

  /// No description provided for @settings_user_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get settings_user_name_hint;

  /// No description provided for @default_participant_me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get default_participant_me;

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

  /// Shown when a filter (not search) returns no groups
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get no_results_found;

  /// Secondary helper text suggesting to change filters or search
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the filter or search.'**
  String get try_adjust_filter_or_search;

  /// Header for general statistics section
  ///
  /// In en, this message translates to:
  /// **'General statistics'**
  String get general_statistics;

  /// Empty state subtitle encouraging user to add first expense
  ///
  /// In en, this message translates to:
  /// **'Add the first expense to get started'**
  String get add_first_expense;

  /// Tooltip text when overview/statistics button is enabled
  ///
  /// In en, this message translates to:
  /// **'Overview and statistics'**
  String get overview_and_statistics;

  /// Label shown before the computed overall daily average spending value
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily_average;

  /// Label shown before the amount spent today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get spent_today;

  /// Label shown before the computed overall monthly average spending value
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly_average;

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

  /// Shown after an entity name when a duplicate entry is attempted
  ///
  /// In en, this message translates to:
  /// **'already exists'**
  String get already_exists;

  /// Filter label: all groups
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get status_all;

  /// Filter label: active groups
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// Filter label: archived groups
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get status_archived;

  /// Empty state title for archived groups
  ///
  /// In en, this message translates to:
  /// **'No archived groups'**
  String get no_archived_groups;

  /// Empty state subtitle for archived groups
  ///
  /// In en, this message translates to:
  /// **'You have not archived any groups yet'**
  String get no_archived_groups_subtitle;

  /// No description provided for @all_groups_archived_info.
  ///
  /// In en, this message translates to:
  /// **'All your groups are archived. You can restore them from the Archive section or create new ones.'**
  String get all_groups_archived_info;

  /// Tooltip for status filter buttons row
  ///
  /// In en, this message translates to:
  /// **'Filter groups'**
  String get filter_status_tooltip;

  /// Semantic label for the welcome screen logo
  ///
  /// In en, this message translates to:
  /// **'Caravella app logo'**
  String get welcome_logo_semantic;

  /// Create new group action label
  ///
  /// In en, this message translates to:
  /// **'Create new group'**
  String get create_new_group;

  /// Default accessibility label for add button
  ///
  /// In en, this message translates to:
  /// **'Add new item'**
  String get accessibility_add_new_item;

  /// Navigation bar accessibility label
  ///
  /// In en, this message translates to:
  /// **'Navigation bar'**
  String get accessibility_navigation_bar;

  /// Back button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get accessibility_back_button;

  /// Loading state accessibility label
  ///
  /// In en, this message translates to:
  /// **'Loading groups'**
  String get accessibility_loading_groups;

  /// Loading groups progress indicator label
  ///
  /// In en, this message translates to:
  /// **'Loading your groups'**
  String get accessibility_loading_your_groups;

  /// Groups list section accessibility label
  ///
  /// In en, this message translates to:
  /// **'Groups list'**
  String get accessibility_groups_list;

  /// Welcome screen accessibility label
  ///
  /// In en, this message translates to:
  /// **'Welcome screen'**
  String get accessibility_welcome_screen;

  /// Total expenses accessibility label
  ///
  /// In en, this message translates to:
  /// **'Total expenses: {amount}€'**
  String accessibility_total_expenses(Object amount);

  /// Add expense button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get accessibility_add_expense;

  /// Security switch accessibility label
  ///
  /// In en, this message translates to:
  /// **'Security switch - {state}'**
  String accessibility_security_switch(Object state);

  /// Switch on state label
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get accessibility_switch_on;

  /// Switch off state label
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get accessibility_switch_off;

  /// Image source selection dialog accessibility label
  ///
  /// In en, this message translates to:
  /// **'Image source selection dialog'**
  String get accessibility_image_source_dialog;

  /// Currently enabled state label
  ///
  /// In en, this message translates to:
  /// **'Currently enabled'**
  String get accessibility_currently_enabled;

  /// Currently disabled state label
  ///
  /// In en, this message translates to:
  /// **'Currently disabled'**
  String get accessibility_currently_disabled;

  /// Double tap to disable hint
  ///
  /// In en, this message translates to:
  /// **'Double tap to disable screen security'**
  String get accessibility_double_tap_disable;

  /// Double tap to enable hint
  ///
  /// In en, this message translates to:
  /// **'Double tap to enable screen security'**
  String get accessibility_double_tap_enable;

  /// Success toast type description
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get accessibility_toast_success;

  /// Error toast type description
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get accessibility_toast_error;

  /// Information toast type description
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get accessibility_toast_info;

  /// Title for the suggested colors section
  ///
  /// In en, this message translates to:
  /// **'Suggested colors'**
  String get color_suggested_title;

  /// Subtitle explaining the suggested colors section
  ///
  /// In en, this message translates to:
  /// **'Pick one of the theme compatible colors'**
  String get color_suggested_subtitle;

  /// Subtitle for the random color section
  ///
  /// In en, this message translates to:
  /// **'Let the app pick a color for you'**
  String get color_random_subtitle;

  /// No description provided for @currency_AED.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates Dirham'**
  String get currency_AED;

  /// No description provided for @currency_AFN.
  ///
  /// In en, this message translates to:
  /// **'Afghan Afghani'**
  String get currency_AFN;

  /// No description provided for @currency_ALL.
  ///
  /// In en, this message translates to:
  /// **'Albanian Lek'**
  String get currency_ALL;

  /// No description provided for @currency_AMD.
  ///
  /// In en, this message translates to:
  /// **'Armenian Dram'**
  String get currency_AMD;

  /// No description provided for @currency_ANG.
  ///
  /// In en, this message translates to:
  /// **'Netherlands Antillean Guilder'**
  String get currency_ANG;

  /// No description provided for @currency_AOA.
  ///
  /// In en, this message translates to:
  /// **'Angolan Kwanza'**
  String get currency_AOA;

  /// No description provided for @currency_ARS.
  ///
  /// In en, this message translates to:
  /// **'Argentine Peso'**
  String get currency_ARS;

  /// No description provided for @currency_AUD.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get currency_AUD;

  /// No description provided for @currency_AWG.
  ///
  /// In en, this message translates to:
  /// **'Aruban Florin'**
  String get currency_AWG;

  /// No description provided for @currency_AZN.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijani Manat'**
  String get currency_AZN;

  /// No description provided for @currency_BAM.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina Convertible Mark'**
  String get currency_BAM;

  /// No description provided for @currency_BBD.
  ///
  /// In en, this message translates to:
  /// **'Barbadian Dollar'**
  String get currency_BBD;

  /// No description provided for @currency_BDT.
  ///
  /// In en, this message translates to:
  /// **'Bangladeshi Taka'**
  String get currency_BDT;

  /// No description provided for @currency_BGN.
  ///
  /// In en, this message translates to:
  /// **'Bulgarian Lev'**
  String get currency_BGN;

  /// No description provided for @currency_BHD.
  ///
  /// In en, this message translates to:
  /// **'Bahraini Dinar'**
  String get currency_BHD;

  /// No description provided for @currency_BIF.
  ///
  /// In en, this message translates to:
  /// **'Burundian Franc'**
  String get currency_BIF;

  /// No description provided for @currency_BMD.
  ///
  /// In en, this message translates to:
  /// **'Bermudian Dollar'**
  String get currency_BMD;

  /// No description provided for @currency_BND.
  ///
  /// In en, this message translates to:
  /// **'Brunei Dollar'**
  String get currency_BND;

  /// No description provided for @currency_BOB.
  ///
  /// In en, this message translates to:
  /// **'Bolivian Boliviano'**
  String get currency_BOB;

  /// No description provided for @currency_BRL.
  ///
  /// In en, this message translates to:
  /// **'Brazilian Real'**
  String get currency_BRL;

  /// No description provided for @currency_BSD.
  ///
  /// In en, this message translates to:
  /// **'Bahamian Dollar'**
  String get currency_BSD;

  /// No description provided for @currency_BTN.
  ///
  /// In en, this message translates to:
  /// **'Bhutanese Ngultrum'**
  String get currency_BTN;

  /// No description provided for @currency_BWP.
  ///
  /// In en, this message translates to:
  /// **'Botswana Pula'**
  String get currency_BWP;

  /// No description provided for @currency_BYN.
  ///
  /// In en, this message translates to:
  /// **'Belarusian Ruble'**
  String get currency_BYN;

  /// No description provided for @currency_BZD.
  ///
  /// In en, this message translates to:
  /// **'Belize Dollar'**
  String get currency_BZD;

  /// No description provided for @currency_CAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get currency_CAD;

  /// No description provided for @currency_CDF.
  ///
  /// In en, this message translates to:
  /// **'Congolese Franc'**
  String get currency_CDF;

  /// No description provided for @currency_CHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss Franc'**
  String get currency_CHF;

  /// No description provided for @currency_CLP.
  ///
  /// In en, this message translates to:
  /// **'Chilean Peso'**
  String get currency_CLP;

  /// No description provided for @currency_CNY.
  ///
  /// In en, this message translates to:
  /// **'Chinese Yuan'**
  String get currency_CNY;

  /// No description provided for @currency_COP.
  ///
  /// In en, this message translates to:
  /// **'Colombian Peso'**
  String get currency_COP;

  /// No description provided for @currency_CRC.
  ///
  /// In en, this message translates to:
  /// **'Costa Rican Colón'**
  String get currency_CRC;

  /// No description provided for @currency_CUP.
  ///
  /// In en, this message translates to:
  /// **'Cuban Peso'**
  String get currency_CUP;

  /// No description provided for @currency_CVE.
  ///
  /// In en, this message translates to:
  /// **'Cape Verdean Escudo'**
  String get currency_CVE;

  /// No description provided for @currency_CZK.
  ///
  /// In en, this message translates to:
  /// **'Czech Koruna'**
  String get currency_CZK;

  /// No description provided for @currency_DJF.
  ///
  /// In en, this message translates to:
  /// **'Djiboutian Franc'**
  String get currency_DJF;

  /// No description provided for @currency_DKK.
  ///
  /// In en, this message translates to:
  /// **'Danish Krone'**
  String get currency_DKK;

  /// No description provided for @currency_DOP.
  ///
  /// In en, this message translates to:
  /// **'Dominican Peso'**
  String get currency_DOP;

  /// No description provided for @currency_DZD.
  ///
  /// In en, this message translates to:
  /// **'Algerian Dinar'**
  String get currency_DZD;

  /// No description provided for @currency_EGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get currency_EGP;

  /// No description provided for @currency_ERN.
  ///
  /// In en, this message translates to:
  /// **'Eritrean Nakfa'**
  String get currency_ERN;

  /// No description provided for @currency_ETB.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian Birr'**
  String get currency_ETB;

  /// No description provided for @currency_EUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currency_EUR;

  /// No description provided for @currency_FJD.
  ///
  /// In en, this message translates to:
  /// **'Fiji Dollar'**
  String get currency_FJD;

  /// No description provided for @currency_FKP.
  ///
  /// In en, this message translates to:
  /// **'Falkland Islands Pound'**
  String get currency_FKP;

  /// No description provided for @currency_GBP.
  ///
  /// In en, this message translates to:
  /// **'Pound Sterling'**
  String get currency_GBP;

  /// No description provided for @currency_GEL.
  ///
  /// In en, this message translates to:
  /// **'Georgian Lari'**
  String get currency_GEL;

  /// No description provided for @currency_GHS.
  ///
  /// In en, this message translates to:
  /// **'Ghanaian Cedi'**
  String get currency_GHS;

  /// No description provided for @currency_GIP.
  ///
  /// In en, this message translates to:
  /// **'Gibraltar Pound'**
  String get currency_GIP;

  /// No description provided for @currency_GMD.
  ///
  /// In en, this message translates to:
  /// **'Gambian Dalasi'**
  String get currency_GMD;

  /// No description provided for @currency_GNF.
  ///
  /// In en, this message translates to:
  /// **'Guinean Franc'**
  String get currency_GNF;

  /// No description provided for @currency_GTQ.
  ///
  /// In en, this message translates to:
  /// **'Guatemalan Quetzal'**
  String get currency_GTQ;

  /// No description provided for @currency_GYD.
  ///
  /// In en, this message translates to:
  /// **'Guyanese Dollar'**
  String get currency_GYD;

  /// No description provided for @currency_HKD.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong Dollar'**
  String get currency_HKD;

  /// No description provided for @currency_HNL.
  ///
  /// In en, this message translates to:
  /// **'Honduran Lempira'**
  String get currency_HNL;

  /// No description provided for @currency_HTG.
  ///
  /// In en, this message translates to:
  /// **'Haitian Gourde'**
  String get currency_HTG;

  /// No description provided for @currency_HUF.
  ///
  /// In en, this message translates to:
  /// **'Hungarian Forint'**
  String get currency_HUF;

  /// No description provided for @currency_IDR.
  ///
  /// In en, this message translates to:
  /// **'Indonesian Rupiah'**
  String get currency_IDR;

  /// No description provided for @currency_ILS.
  ///
  /// In en, this message translates to:
  /// **'Israeli New Shekel'**
  String get currency_ILS;

  /// No description provided for @currency_INR.
  ///
  /// In en, this message translates to:
  /// **'Indian Rupee'**
  String get currency_INR;

  /// No description provided for @currency_IQD.
  ///
  /// In en, this message translates to:
  /// **'Iraqi Dinar'**
  String get currency_IQD;

  /// No description provided for @currency_IRR.
  ///
  /// In en, this message translates to:
  /// **'Iranian Rial'**
  String get currency_IRR;

  /// No description provided for @currency_ISK.
  ///
  /// In en, this message translates to:
  /// **'Icelandic Króna'**
  String get currency_ISK;

  /// No description provided for @currency_JMD.
  ///
  /// In en, this message translates to:
  /// **'Jamaican Dollar'**
  String get currency_JMD;

  /// No description provided for @currency_JOD.
  ///
  /// In en, this message translates to:
  /// **'Jordanian Dinar'**
  String get currency_JOD;

  /// No description provided for @currency_JPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get currency_JPY;

  /// No description provided for @currency_KES.
  ///
  /// In en, this message translates to:
  /// **'Kenyan Shilling'**
  String get currency_KES;

  /// No description provided for @currency_KGS.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyzstani Som'**
  String get currency_KGS;

  /// No description provided for @currency_KHR.
  ///
  /// In en, this message translates to:
  /// **'Cambodian Riel'**
  String get currency_KHR;

  /// No description provided for @currency_KID.
  ///
  /// In en, this message translates to:
  /// **'Kiribati Dollar'**
  String get currency_KID;

  /// No description provided for @currency_KMF.
  ///
  /// In en, this message translates to:
  /// **'Comorian Franc'**
  String get currency_KMF;

  /// No description provided for @currency_KPW.
  ///
  /// In en, this message translates to:
  /// **'North Korean Won'**
  String get currency_KPW;

  /// No description provided for @currency_KRW.
  ///
  /// In en, this message translates to:
  /// **'South Korean Won'**
  String get currency_KRW;

  /// No description provided for @currency_KWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get currency_KWD;

  /// No description provided for @currency_KYD.
  ///
  /// In en, this message translates to:
  /// **'Cayman Islands Dollar'**
  String get currency_KYD;

  /// No description provided for @currency_KZT.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstani Tenge'**
  String get currency_KZT;

  /// No description provided for @currency_LAK.
  ///
  /// In en, this message translates to:
  /// **'Lao Kip'**
  String get currency_LAK;

  /// No description provided for @currency_LBP.
  ///
  /// In en, this message translates to:
  /// **'Lebanese Pound'**
  String get currency_LBP;

  /// No description provided for @currency_LKR.
  ///
  /// In en, this message translates to:
  /// **'Sri Lankan Rupee'**
  String get currency_LKR;

  /// No description provided for @currency_LRD.
  ///
  /// In en, this message translates to:
  /// **'Liberian Dollar'**
  String get currency_LRD;

  /// No description provided for @currency_LSL.
  ///
  /// In en, this message translates to:
  /// **'Lesotho Loti'**
  String get currency_LSL;

  /// No description provided for @currency_LYD.
  ///
  /// In en, this message translates to:
  /// **'Libyan Dinar'**
  String get currency_LYD;

  /// No description provided for @currency_MAD.
  ///
  /// In en, this message translates to:
  /// **'Moroccan Dirham'**
  String get currency_MAD;

  /// No description provided for @currency_MDL.
  ///
  /// In en, this message translates to:
  /// **'Moldovan Leu'**
  String get currency_MDL;

  /// No description provided for @currency_MGA.
  ///
  /// In en, this message translates to:
  /// **'Malagasy Ariary'**
  String get currency_MGA;

  /// No description provided for @currency_MKD.
  ///
  /// In en, this message translates to:
  /// **'Macedonian Denar'**
  String get currency_MKD;

  /// No description provided for @currency_MMK.
  ///
  /// In en, this message translates to:
  /// **'Myanmar Kyat'**
  String get currency_MMK;

  /// No description provided for @currency_MNT.
  ///
  /// In en, this message translates to:
  /// **'Mongolian Tögrög'**
  String get currency_MNT;

  /// No description provided for @currency_MOP.
  ///
  /// In en, this message translates to:
  /// **'Macanese Pataca'**
  String get currency_MOP;

  /// No description provided for @currency_MRU.
  ///
  /// In en, this message translates to:
  /// **'Mauritanian Ouguiya'**
  String get currency_MRU;

  /// No description provided for @currency_MUR.
  ///
  /// In en, this message translates to:
  /// **'Mauritian Rupee'**
  String get currency_MUR;

  /// No description provided for @currency_MVR.
  ///
  /// In en, this message translates to:
  /// **'Maldivian Rufiyaa'**
  String get currency_MVR;

  /// No description provided for @currency_MWK.
  ///
  /// In en, this message translates to:
  /// **'Malawian Kwacha'**
  String get currency_MWK;

  /// No description provided for @currency_MXN.
  ///
  /// In en, this message translates to:
  /// **'Mexican Peso'**
  String get currency_MXN;

  /// No description provided for @currency_MYR.
  ///
  /// In en, this message translates to:
  /// **'Malaysian Ringgit'**
  String get currency_MYR;

  /// No description provided for @currency_MZN.
  ///
  /// In en, this message translates to:
  /// **'Mozambican Metical'**
  String get currency_MZN;

  /// No description provided for @currency_NAD.
  ///
  /// In en, this message translates to:
  /// **'Namibian Dollar'**
  String get currency_NAD;

  /// No description provided for @currency_NGN.
  ///
  /// In en, this message translates to:
  /// **'Nigerian Naira'**
  String get currency_NGN;

  /// No description provided for @currency_NIO.
  ///
  /// In en, this message translates to:
  /// **'Nicaraguan Córdoba'**
  String get currency_NIO;

  /// No description provided for @currency_NOK.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Krone'**
  String get currency_NOK;

  /// No description provided for @currency_NPR.
  ///
  /// In en, this message translates to:
  /// **'Nepalese Rupee'**
  String get currency_NPR;

  /// No description provided for @currency_NZD.
  ///
  /// In en, this message translates to:
  /// **'New Zealand Dollar'**
  String get currency_NZD;

  /// No description provided for @currency_OMR.
  ///
  /// In en, this message translates to:
  /// **'Omani Rial'**
  String get currency_OMR;

  /// No description provided for @currency_PAB.
  ///
  /// In en, this message translates to:
  /// **'Panamanian Balboa'**
  String get currency_PAB;

  /// No description provided for @currency_PEN.
  ///
  /// In en, this message translates to:
  /// **'Peruvian Sol'**
  String get currency_PEN;

  /// No description provided for @currency_PGK.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinean Kina'**
  String get currency_PGK;

  /// No description provided for @currency_PHP.
  ///
  /// In en, this message translates to:
  /// **'Philippine Peso'**
  String get currency_PHP;

  /// No description provided for @currency_PKR.
  ///
  /// In en, this message translates to:
  /// **'Pakistani Rupee'**
  String get currency_PKR;

  /// No description provided for @currency_PLN.
  ///
  /// In en, this message translates to:
  /// **'Polish Zloty'**
  String get currency_PLN;

  /// No description provided for @currency_PYG.
  ///
  /// In en, this message translates to:
  /// **'Paraguayan Guaraní'**
  String get currency_PYG;

  /// No description provided for @currency_QAR.
  ///
  /// In en, this message translates to:
  /// **'Qatari Riyal'**
  String get currency_QAR;

  /// No description provided for @currency_RON.
  ///
  /// In en, this message translates to:
  /// **'Romanian Leu'**
  String get currency_RON;

  /// No description provided for @currency_RSD.
  ///
  /// In en, this message translates to:
  /// **'Serbian Dinar'**
  String get currency_RSD;

  /// No description provided for @currency_RUB.
  ///
  /// In en, this message translates to:
  /// **'Russian Ruble'**
  String get currency_RUB;

  /// No description provided for @currency_RWF.
  ///
  /// In en, this message translates to:
  /// **'Rwandan Franc'**
  String get currency_RWF;

  /// No description provided for @currency_SAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get currency_SAR;

  /// No description provided for @currency_SBD.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islands Dollar'**
  String get currency_SBD;

  /// No description provided for @currency_SCR.
  ///
  /// In en, this message translates to:
  /// **'Seychellois Rupee'**
  String get currency_SCR;

  /// No description provided for @currency_SDG.
  ///
  /// In en, this message translates to:
  /// **'Sudanese Pound'**
  String get currency_SDG;

  /// No description provided for @currency_SEK.
  ///
  /// In en, this message translates to:
  /// **'Swedish Krona'**
  String get currency_SEK;

  /// No description provided for @currency_SGD.
  ///
  /// In en, this message translates to:
  /// **'Singapore Dollar'**
  String get currency_SGD;

  /// No description provided for @currency_SHP.
  ///
  /// In en, this message translates to:
  /// **'Saint Helena Pound'**
  String get currency_SHP;

  /// No description provided for @currency_SLE.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leonean Leone (new)'**
  String get currency_SLE;

  /// No description provided for @currency_SLL.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leonean Leone (old)'**
  String get currency_SLL;

  /// No description provided for @currency_SOS.
  ///
  /// In en, this message translates to:
  /// **'Somali Shilling'**
  String get currency_SOS;

  /// No description provided for @currency_SRD.
  ///
  /// In en, this message translates to:
  /// **'Surinamese Dollar'**
  String get currency_SRD;

  /// No description provided for @currency_SSP.
  ///
  /// In en, this message translates to:
  /// **'South Sudanese Pound'**
  String get currency_SSP;

  /// No description provided for @currency_STN.
  ///
  /// In en, this message translates to:
  /// **'São Tomé and Príncipe Dobra'**
  String get currency_STN;

  /// No description provided for @currency_SVC.
  ///
  /// In en, this message translates to:
  /// **'Salvadoran Colón (historic)'**
  String get currency_SVC;

  /// No description provided for @currency_SYP.
  ///
  /// In en, this message translates to:
  /// **'Syrian Pound'**
  String get currency_SYP;

  /// No description provided for @currency_SZL.
  ///
  /// In en, this message translates to:
  /// **'Eswatini Lilangeni'**
  String get currency_SZL;

  /// No description provided for @currency_THB.
  ///
  /// In en, this message translates to:
  /// **'Thai Baht'**
  String get currency_THB;

  /// No description provided for @currency_TJS.
  ///
  /// In en, this message translates to:
  /// **'Tajikistani Somoni'**
  String get currency_TJS;

  /// No description provided for @currency_TMT.
  ///
  /// In en, this message translates to:
  /// **'Turkmenistan Manat'**
  String get currency_TMT;

  /// No description provided for @currency_TND.
  ///
  /// In en, this message translates to:
  /// **'Tunisian Dinar'**
  String get currency_TND;

  /// No description provided for @currency_TOP.
  ///
  /// In en, this message translates to:
  /// **'Tongan Paʻanga'**
  String get currency_TOP;

  /// No description provided for @currency_TRY.
  ///
  /// In en, this message translates to:
  /// **'Turkish Lira'**
  String get currency_TRY;

  /// No description provided for @currency_TTD.
  ///
  /// In en, this message translates to:
  /// **'Trinidad and Tobago Dollar'**
  String get currency_TTD;

  /// No description provided for @currency_TVD.
  ///
  /// In en, this message translates to:
  /// **'Tuvaluan Dollar'**
  String get currency_TVD;

  /// No description provided for @currency_TWD.
  ///
  /// In en, this message translates to:
  /// **'New Taiwan Dollar'**
  String get currency_TWD;

  /// No description provided for @currency_TZS.
  ///
  /// In en, this message translates to:
  /// **'Tanzanian Shilling'**
  String get currency_TZS;

  /// No description provided for @currency_UAH.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian Hryvnia'**
  String get currency_UAH;

  /// No description provided for @currency_UGX.
  ///
  /// In en, this message translates to:
  /// **'Ugandan Shilling'**
  String get currency_UGX;

  /// No description provided for @currency_USD.
  ///
  /// In en, this message translates to:
  /// **'United States Dollar'**
  String get currency_USD;

  /// No description provided for @currency_UYU.
  ///
  /// In en, this message translates to:
  /// **'Uruguayan Peso'**
  String get currency_UYU;

  /// No description provided for @currency_UZS.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistani So\'m'**
  String get currency_UZS;

  /// No description provided for @currency_VED.
  ///
  /// In en, this message translates to:
  /// **'Venezuelan Digital Bolívar'**
  String get currency_VED;

  /// No description provided for @currency_VES.
  ///
  /// In en, this message translates to:
  /// **'Venezuelan Bolívar'**
  String get currency_VES;

  /// No description provided for @currency_VND.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Đồng'**
  String get currency_VND;

  /// No description provided for @currency_VUV.
  ///
  /// In en, this message translates to:
  /// **'Vanuatu Vatu'**
  String get currency_VUV;

  /// No description provided for @currency_WST.
  ///
  /// In en, this message translates to:
  /// **'Samoan Tala'**
  String get currency_WST;

  /// No description provided for @currency_XAF.
  ///
  /// In en, this message translates to:
  /// **'CFA Franc BEAC'**
  String get currency_XAF;

  /// No description provided for @currency_XOF.
  ///
  /// In en, this message translates to:
  /// **'CFA Franc BCEAO'**
  String get currency_XOF;

  /// No description provided for @currency_XPF.
  ///
  /// In en, this message translates to:
  /// **'CFP Franc'**
  String get currency_XPF;

  /// No description provided for @currency_YER.
  ///
  /// In en, this message translates to:
  /// **'Yemeni Rial'**
  String get currency_YER;

  /// No description provided for @currency_ZAR.
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currency_ZAR;

  /// No description provided for @currency_ZMW.
  ///
  /// In en, this message translates to:
  /// **'Zambian Kwacha'**
  String get currency_ZMW;

  /// No description provided for @currency_ZWL.
  ///
  /// In en, this message translates to:
  /// **'Zimbabwean Dollar'**
  String get currency_ZWL;

  /// No description provided for @search_currency.
  ///
  /// In en, this message translates to:
  /// **'Search currency...'**
  String get search_currency;

  /// Section title for expense list
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get activity;

  /// Placeholder for searching expenses by name or note
  ///
  /// In en, this message translates to:
  /// **'Search by name or note...'**
  String get search_expenses_hint;

  /// Button to clear expense filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_filters;

  /// Label to show filters
  ///
  /// In en, this message translates to:
  /// **'Show filters'**
  String get show_filters;

  /// Label to hide filters
  ///
  /// In en, this message translates to:
  /// **'Hide filters'**
  String get hide_filters;

  /// Chip label for all categories
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_categories;

  /// Chip label for all participants
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_participants;

  /// Empty state when active filters return no expenses
  ///
  /// In en, this message translates to:
  /// **'No expenses match the selected filters'**
  String get no_expenses_with_filters;

  /// Empty state when there are no expenses yet
  ///
  /// In en, this message translates to:
  /// **'No expenses added yet'**
  String get no_expenses_yet;

  /// Title for empty expenses state
  ///
  /// In en, this message translates to:
  /// **'Ready to start tracking?'**
  String get empty_expenses_title;

  /// Subtitle for empty expenses state
  ///
  /// In en, this message translates to:
  /// **'Add your first expense to get started with this group!'**
  String get empty_expenses_subtitle;

  /// Button text for adding the first expense in empty state
  ///
  /// In en, this message translates to:
  /// **'Add First Expense'**
  String get add_first_expense_button;

  /// Tooltip to show the group search bar
  ///
  /// In en, this message translates to:
  /// **'Show search bar'**
  String get show_search;

  /// Tooltip to hide the group search bar
  ///
  /// In en, this message translates to:
  /// **'Hide search bar'**
  String get hide_search;

  /// Main section header for the list of expense groups/trips on the history page
  ///
  /// In en, this message translates to:
  /// **'Expense Groups'**
  String get expense_groups_title;

  /// Short subtitle describing the purpose of the expense groups section (e.g. add, edit, view trips)
  ///
  /// In en, this message translates to:
  /// **'Manage your expense groups'**
  String get expense_groups_desc;

  /// Title of the page showing the changelog
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get whats_new_title;

  /// Subtitle of the what's new page
  ///
  /// In en, this message translates to:
  /// **'Discover the latest features and updates'**
  String get whats_new_desc;

  /// Card headline describing the what's new section
  ///
  /// In en, this message translates to:
  /// **'Latest highlights'**
  String get whats_new_subtitle;

  /// Support text explaining that the content lists the most recent updates
  ///
  /// In en, this message translates to:
  /// **'Stay up to date with recent improvements'**
  String get whats_new_latest;

  /// Title for the changelog section
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog_title;

  /// Description for the changelog section
  ///
  /// In en, this message translates to:
  /// **'Version history and improvements'**
  String get changelog_desc;

  /// Label shown before the computed average spent per person in the Participants tab
  ///
  /// In en, this message translates to:
  /// **'Average per person'**
  String get average_per_person;

  /// Inline toggle label to expand and show all items
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// Inline toggle label to collapse and show fewer items
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get less;

  /// Short prefix shown before the recipient in a debt/settlement line (e.g., 'to Alice 10€')
  ///
  /// In en, this message translates to:
  /// **'to '**
  String get debt_prefix_to;

  /// Tooltip for the map button to view expenses on a map
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get view_on_map;

  /// Title of the page showing expenses on a map
  ///
  /// In en, this message translates to:
  /// **'Expenses Map'**
  String get expenses_map;

  /// Message shown when no expenses have location data
  ///
  /// In en, this message translates to:
  /// **'No locations available'**
  String get no_locations_available;

  /// Subtitle explaining how to add locations
  ///
  /// In en, this message translates to:
  /// **'Add location data to your expenses to see them on the map'**
  String get no_locations_subtitle;

  /// Label showing number of expenses at a location
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 expense} other{{count} expenses}}'**
  String expense_count(int count);

  /// Label to check for updates from Google Play Store
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get check_for_updates;

  /// Description for update check
  ///
  /// In en, this message translates to:
  /// **'Check for new version availability'**
  String get check_for_updates_desc;

  /// Title when an update is available
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get update_available;

  /// Description when an update is available
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available'**
  String get update_available_desc;

  /// Message when there are no updates
  ///
  /// In en, this message translates to:
  /// **'App up to date'**
  String get no_update_available;

  /// Description when there are no updates
  ///
  /// In en, this message translates to:
  /// **'You\'re using the latest version'**
  String get no_update_available_desc;

  /// Button to start the update
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get update_now;

  /// Button to postpone the update
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get update_later;

  /// Message while checking for updates
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get checking_for_updates;

  /// Error message during update check
  ///
  /// In en, this message translates to:
  /// **'Update check error'**
  String get update_error;

  /// Message while downloading update
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get update_downloading;

  /// Message while installing update
  ///
  /// In en, this message translates to:
  /// **'Installing...'**
  String get update_installing;

  /// Message explaining the feature is Android-only
  ///
  /// In en, this message translates to:
  /// **'Feature only available on Android with Google Play Store'**
  String get update_feature_android_only;

  /// Title of bottom sheet to recommend update
  ///
  /// In en, this message translates to:
  /// **'Update recommended'**
  String get update_recommendation_title;

  /// Description in bottom sheet recommending to update
  ///
  /// In en, this message translates to:
  /// **'A new version of Caravella is available. Update the app to always have the latest features and improvements!'**
  String get update_recommendation_desc;

  /// Button to install update from bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Install update'**
  String get update_install;

  /// Button to postpone update from bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get update_remind_later;

  /// Button label to send a payment reminder to a participant
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get send_reminder;

  /// Reminder message when a participant owes money to a single person
  ///
  /// In en, this message translates to:
  /// **'Hi {participantName}! 👋\n\nJust a friendly reminder that you owe {amount} to {creditorName} for the group \"{groupName}\".\n\nThank you! 😊'**
  String reminder_message_single(
    Object participantName,
    Object amount,
    Object creditorName,
    Object groupName,
  );

  /// Reminder message when a participant owes money to multiple people
  ///
  /// In en, this message translates to:
  /// **'Hi {participantName}! 👋\n\nJust a friendly reminder of your payments for the group \"{groupName}\":\n\n{debtsList}\n\nThank you! 😊'**
  String reminder_message_multiple(
    Object participantName,
    Object groupName,
    Object debtsList,
  );

  /// Label for persistent notification toggle
  ///
  /// In en, this message translates to:
  /// **'Persistent notification'**
  String get notification_enabled;

  /// Description of the persistent notification setting
  ///
  /// In en, this message translates to:
  /// **'Display today\'s expenses in an always-visible notification'**
  String get notification_enabled_desc;

  /// Today's spent amount in notification
  ///
  /// In en, this message translates to:
  /// **'Today\'s expenses: {amount} {currency}'**
  String notification_daily_spent(String amount, String currency);

  /// Total spent amount in notification
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} {currency}'**
  String notification_total_spent(String amount, String currency);

  /// Action button in notification to add expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get notification_add_expense;

  /// Action button in notification to close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get notification_close;

  /// Label for expense group type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get group_type;

  /// Description for group type selection
  ///
  /// In en, this message translates to:
  /// **'Choose the group type'**
  String get group_type_description;

  /// Group type: travel
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get group_type_travel;

  /// Group type: personal
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get group_type_personal;

  /// Group type: family
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get group_type_family;

  /// Group type: other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get group_type_other;

  /// Default category for travel group type
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get category_travel_transport;

  /// Default category for travel group type
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get category_travel_accommodation;

  /// Default category for travel group type
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get category_travel_restaurants;

  /// Default category for personal group type
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_personal_shopping;

  /// Default category for personal group type
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get category_personal_health;

  /// Default category for personal group type
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get category_personal_entertainment;

  /// Default category for family group type
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get category_family_groceries;

  /// Default category for family group type
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get category_family_home;

  /// Default category for family group type
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get category_family_bills;

  /// Default category for other group type
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get category_other_misc;

  /// Default category for other group type
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get category_other_utilities;

  /// Default category for other group type
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get category_other_services;

  /// Label for expense attachments
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// Button to add an attachment
  ///
  /// In en, this message translates to:
  /// **'Add attachment'**
  String get add_attachment;

  /// Error message when trying to add more than 5 attachments
  ///
  /// In en, this message translates to:
  /// **'Maximum limit of 5 attachments reached'**
  String get attachment_limit_reached;

  /// Action to delete an attachment
  ///
  /// In en, this message translates to:
  /// **'Delete attachment'**
  String get delete_attachment;

  /// Action to share an attachment
  ///
  /// In en, this message translates to:
  /// **'Share attachment'**
  String get share_attachment;

  /// Delete attachment confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete attachment'**
  String get delete_attachment_confirm_title;

  /// Delete attachment confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this attachment?'**
  String get delete_attachment_confirm_message;

  /// Title for choosing attachment source
  ///
  /// In en, this message translates to:
  /// **'Choose source'**
  String get attachment_source;

  /// Option to choose from files
  ///
  /// In en, this message translates to:
  /// **'From files'**
  String get from_files;

  /// Message indicating that an archived group is in read-only mode
  ///
  /// In en, this message translates to:
  /// **'Archived Group - Read-only'**
  String get archived_group_readonly;

  /// Description for archived group in read-only mode
  ///
  /// In en, this message translates to:
  /// **'This group is archived. You cannot modify it or add new expenses.'**
  String get archived_group_readonly_desc;

  /// Title for an expense in read-only mode
  ///
  /// In en, this message translates to:
  /// **'Expense - Read-only'**
  String get expense_readonly;

  /// Message explaining that an expense cannot be modified because the group is archived
  ///
  /// In en, this message translates to:
  /// **'This expense belongs to an archived group and cannot be modified.'**
  String get expense_readonly_archived;

  /// Generic title for an expense
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Action button in notification to disable notifications
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get notification_disable;

  /// Button to load more expenses in paginated list
  ///
  /// In en, this message translates to:
  /// **'Load more expenses'**
  String get load_more_expenses;

  /// Title of group creation wizard
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get wizard_group_creation_title;

  /// Title of wizard step 1: group name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wizard_step_name;

  /// Title of wizard step: type and group name
  ///
  /// In en, this message translates to:
  /// **'Type and Name'**
  String get wizard_step_type_and_name;

  /// Description of type and name step in wizard
  ///
  /// In en, this message translates to:
  /// **'What\'s this group for?'**
  String get wizard_type_and_name_description;

  /// Title of wizard step 2: participants
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get wizard_step_participants;

  /// Title of wizard step 3: categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get wizard_step_categories;

  /// Title of wizard step 4: period
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get wizard_step_period;

  /// Title of wizard step 5: background color
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get wizard_step_background;

  /// Title of final wizard step: congratulations
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get wizard_step_congratulations;

  /// Separator for progress indicator (e.g. 'Step 1 of 6')
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get wizard_step_of;

  /// Text of button to go to next step
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wizard_next;

  /// Text of button to go back to previous step
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get wizard_previous;

  /// Text of button to skip an optional step
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get wizard_skip;

  /// Text of final button to create the group
  ///
  /// In en, this message translates to:
  /// **'Create Group'**
  String get wizard_finish;

  /// Description of the name step in the wizard
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get wizard_name_description;

  /// Description of the participants step in the wizard
  ///
  /// In en, this message translates to:
  /// **'Add people who will share expenses'**
  String get wizard_participants_description;

  /// Description of the categories step in the wizard
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize expenses'**
  String get wizard_categories_description;

  /// Description of the period step in the wizard
  ///
  /// In en, this message translates to:
  /// **'Set start and end dates (optional)'**
  String get wizard_period_description;

  /// Description of the background step in the wizard
  ///
  /// In en, this message translates to:
  /// **'Choose a background color for the group'**
  String get wizard_background_description;

  /// Congratulations message with group name
  ///
  /// In en, this message translates to:
  /// **'Your group \'{groupName}\' has been created successfully!'**
  String wizard_congratulations_message(String groupName);

  /// Title of the summary in the final screen
  ///
  /// In en, this message translates to:
  /// **'Group summary:'**
  String get wizard_group_summary;

  /// Number of participants in the summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant} other{{count} participants}}'**
  String wizard_created_participants(int count);

  /// Number of categories in the summary
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 category} other{{count} categories}}'**
  String wizard_created_categories(int count);

  /// Title of initial wizard step: user name
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get wizard_step_user_name;

  /// Welcome message in user name step
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get wizard_user_name_welcome;

  /// Description of user name step
  ///
  /// In en, this message translates to:
  /// **'Before we start, tell us your name so we can personalize your experience'**
  String get wizard_user_name_description;

  /// Privacy note for user name
  ///
  /// In en, this message translates to:
  /// **'Your data stays private on your device'**
  String get wizard_user_name_local_storage_note;

  /// Label for user name field
  ///
  /// In en, this message translates to:
  /// **'Your name (optional)'**
  String get wizard_user_name_label;

  /// Hint for user name field
  ///
  /// In en, this message translates to:
  /// **'e.g. Alex'**
  String get wizard_user_name_hint;

  /// Title of combined participants and categories step
  ///
  /// In en, this message translates to:
  /// **'Who and what'**
  String get wizard_step_participants_and_categories;

  /// Description of combined participants and categories step
  ///
  /// In en, this message translates to:
  /// **'Define who participates and what expenses will be shared'**
  String get wizard_participants_and_categories_description;

  /// Title of participants section in combined step
  ///
  /// In en, this message translates to:
  /// **'Who\'s participating?'**
  String get wizard_participants_section_title;

  /// Hint for participants section
  ///
  /// In en, this message translates to:
  /// **'Add friends or roommates. You can modify them later.'**
  String get wizard_participants_section_hint;

  /// Title of categories section in combined step
  ///
  /// In en, this message translates to:
  /// **'What will be shared?'**
  String get wizard_categories_section_title;

  /// Hint for categories section
  ///
  /// In en, this message translates to:
  /// **'E.g. Food, Accommodation, Transportation. You can add or rename later.'**
  String get wizard_categories_section_hint;

  /// Title of final color and confirm step
  ///
  /// In en, this message translates to:
  /// **'Color and confirm'**
  String get wizard_step_color_and_final;

  /// Description of final step
  ///
  /// In en, this message translates to:
  /// **'Choose a color for the group and review the summary'**
  String get wizard_color_and_final_description;

  /// Title of preview section
  ///
  /// In en, this message translates to:
  /// **'Group preview'**
  String get wizard_preview_title;

  /// Title of success dialog
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get wizard_success_title;

  /// Button to go to created group
  ///
  /// In en, this message translates to:
  /// **'Go to group'**
  String get wizard_go_to_group;

  /// Button to go back to home page
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get wizard_go_to_home;

  /// Button to go to group settings
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get wizard_go_to_settings;

  /// Title of next actions section
  ///
  /// In en, this message translates to:
  /// **'What you can do now:'**
  String get wizard_completion_what_next;

  /// Title of add expenses option
  ///
  /// In en, this message translates to:
  /// **'Add expenses'**
  String get wizard_completion_add_expenses;

  /// Description of add expenses option
  ///
  /// In en, this message translates to:
  /// **'Start tracking group expenses'**
  String get wizard_completion_add_expenses_description;

  /// Title of customize group option
  ///
  /// In en, this message translates to:
  /// **'Customize group'**
  String get wizard_completion_customize_group;

  /// Description of customize group option
  ///
  /// In en, this message translates to:
  /// **'Edit participants, categories, and settings'**
  String get wizard_completion_customize_group_description;

  /// Section title for dangerous actions like archive and delete
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get danger_zone;

  /// Description for danger zone section
  ///
  /// In en, this message translates to:
  /// **'Archive or delete this group'**
  String get danger_zone_desc;

  /// Description for export options
  ///
  /// In en, this message translates to:
  /// **'Download or share expenses in various formats'**
  String get export_options_desc;

  /// Short description for CSV export format
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet format'**
  String get export_csv_description;

  /// Short description for OFX export format
  ///
  /// In en, this message translates to:
  /// **'Banking format'**
  String get export_ofx_description;

  /// Short description for Markdown export format
  ///
  /// In en, this message translates to:
  /// **'Document format'**
  String get export_markdown_description;

  /// Label for save action button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save_label;
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
      <String>['en', 'es', 'it', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
