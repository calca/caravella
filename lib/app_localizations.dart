import 'package:flutter/widgets.dart';
// Generated localization file (project path via l10n.yaml synthetic-package: false)
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

// Bridge per mantenere compatibile l'attuale API loc.get('key')
// usando le classi generate automaticamente.
class AppLocalizations {
  final gen.AppLocalizations _delegate;

  // Private named constructor
  AppLocalizations._(this._delegate);

  // Backward-compatible factory: accepts either a generated delegate instance or a locale code string.
  factory AppLocalizations(dynamic source) {
    if (source is gen.AppLocalizations) return AppLocalizations._(source);
    if (source is String) {
      // Normalize locales like 'en_US' -> 'en'
      final code = source.split('_').first;
      return AppLocalizations._(gen.lookupAppLocalizations(Locale(code)));
    }
    throw ArgumentError(
      'Unsupported AppLocalizations source type: ${source.runtimeType}',
    );
  }

  static AppLocalizations of(BuildContext context) =>
      AppLocalizations(gen.AppLocalizations.of(context));

  String get locale => _delegate.localeName;

  late final Map<String, String> _keyMap = _buildMap();

  Map<String, String> _buildMap() {
    final m = <String, String>{};
    // Map simple (non-parameterized) keys directly to generated snake_case getters.
    void add(String k, String v) => m[k] = v;
    add('settings_flag_secure_desc', _delegate.settings_flag_secure_desc);
    add('settings_flag_secure_title', _delegate.settings_flag_secure_title);
    add('select_currency', _delegate.select_currency);
    add('select_period_hint_short', _delegate.select_period_hint_short);
    add('select_period_hint', _delegate.select_period_hint);
    add('save_change_expense', _delegate.save_change_expense);
    add('group_total', _delegate.group_total);
    add('download_all_csv', _delegate.download_all_csv);
    add('share_all_csv', _delegate.share_all_csv);
    add('welcome_v3_title', _delegate.welcome_v3_title);
    add('good_morning', _delegate.good_morning);
    add('good_afternoon', _delegate.good_afternoon);
    add('good_evening', _delegate.good_evening);
    add('your_groups', _delegate.your_groups);
    add('no_active_groups', _delegate.no_active_groups);
    add('no_active_groups_subtitle', _delegate.no_active_groups_subtitle);
    add('create_first_group', _delegate.create_first_group);
    add('new_expense_group', _delegate.new_expense_group);
    add('tap_to_create', _delegate.tap_to_create);
    add('no_expense_label', _delegate.no_expense_label);
    add('image', _delegate.image);
    add('select_image', _delegate.select_image);
    add('change_image', _delegate.change_image);
    add('from_gallery', _delegate.from_gallery);
    add('from_camera', _delegate.from_camera);
    add('remove_image', _delegate.remove_image);
    add('no_trips_found', _delegate.no_trips_found);
    add('expenses', _delegate.expenses);
    add('participants', _delegate.participants);
    add('participants_label', _delegate.participants_label);
    add('last_7_days', _delegate.last_7_days);
    add('recent_activity', _delegate.recent_activity);
    add('about', _delegate.about);
    add('license_hint', _delegate.license_hint);
    add('license_link', _delegate.license_link);
    add('license_section', _delegate.license_section);
    add('add_trip', _delegate.add_trip);
    add('new_group', _delegate.new_group);
    add('group_name', _delegate.group_name);
    add('enter_title', _delegate.enter_title);
    add('enter_participant', _delegate.enter_participant);
    add('select_start', _delegate.select_start);
    add('select_end', _delegate.select_end);
    add('start_date_not_selected', _delegate.start_date_not_selected);
    add('end_date_not_selected', _delegate.end_date_not_selected);
    add('select_from_date', _delegate.select_from_date);
    add('select_to_date', _delegate.select_to_date);
    add('date_range_not_selected', _delegate.date_range_not_selected);
    add('date_range_partial', _delegate.date_range_partial);
    add('save', _delegate.save);
    add('delete_trip', _delegate.delete_trip);
    add('delete_trip_confirm', _delegate.delete_trip_confirm);
    add('cancel', _delegate.cancel);
    add('ok', _delegate.ok);
    add('add_expense', _delegate.add_expense);
    add('edit_expense', _delegate.edit_expense);
    add('category', _delegate.category);
    add('amount', _delegate.amount);
    add('invalid_amount', _delegate.invalid_amount);
    add('no_categories', _delegate.no_categories);
    add('add_category', _delegate.add_category);
    add('category_name', _delegate.category_name);
    add('note', _delegate.note);
    add('note_hint', _delegate.note_hint);
    add('select_both_dates', _delegate.select_both_dates);
    add('select_both_dates_or_none', _delegate.select_both_dates_or_none);
    add('end_date_after_start', _delegate.end_date_after_start);
    add('start_date_optional', _delegate.start_date_optional);
    add('end_date_optional', _delegate.end_date_optional);
    add('dates', _delegate.dates);
    add('expenses_by_participant', _delegate.expenses_by_participant);
    add('expenses_by_category', _delegate.expenses_by_category);
    add('uncategorized', _delegate.uncategorized);
    add('backup', _delegate.backup);
    add('no_trips_to_backup', _delegate.no_trips_to_backup);
    add('backup_error', _delegate.backup_error);
    add('backup_share_message', _delegate.backup_share_message);
    add('import', _delegate.import);
    add('import_confirm_title', _delegate.import_confirm_title);
    add('import_success', _delegate.import_success);
    add('import_error', _delegate.import_error);
    add('categories', _delegate.categories);
    add('from', _delegate.from);
    add('to', _delegate.to);
    add('add', _delegate.add);
    add('participant_name', _delegate.participant_name);
    add('participant_name_hint', _delegate.participant_name_hint);
    add('edit_participant', _delegate.edit_participant);
    add('delete_participant', _delegate.delete_participant);
    add('add_participant', _delegate.add_participant);
    add('no_participants', _delegate.no_participants);
    add('category_name_hint', _delegate.category_name_hint);
    add('edit_category', _delegate.edit_category);
    add('delete_category', _delegate.delete_category);
    add('currency', _delegate.currency);
    add('settings_tab', _delegate.settings_tab);
    add('basic_info', _delegate.basic_info);
    add('settings', _delegate.settings);
    add('history', _delegate.history);
    add('all', _delegate.all);
    add('search_groups', _delegate.search_groups);
    add('no_search_results', _delegate.no_search_results);
    add('try_different_search', _delegate.try_different_search);
    add('active', _delegate.active);
    add('archived', _delegate.archived);
    add('archive', _delegate.archive);
    add('unarchive', _delegate.unarchive);
    add('archive_confirm', _delegate.archive_confirm);
    add('unarchive_confirm', _delegate.unarchive_confirm);
    add('overview', _delegate.overview);
    add('statistics', _delegate.statistics);
    add('options', _delegate.options);
    add('show_overview', _delegate.show_overview);
    add('show_statistics', _delegate.show_statistics);
    add('no_expenses_to_display', _delegate.no_expenses_to_display);
    add('no_expenses_to_analyze', _delegate.no_expenses_to_analyze);
    add('select_expense_date', _delegate.select_expense_date);
    add('select_expense_date_short', _delegate.select_expense_date_short);
    add('date', _delegate.date);
    add('edit_group', _delegate.edit_group);
    add('delete_group', _delegate.delete_group);
    add('delete_group_confirm', _delegate.delete_group_confirm);
    add('add_expense_fab', _delegate.add_expense_fab);
    add('pin_group', _delegate.pin_group);
    add('unpin_group', _delegate.unpin_group);
    add('theme_automatic', _delegate.theme_automatic);
    add('theme_light', _delegate.theme_light);
    add('theme_dark', _delegate.theme_dark);
    add('developed_by', _delegate.developed_by);
    add('links', _delegate.links);
    add('daily_expenses_chart', _delegate.daily_expenses_chart);
    add('weekly_expenses_chart', _delegate.weekly_expenses_chart);
    add('daily_average_by_category', _delegate.daily_average_by_category);
    add('per_day', _delegate.per_day);
    add('no_expenses_for_statistics', _delegate.no_expenses_for_statistics);
    add('settlement', _delegate.settlement);
    add('all_balanced', _delegate.all_balanced);
    add('owes_to', _delegate.owes_to);
    add('export_csv', _delegate.export_csv);
    add('no_expenses_to_export', _delegate.no_expenses_to_export);
    add('export_csv_share_text', _delegate.export_csv_share_text);
    add('export_csv_error', _delegate.export_csv_error);
    add('expense_name', _delegate.expense_name);
    add('paid_by', _delegate.paid_by);
    add('expense_added_success', _delegate.expense_added_success);
    add('expense_updated_success', _delegate.expense_updated_success);
    add('data_refreshing', _delegate.data_refreshing);
    add('data_refreshed', _delegate.data_refreshed);
    add('refresh', _delegate.refresh);
    add('group_added_success', _delegate.group_added_success);
    add('csv_select_directory_title', _delegate.csv_select_directory_title);
    add('csv_save_cancelled', _delegate.csv_save_cancelled);
    add('csv_save_error', _delegate.csv_save_error);
    add('csv_expense_name', _delegate.csv_expense_name);
    add('csv_amount', _delegate.csv_amount);
    add('csv_paid_by', _delegate.csv_paid_by);
    add('csv_category', _delegate.csv_category);
    add('csv_date', _delegate.csv_date);
    add('csv_note', _delegate.csv_note);
    add('csv_location', _delegate.csv_location);
    add('location', _delegate.location);
    add('location_hint', _delegate.location_hint);
    add('get_current_location', _delegate.get_current_location);
    add('enter_location_manually', _delegate.enter_location_manually);
    add('location_permission_denied', _delegate.location_permission_denied);
    add('location_service_disabled', _delegate.location_service_disabled);
    add('getting_location', _delegate.getting_location);
    add('location_error', _delegate.location_error);
    add('settings_general', _delegate.settings_general);
    add('settings_language', _delegate.settings_language);
    add('settings_language_it', _delegate.settings_language_it);
    add('settings_language_en', _delegate.settings_language_en);
    add('settings_select_language', _delegate.settings_select_language);
    add('settings_theme', _delegate.settings_theme);
    add('settings_select_theme', _delegate.settings_select_theme);
    add('settings_data', _delegate.settings_data);
    add('settings_data_manage', _delegate.settings_data_manage);
    add('settings_data_desc', _delegate.settings_data_desc);
    add('settings_info', _delegate.settings_info);
    add('settings_app_version', _delegate.settings_app_version);
    add('settings_info_card', _delegate.settings_info_card);
    add('settings_info_card_desc', _delegate.settings_info_card_desc);
    add('terms_github_title', _delegate.terms_github_title);
    add('terms_github_desc', _delegate.terms_github_desc);
    add('terms_repo_title', _delegate.terms_repo_title);
    add('terms_repo_desc', _delegate.terms_repo_desc);
    add('terms_issue_title', _delegate.terms_issue_title);
    add('terms_issue_desc', _delegate.terms_issue_desc);
    add('terms_license_desc', _delegate.terms_license_desc);
    add('data_title', _delegate.data_title);
    add('data_backup_title', _delegate.data_backup_title);
    add('data_backup_desc', _delegate.data_backup_desc);
    add('data_restore_title', _delegate.data_restore_title);
    add('data_restore_desc', _delegate.data_restore_desc);
    return m;
  }

  String get(String key, {Map<String, String>? params}) {
    // Usa switch basato sulle chiavi (fallback: stessa chiave se mancante)
    // Parameterized messages handled explicitly
    if (key == 'from_to' && params != null) {
      return _delegate.from_to(params['end'] ?? '', params['start'] ?? '');
    }
    if (key == 'import_confirm_message' && params != null) {
      return _delegate.import_confirm_message(params['file'] ?? '');
    }
    if (key == 'participant_name_semantics' && params != null) {
      return _delegate.participant_name_semantics(params['name'] ?? '');
    }
    if (key == 'category_name_semantics' && params != null) {
      return _delegate.category_name_semantics(params['name'] ?? '');
    }
    if (key == 'csv_saved_in' && params != null) {
      return _delegate.csv_saved_in(params['path'] ?? '');
    }
    String value = _keyMap[key] ?? key;
    if (params != null) {
      params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    }
    return value;
  }
}
