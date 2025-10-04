/// Multi-device secure sync module
/// 
/// This module provides end-to-end encrypted multi-device synchronization
/// for expense groups using QR code-based key exchange and Supabase Realtime.
library sync;

// Models
export 'models/qr_key_exchange_payload.dart';
export 'models/supabase_config.dart';
export 'models/sync_event.dart';
export 'models/device_info.dart';
export 'models/subscription_tier.dart';

// Services
export 'services/group_sync_coordinator.dart';
export 'services/qr_generation_service.dart';
export 'services/realtime_sync_service.dart';
export 'services/supabase_client_service.dart';
export 'services/device_management_service.dart';
export 'services/key_rotation_service.dart';
export 'services/key_backup_service.dart';
export 'services/conflict_resolution_service.dart';
export 'services/auth_service.dart';
export 'services/revenue_cat_service.dart';

// Widgets
export 'widgets/qr_display_widget.dart';
export 'widgets/qr_scanner_widget.dart';
export 'widgets/sync_status_indicator.dart';

// Pages
export 'pages/group_join_qr_page.dart';
export 'pages/group_share_qr_page.dart';
export 'pages/device_management_page.dart';
export 'pages/key_backup_page.dart';
export 'pages/auth_page.dart';
export 'pages/subscription_page.dart';

// Utilities
export 'utils/auth_guard.dart';

// Initialization
export 'sync_initializer.dart';
