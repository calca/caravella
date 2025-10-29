// Caravella Core Package - Main exports
// This file exports all public APIs from the core package

// Configuration
export 'config/app_config.dart';
export 'config/app_icons.dart';

// Data Models
export 'data/model/expense_category.dart';
export 'data/model/expense_details.dart';
export 'data/model/expense_group.dart';
export 'data/model/expense_location.dart';
export 'data/model/expense_participant.dart';

// Storage and Repository
export 'data/expense_group_repository.dart';
export 'data/expense_group_storage_v2.dart';
export 'data/file_based_expense_group_repository.dart';
export 'data/storage_benchmark.dart';
export 'data/storage_errors.dart';
export 'data/storage_index.dart';
export 'data/storage_performance.dart';
export 'data/storage_transaction.dart';

// Services
export 'services/logger_service.dart';
export 'services/preferences_service.dart';
export 'services/rating_service.dart';
export 'services/app_shortcuts_service.dart';
export 'services/platform_shortcuts_manager.dart';

// State Management
export 'state/dynamic_color_notifier.dart';
export 'state/expense_group_notifier.dart';
export 'state/locale_notifier.dart';
export 'state/theme_mode_notifier.dart';
