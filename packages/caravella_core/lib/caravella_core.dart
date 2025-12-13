// Caravella Core Package - Main exports
// This file exports all public APIs from the core package

// Configuration
export 'config/app_config.dart';
export 'config/app_icons.dart';

// Data Models
export 'model/expense_category.dart';
export 'model/expense_details.dart';
export 'model/expense_group.dart';
export 'model/expense_group_color_palette.dart';
export 'model/expense_group_type.dart';
export 'model/expense_location.dart';
export 'model/expense_participant.dart';

// Storage and Repository
export 'data/expense_group_repository.dart';
export 'data/expense_group_storage_v2.dart';
export 'data/file_based_expense_group_repository.dart';
export 'data/storage_benchmark.dart';
export 'data/storage_errors.dart';
export 'data/storage_index.dart';
export 'data/storage_performance.dart';
export 'data/storage_transaction.dart';

// Services - Logging
export 'services/logging/logger_service.dart';

// Services - Storage
export 'services/storage/preferences_service.dart';
export 'services/storage/attachments_storage_service.dart';

// Services - User Feedback
export 'services/user/rating_service.dart';

// Services - Media
export 'services/media/file_picker_service.dart';
export 'services/media/image_compression_service.dart';
export 'services/media/location_service_abstraction.dart';

// Services - Shortcuts
export 'services/shortcuts/app_shortcuts_service.dart';
export 'services/shortcuts/platform_shortcuts_manager.dart';
export 'services/shortcuts/shortcuts_navigation_service.dart';

// State Management
export 'state/auto_backup_notifier.dart';
export 'state/dynamic_color_notifier.dart';
export 'state/expense_group_notifier.dart';
export 'state/flag_secure_notifier.dart';
export 'state/locale_notifier.dart';
export 'state/theme_mode_notifier.dart';
export 'state/user_name_notifier.dart';
