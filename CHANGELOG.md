# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New **Sync** CTA in the expense group detail page's action row, right before Settings — opens that group's sharing/sync settings directly. Its icon is tinted green when fully synced, ochre when sync is pending or a previous sync failed, matching the same sync-health signal already used in Settings → Sync
- New **Invite your friends** entry in Settings → Info: shares a friendly pre-written message with the Play Store link via the system share sheet (WhatsApp, etc.)
- Sync groups between your own devices over local Wi-Fi, Bluetooth, or an optional Google Drive relay is now reachable from the app: a **Sync** entry in Settings → Data (Wi-Fi status, Bluetooth pairing, cloud opt-in, history), a per-group **Enable sync** toggle in group settings, and a sync status indicator on the home screen (#416)
- Local (Wi-Fi/LAN) sync is now off by default and must be turned on from Settings → Sync — it previously started automatically on every launch with no way to disable it; QR pairing and the paired-devices list are hidden while it's off, and the choice persists across restarts
- Bluetooth sync now has the same enable/disable toggle in Settings → Sync (off by default) — the manual pairing entry point is hidden until turned on
- **QR code pairing for Wi-Fi sync**: show a QR code on one device and scan it from another (Settings → Sync) to establish trust between them — automatic LAN sync now only exchanges data with devices that have completed this handshake, instead of any app install on the same network. Paired devices are listed in Settings → Sync (removable) and, for any group with sync enabled, in that group's settings
- **Real Google Drive cloud sync**, in a new optional `google_drive_sync` package built only when compiled with `--dart-define=ENABLE_GOOGLE_DRIVE_SYNC=true` (off by default, including all current release builds): sign in with your own Google account and sync data is relayed through a hidden, app-private folder in your own Drive — never a server we operate. See the new [setup guide](docs/GOOGLE_DRIVE_SYNC_SETUP.md) for the Google Cloud Console configuration this requires

### Security
- **LAN and Bluetooth sync payloads are now end-to-end encrypted.** Pairing (QR code or Bluetooth) exchanges each device's X25519 public key — never a shared secret — and both sides derive an identical AES-256-GCM key via ECDH + HKDF-SHA256; every subsequent delta exchange is encrypted and authenticated with that key instead of being sent as plain JSON over plain HTTP (LAN) or plain Nearby Connections payloads (Bluetooth). A device that never completed the handshake has no key on file and its sync requests are rejected outright, whatever transport it uses
- **Pairing now grants access per group, not to every synced group.** Trusting a device previously meant it could pull *any* group you'd turned sync on for; now each pairing (from a specific group's Sync sub-page) grants that one group only, enforced independently on the receiving side even if a peer's delta claims a group it was never granted
- **Bluetooth sync no longer auto-accepts and syncs with any nearby device** advertising the app's service ID — it now requires the same handshake as LAN (public-key exchange, per-group grant) before any data is exchanged, closing a gap where proximity alone was enough to sync
- Pairing QR codes now expire 5 minutes after being generated — scanning a stale/photographed code past that window is rejected instead of remaining usable indefinitely. The QR display sheet shows a live countdown and switches to a "generate new code" prompt once it expires
- Pairing now detects when a code's address is an Android Emulator's private NAT address (`10.0.2.x`, unreachable from outside that one emulator instance) and shows a specific explanation instead of a raw connection error — both when scanning such a code and, as a heads-up, on the QR display sheet when the showing device is itself an emulator
- LAN sync no longer auto-syncs with every device broadcasting the app's mDNS service on the same Wi-Fi network — only devices paired via QR code are trusted; unpaired peers are discovered but never exchanged data with, closing the "syncs with strangers on the same network" gap in the original LAN sync groundwork
- Bluetooth sync is now gated behind `--dart-define=ENABLE_BLUETOOTH_SYNC` (default `true`, preserving current behavior) so F-Droid-style builds can exclude it and the Google Play Services dependency it reaches (`nearby_connections`) by passing `=false` — F-Droid's own build recipe (`metadata.yml`) now does this

### Fixed
- Fixed the press ripple on Settings (and group settings) tiles not filling the whole rounded card: the tap handler lived on the inner `ListTile`, whose own unclipped, non-rounded ink splash didn't match the card's rounded corners painted separately by `SettingsCard`/`BaseCard`. `SettingsCard` now exposes an `onTap` that's forwarded to `BaseCard`'s existing clipped `Material`/`InkWell`, and every settings/group-settings/sync row moved its tap handler there instead of onto the `ListTile`
- Fixed the same ripple-clipping bug on every toggle row (Share this group, Wi-Fi/Bluetooth/Cloud sync enable, FLAG_SECURE, App Functions, Dynamic color, Auto backup): the toggle handler now lives on `SettingsCard.onTap` too, so tapping anywhere on the row — not just the small `Switch` control — both flips the setting and produces a ripple that correctly fills the rounded card, instead of an unclipped splash confined to the switch alone (or, on rows that had no row-level tap handler at all, no ripple and no reaction whatsoever outside the switch)
- Fixed the group detail page's Android status bar icons rendering invisible (white-on-light) whenever the group has no background image, regardless of theme — its `SliverAppBar` used a transparent `backgroundColor` without an explicit `systemOverlayStyle`, so Flutter computed its own status bar icon style from that color's *estimated* brightness instead of the app's; `Colors.transparent`'s RGB channels read as black once alpha is disregarded, so the app bar silently requested light (white) icons on every screen regardless of the actual (light) header behind it, overriding the correct per-screen `AppSystemUI` styling. Also removed a since-superseded app-root call that independently re-applied a theme-only icon style on every rebuild, and fixed the group's own accent color (when set, no image) not being taken into account for that contrast at all
- Fixed the SQLite v2→v3 upgrade skipping the sync columns/tables for any pre-existing (real-world) database, which made every install upgrading from before the sync groundwork land fail to read its existing groups and fail to save new ones
- Bluetooth pairing now requests the required Android 12+/13+ runtime permissions (scan/connect/advertise, nearby Wi-Fi devices) before starting discovery, with a localized error shown if denied, instead of silently failing to find any device; added the corresponding manifest entries and the iOS Bonjour/local-network declarations LAN sync needs
- The Sync row's green/ochre status dot (shown on the home screen and Settings → Data when sync is on) now also appears on the **Sync** row in a group's own settings, once that group's sync toggle is enabled — previously only a plain icon was shown there

### Changed
- Sync History is now a dedicated full page (Settings → Sync → Sync History) instead of a modal bottom sheet, and is also reachable per-group from that group's own Sync sub-page, scoped to sync events that touched that group specifically
- The shared-group indicator on home screen group cards is now a text pill ("Condiviso"/"Shared") matching the existing favorite pill's style, placed to its right, instead of a bare people icon + sync-status dot in the title row
- Removed the shared-group people icon from the expense groups list (history/all-groups page) — redundant now that the home screen carries its own indicator
- Settings reordering: **Template e tipologia gruppi** moved right before **Informazioni** (after Privacy and Dati), and **Lingua**, **Colore dinamico**, **Tema** moved out of the General section into a new **Aspetto** sub-page reachable from a single entry row, mirroring the Data/Group-templates sub-page pattern
- Theme selection in Settings → Aspetto is now an inline "Sistema / Giorno / Notte" 3-card selector (tap to apply immediately) instead of a modal bottom sheet
- Removed the separate sync-history icon button from the home screen header — the home screen now shows a single Settings button with a small status dot: green when at least one sync channel is enabled and the last sync had no errors, ochre when the last sync failed (to draw attention), and no dot when sync isn't configured at all. Sync history itself is still reachable from Settings → Sync. The same status dot now also appears on the **Synchronization** row in Settings → Data
- Settings → Sync is now two entry tiles instead of one long stacked page: **Sync with other people** (Wi-Fi/Bluetooth pairing with other people's devices) and **Sync your devices** (Google Drive cloud relay across your own devices), each on its own sub-page — reflecting that these solve different problems (pairing with someone else vs. keeping your own devices in sync) and use unrelated trust models; the cloud sub-page now also explains that enabling it applies to all groups at once, unlike per-group Wi-Fi/Bluetooth sync
- A group's **Share this group** sync toggle (in that group's own Sync sub-page) can only be turned on once Wi-Fi or Bluetooth sync is turned on app-wide, and now shows why it's disabled otherwise. Once on, that same page hosts the real **Show QR code** / **Share via Bluetooth** actions for that specific group — pairing now happens from the group you're sharing, not from a generic app-wide screen — with a proper section header for the paired-devices list instead of a plain inline label. Settings → Sync (the app-wide page) keeps only the two on/off toggles plus the group-agnostic **Scan QR code** / discover-a-nearby-device actions, since a device receiving a group for the first time has nowhere else to start from
- Per-group sync (enable toggle + paired devices list) moved out of the main group settings screen into its own **Synchronization** sub-page, matching the General/Participants/Categories/Other pattern instead of being inlined
- Settings rows now render via the shared `BaseCard` (`caravella_core_ui`) instead of a bespoke `Card`-based reimplementation, and the "edit name" dialog uses the shared `Material3Dialog` instead of a raw `AlertDialog`
- The new group Synchronization sub-page now uses the shared `CaravellaAppBar` instead of a bespoke `AppBar`, matching the General/Participants/Categories/Other sub-pages
- Snackbar-style messages (receipt scanning, voice input errors, group save/archive errors) now consistently use the shared `AppToast` component instead of ad-hoc `ScaffoldMessenger` snackbars
- Removed the legacy single-date-picker fallback in the group period editor (dead code kept for backwards compatibility since the range picker was introduced)
- The Cloud Sync section in Settings → Sync is now hidden entirely on builds without Google Drive sync (the default), instead of showing a toggle that silently did nothing; fixed the toggle constructing a fresh, session-less channel on every rebuild instead of reusing the real one
- Privacy policy and permissions documentation (`store/`) updated to reflect that sync (Wi-Fi/Bluetooth device sync, optional Google Drive relay) can now transmit expense/group/participant data — previously these documents stated the app never does this
- Upgraded the `bonsoir` mDNS package (LAN sync discovery) from 5.1.11 to 7.1.4, migrating `lan_sync_channel.dart` to its new sealed discovery-event types and `hostAddress`/`initialize()` APIs
- The Cloud Sync privacy confirmation in Settings → Sync now uses the shared `Material3Dialog` (`Material3Dialogs.showConfirmation`) instead of a raw `AlertDialog`
- Upgraded `google_sign_in` 6.3.0 → 7.2.0 in `google_drive_sync` (Google Drive cloud sync), migrating `GoogleDriveAuthService` to the new singleton `GoogleSignIn.instance`/`initialize()`/`authenticate()`/`attemptLightweightAuthentication()` API and requesting the Drive scope per-authorization via `GoogleSignInAccount.authorizationClient` instead of the removed `signIn()`/`authHeaders`; also upgraded `googleapis` 14.0.0 → 16.0.0 (no code changes needed), `talker`/`talker_flutter` 5.1.17 → 5.1.19, `uuid` 4.5.3 → 4.6.0, `share_plus` → 13.2.1, and `package_info_plus` → 10.2.1

## [1.8.0] - 2026-07-14

### Added
- **Voice input for expenses**: speak naturally to add an expense — amount, description, category, date, and payer are parsed automatically; available from the expense form and a home-screen quick-add CTA, in all 5 app languages (#228)
- **Receipt OCR scanning**: photograph a receipt and have the amount and description extracted automatically via on-device ML Kit text recognition (#226)
- **Unsplash image search** for expense group backgrounds, with in-app download and attribution (#422)
- **Android home screen widget**: configurable widget showing today's and the group's total spending, with quick-add and open-group actions; resizable and reconfigurable after placement (#438, and follow-up refinements #445–#481)
- **Dedicated expense search page**: full-text search with a calendar that highlights days with expenses, plus filters by category, participant, attachment, and location (#414)
- **Gmail-style full-screen group search** from the groups/history page (#435)
- Settings: new **Group templates** section to create/edit/delete custom group templates (name, icon, default categories), persisted via `PreferencesService`
- Group creation: type selector now includes custom templates and applies their default categories when selected, while preserving built-in `ExpenseGroupType` behavior

### Changed
- Expense group detail page redesigned to match the home card style: same background resolution, centered header, and reused `GroupCardHeader`/`GroupCardAmounts` widgets (#482)
- Group creation wizard: refined layout and input presentation, name label hidden with left-aligned input, and accidental swipe navigation between steps disabled (#475, #483)
- Unified primary button style across the app (expense form, wizard, group templates), replacing duplicated FAB/bottom-bar styling with the shared `AddFab`/`BottomActionBar` widgets
- Group type templates: creating/editing a template now opens a dedicated full-screen page with the primary action pinned at the bottom, instead of a popup dialog; the categories list now uses the same editable list style found in the group form, and the icon selection highlights the selected icon more clearly
- Group type templates: renamed "Group templates" to "Group type templates" throughout the app (settings section/page titles) to better reflect that templates apply to group types
- Group type selector: custom templates are now shown (and selectable) when editing an existing group, not only when creating a new one; the selector list now only shows the template name, without the categories preview

### Fixed
- Voice input no longer leaks a leading currency symbol (e.g. "€12") into the parsed expense description
- Voice input now reliably surfaces recognition errors (permission denied, no speech detected, recognition failure) instead of silently failing after the first use — root cause was a singleton speech-recognition listener wired only once for the app's lifetime
- Receipt scan: tapping the scan button now opens the camera directly, with gallery selection available via long-press; camera/photo permission denial shows a dedicated message instead of a generic "scan failed" one
- Unsplash background picker no longer shows a stale thumbnail image when a grid cell is reused for a different photo (#433)
- Unsplash image search now works correctly in F-Droid/GitHub release builds, where it was previously disabled (#429)
- Duplicate participant/category name check no longer flags the item being edited against itself (e.g. a simple case change like "Mario" → "mario")
- Add expense form: amount and description fields no longer show a reddish "invalid" background as soon as the sheet opens (the amount field autofocuses, which previously marked both fields as touched instantly); the fields are now only flagged as touched after the user leaves them
- Add expense form: the description field's validation state is now tracked independently from the amount field, instead of incorrectly sharing the amount field's touched flag
- Add expense form: the "Add"/"Save" button now correctly turns primary-colored as soon as all required fields become valid, instead of staying gray until an unrelated rebuild occurred
- Add expense compact sheet: removed the full-edit action button and enabled swipe-up gesture to open the full edit flow

## [1.6.0] - 2026-04-03

### Added
- Android App Functions integration (`packages/android_app_functions`) to expose Caravella capabilities to Android AI agents (e.g. Google Gemini)
  - **addExpense** – AI agent can launch the add-expense screen pre-filled with group, amount, category, and note
  - **getGroupBalance** – Returns the total balance for a specific expense group
  - **getRecentExpenses** – Returns the last 3 expenses for a specific expense group
  - **getTodayTotal** – Returns the total amount spent today for a specific expense group
  - `CaravellaAppFunctionService` (Kotlin) handles function calls directly from the Android OS without requiring a running Flutter engine for read-only queries
  - `AppFunctionStorageReader` (Kotlin) reads the JSON storage file directly for fast background access
  - `AppFunctionsService` (Dart) handles `addExpense` callbacks when the app is running and forwards them to the UI
  - Function schema declared in `res/xml/app_function_declarations.xml`

### Changed
- **Refactored expense group settings navigation from tabs to separate pages**
  - Removed tab-based interface from group edit page
  - Created 4 dedicated pages: General, Participants, Categories, and Other settings
  - Improved navigation flow with direct page-to-page transitions
  - Settings are now accessed individually from the group settings menu
  - Each settings page maintains its own state and save logic

### Fixed
- Expense amounts now correctly display decimal places in transaction lists
  - Previously amounts like 12.50 were shown as just "12"
  - Decimal display now enabled across all expense list views (main list, home screen, map view)
  - Affects `FilteredExpenseList`, `GroupCardRecents`, and `ExpenseMapDetailSheet` components

### Changed
- Updated `flutter_local_notifications` to 20.0.0
  - Adapted notification service to use named parameters (breaking change in library)
  - Methods `initialize()`, `show()`, and `cancel()` now require named parameters

### Added
- Group creation wizard with optimized 3-step flow for first-time users
  - Complete multi-language support (EN, IT, ES, PT, ZH)
- Month separators in expense list for better organization and navigation
  - Localized month/year headers automatically inserted between expenses from different months
  - Visual dividers help users quickly locate expenses by time period
- Pagination in expense list for improved performance with large datasets
  - Initial load of 100 expenses with "Load more" button for additional items
  - Prevents UI lag when viewing groups with many expenses
- Smooth animation for newly added expenses in the expense list
  - Newly created expenses fade in and scale up with a subtle bounce effect
  - Visual feedback helps users identify their just-added expense in the list
- Featured card on home page for pinned/most recent expense group
  - Prominently displays the most important group in a dedicated 60% height card
  - Remaining groups shown in carousel below (40% height)
  - Improved visual hierarchy and user focus on primary group
- Enhanced animations for expense additions on home page
  - Total amount animates with scale and fade effect when updated
  - Daily spent badge slides in from top with fade animation
  - Recent expenses animate with staggered slide and fade effects
  - Creates smooth visual feedback without intrusive toast notifications

### Fixed
- Fixed wizard bug where user name entered in first step was not automatically added as participant in the group
- Welcome page now appears smoothly on first app launch without skeleton flash
- Persistent notifications now respect expense group date ranges
  - Notifications are automatically cancelled when group end date has passed
  - Groups with future start dates no longer trigger notifications prematurely
  - Date range validation applied consistently across all notification update paths
- Notifications now update correctly after expense operations from all entry points
  - Adding/editing expenses from home page quick actions properly refreshes notification count
  - Notification badge accurately reflects current expense totals in all scenarios

### Changed
- Home page skeleton loader improved to match the actual widget structure
  - Centered total amount display
  - Today's spending badge with primary color accent
  - Recent expenses section with two compact expense card placeholders
  - Better visual consistency between loading and loaded states
- Group options menu reorganization for improved accessibility and workflow efficiency
  - Pin/favorite action moved to group avatar for faster access (33% fewer taps: 3→2)
  - Options menu replaced with dedicated settings page using consistent SettingsSection and SettingsCard widgets
  - Settings organized into logical sections: Group editing (with direct navigation to General, Participants, Categories, Other tabs), Export & Share, and Danger Zone
  - Edit group navigation now opens at specific tab (33% fewer taps to edit specific sections: 6→4)
  - Archive and delete actions clearly separated in danger zone section
  - Pin icon always visible on avatar with animated state transitions and color feedback
- Export options sheet improved with scrollable card-based layout
  - Each format (CSV, OFX, Markdown) displayed in dedicated card with icon and description
  - Clear separation between share and save actions with labeled buttons
  - Better visual hierarchy and format descriptions for user clarity
- Home page layout restructured for better content hierarchy
  - Featured card (60% of content height) displays pinned/favorite or most recent group
  - Carousel reduced to 40% of content height showing remaining groups
  - Skeleton loader updated to match new two-section layout
  - Improved visual balance and focus on primary expense group

### Technical
- SQLite repository code refactoring for improved readability and formatting
- Enhanced SQLite backend with attachments table support for expense management

## [1.4.0] - 2025-12-16

### Fixed
- Button style consistency across expense and group forms
  - Save/add buttons in expense group and expense forms now use text-only style (TextButton) to match the compact expense form
  - Ensures consistent visual design across all form submission buttons
- Android notification icon missing in flavor-specific builds causing "invalid_icon" error when enabling notifications
  - Added ic_notification.png resources to all Android build flavors (dev, staging, prod)
  - Added default notification icon metadata in AndroidManifest.xml for improved compatibility
  - Ensures notifications work correctly on all Android devices regardless of build variant
- Camera now opens with rear (back) camera by default instead of front camera when taking photos or videos for attachments or group backgrounds
  - Added `preferredCameraDevice` parameter to image picker calls
  - Improved user experience by defaulting to the more commonly used rear camera
- Improved attachment handling to prevent black screen issues and app instability
  - Added comprehensive logging throughout attachment flow for better debugging
  - Added file size checks to skip compression for very small (<200KB) or very large (>50MB) files
  - Prevents memory pressure issues during compression that could cause app crashes
  - Added cancel button to camera media type picker dialog
  - Enhanced error handling in compression and save operations

### Known Limitations
- **Attachment Visibility**: Attachments are stored in app-private storage and are not visible in Android Photos or Files apps by design
  - This prevents cluttering the user's photo gallery with expense attachments
  - Users can use the Share button in the attachment viewer to export files to their gallery or other apps
  - Future enhancement may add optional MediaStore integration for gallery visibility

### Added
- **SQLite Database Backend**: New high-performance storage backend using SQLite (default)
  - Improved query performance with indexed columns and normalized schema
  - Better scalability for large datasets
  - Automatic migration from JSON file storage to SQLite database
  - Backward compatibility: legacy JSON backend still available via `USE_JSON_BACKEND=true` flag
  - Comprehensive test suite for SQLite repository and migration service
  - Database schema with separate tables for groups, participants, categories, and expenses
  - Transaction support for atomic operations and data integrity
  - Automatic backup of JSON data after successful migration
- Markdown export format for expense groups with comprehensive statistics and expenses table
  - Includes group header with title, period, currency, and participant count
  - Statistics section with total expenses, daily average, per-participant breakdown, per-category breakdown, and settlement calculations
  - Expenses table with all expense details (description, amount, paid by, category, date)
  - Available in all supported languages (EN, IT, ES, PT, ZH)
- Tab-based navigation in group edit page with four segments: General, Participants, Categories, and Other settings
- Media attachments support for expenses with image, PDF, and video file types (max 5 per expense)
- Attachment picker with camera, gallery, and file selection options
- Full-screen attachment viewer with swipe navigation, delete and share actions
- PDF preview with full document rendering and scrolling support
- Video playback with player controls (play, pause, seek, volume)
- Horizontal thumbnail gallery for viewing and managing expense attachments
- Image compression for attachments (max 1920px, 85% quality JPEG) to optimize storage
- Automatic file cleanup when deleting expenses or expense groups
- Organized attachment storage by expense group ID for better file management
- Share button in expense form page to share expense details as formatted text
- Quick access to delete expense from app bar when editing

### Changed
- Consolidated group edit and other settings pages into single interface with tab navigation for easier access to all group options
- Relocated group type selection to tappable icon button (42×42px) next to group name field for streamlined layout
- Reorganized group settings into logical tabs: General (name, type, period, currency), Participants, Categories, and Other (background, auto-location)
- Moved delete button from bottom bar to app bar in expense form for better accessibility
- Repositioned expense form actions to reduce clutter in the main editing area

### Fixed
- Fixed "invalid_icon" PlatformException when enabling persistent notifications by removing conflicting vector drawable - Android now always uses PNG notification icons which are fully supported by flutter_local_notifications plugin
- Fixed incorrect "Backup non riuscito" error message appearing when notification toggle or group save operations failed - now shows proper "Errore durante il salvataggio" with error details
- Fixed setState() during build error in expense form page when form validity or save callback changed
- Fixed place search not showing error messages when network requests fail, timeout, or encounter SSL/TLS issues
- Improved error feedback for location search to display localized error messages instead of silently failing

### Technical
- **Flutter 3.38.3 Update**: Upgraded from Flutter 3.35.5 to 3.38.3 (Dart 3.10.1)
  - Updated all package dependencies to latest compatible versions
  - Updated `file_picker` to ^10.3.7, `share_plus` to ^12.0.1, `image` to ^4.5.4, `archive` to ^4.0.7, `shared_preferences` to ^2.5.3, `http` to ^1.6.0
  - Upgraded 19 transitive dependencies to latest compatible versions
  - Fixed `share_plus` API changes (v10→v12): migrated from `Share.share()` / `Share.shareXFiles()` to `SharePlus.instance.share(ShareParams(...))`
  - Fixed `archive` package breaking changes (v3→v4): updated for non-nullable `ZipEncoder().encode()` return value
  - Updated Dart SDK constraint in `play_store_updates` from >=3.0.0 to >=3.9.0 for consistency
  - Removed dependency_overrides for cleaner dependency resolution
  - All 443 tests passing, accessibility validation confirmed
  - Used `addPostFrameCallback` pattern in expense form to prevent setState() during build lifecycle
- **Platform Abstraction Services**: Added service abstractions in `caravella_core` for better testability:
  - `FilePickerService`: Abstraction for `image_picker` and `file_picker` dependencies
  - `ImageCompressionService`: Abstraction for image compression logic
  - `LocationServiceAbstraction`: Abstraction for `geolocator` and `geocoding` dependencies
- Implementations moved to `lib/manager/expense/services/` with platform-specific code isolated
- `LocationService` refactored to use `LocationServiceAbstraction` for improved testability
- Added comprehensive unit tests for all service abstractions (29 tests, 100% pass rate)
- **AttachmentInputWidget Refactoring**: Reduced complexity from 406 to 215 lines by extracting components:
  - `AttachmentSlot`: Reusable slot widget for empty/filled states (182 lines)
  - `AttachmentStateManager`: Business logic and state management (147 lines)
  - Improved testability with ChangeNotifier pattern and service injection
  - Added 8 unit tests for state manager with 100% pass rate
- **AttachmentViewerPage Refactoring**: Simplified from 378 to 178 lines (53% reduction) by extracting specialized viewers:
  - `PdfViewerPage`: Standalone PDF document viewer with loading and error states (95 lines)
  - `VideoPlayerPage`: Video player with controls using Chewie (107 lines)
  - `ImageViewerPage`: Image viewer with pinch-to-zoom support (46 lines)
  - `AttachmentViewerController`: State management for viewer navigation and deletion (44 lines)
  - Main page now acts as coordinator/orchestrator delegating to specialized viewers
  - Improved code reusability and maintainability with separated concerns
- **Validation and Error Handling Consolidation**: Centralized validation and error handling for consistency:
  - `ExpenseValidationService`: Pure validation functions for amounts, names, participants, categories (113 lines)
  - `ExpenseErrorHandler`: Centralized error messaging using AppToast for all expense operations (169 lines)
  - Validation logic extracted from controllers and made independently testable
  - Consistent error messaging across attachment, location, and form validation flows
  - ExpenseFormController migrated to use ExpenseValidationService
  - AttachmentInputWidget migrated to use ExpenseErrorHandler
- **Location Subsystem Reorganization**: Eliminated circular dependencies and improved architecture:
  - `LocationRepository`: Abstract interface for location operations (29 lines)
  - `LocationRepositoryImpl`: Coordinates LocationService and NominatimSearchService (139 lines)
  - `LocationConstants`: Consolidated constants from multiple files (25 lines)
- **ExpenseFormComponent Refactoring**: Dramatically improved maintainability by consolidating parameters and extracting lifecycle logic:
  - `ExpenseFormConfig`: Configuration object consolidating 43 constructor parameters into structured config (160 lines)
  - `ExpenseFormLifecycleManager`: Lifecycle management with auto-location, category handling, and resource cleanup (161 lines)
  - `ExpenseFormOrchestrator`: Business logic coordination for save/delete flows and form callbacks (132 lines)
  - Constructor reduced from 43 parameters to 1 config object (98% reduction in parameters)
  - Factory methods (`.create()` and `.edit()`) for common use cases with backward compatibility
  - Legacy constructor (`.legacy()`) maintains full backward compatibility with existing code
  - Improved testability with separated concerns and clear responsibility boundaries
  - `LocationService` simplified from 149 to 68 lines (54% reduction) using repository pattern
  - Linear dependency chain: Widgets → LocationService → LocationRepository → Platform services
  - Error handling migrated to ExpenseErrorHandler for consistency
  - Removed circular dependencies between widgets and services
- **AppToast Centralization**: Completed 100% centralization of ScaffoldMessenger usage through AppToast
  - Connected `rootScaffoldMessengerKey` in main app to enable fallback mechanism for unmounted contexts
  - Replaced remaining direct SnackBar usage in attachment viewer with AppToast
  - Added comprehensive documentation for `rootScaffoldMessengerKey` setup requirement
  - Exported `rootScaffoldMessengerKey` from caravella_core_ui for main app access
  - Toast messages now work reliably after navigation or sheet dismissal in async operations

## [1.2.0] - 2025-12-03

### Added
- Theme-aware color palette for expense groups that adapts colors based on light/dark mode
- OpenStreetMap integration for visualizing expense locations on an interactive map
- Map view button in expense group overview to display all expenses with locations on a map
- OpenStreetMap location search for expense form with autocomplete and nearby places suggestions
- Location picker with interactive map selection and reverse geocoding to resolve addresses
- Compact location indicator in expense form showing auto-captured GPS location with visual feedback
- Auto-location toggle setting for automatic GPS retrieval when adding new expenses
- Setting to enable/disable automatic location capture with manual override option
- Dynamic color support with Material 3 integration for personalized app theming (Android 12+, limited iOS support)
- Settings toggle to enable colors derived from device wallpaper with graceful fallback to default themes
- Android Quick Actions (App Shortcuts) for quick access to expense groups from launcher (Android only)
- Dynamic icons for Android Quick Launch shortcuts with group initials and background colors or images
- F-Droid metadata and distribution support
- Comprehensive F-Droid submission documentation
- Persistent notification feature for expense groups showing daily and total spending
- Context menu (long-press) for expense groups in history page with pin/unpin, archive/unarchive, and delete actions
- Material 3 expressive swipe behavior for history page with Gmail-style dismissible actions
- Smooth skeleton loader animation for carousel during cold start with shimmer effect
- Fade-in animation for carousel cards when data loads
- In-app store rating feature with smart triggers (after 10 expenses, then monthly)
- Period selector with interactive calendar and duration presets (3, 7, 15, 30 days)
- Long-press on participant card now opens a bottom sheet with message preview before sending
- Google Play Store automatic update checks with flexible update support (Android only)
- Weekly automatic update check that shows recommendation sheet when new version is available
- Manual update check button in "What's New" page with immediate update capability
- Build variant support for Play Store and F-Droid distributions using factory pattern

### Changed
- Dark theme map tiles now use CartoDB Dark Matter for improved visibility of points of interest
- Current location button in map search now shows loading indicator while fetching GPS position
- Expense group colors now use palette indices for consistent appearance across light and dark themes
- Restructured project into multi-package architecture with core, core-ui, and app separation for improved maintainability
- Enhanced skeleton loader with smooth scale and fade-in animations for more polished loading experience
- Improved new group creation flow with immediate skeleton display and automatic navigation to newly created group
- Improved app metadata for distribution platforms
- Replaced CircularProgressIndicator with CarouselSkeletonLoader in home cards section for better UX
- Refactored PreferencesService architecture with singleton pattern and separated preference categories
- Improved PreferencesService API with synchronous read operations where possible
- Organized preference keys and defaults into centralized abstract classes
- Android Quick Launch shortcut icons now dynamically display group initials with theme colors or group images
- Consolidated currency formatting using CurrencyDisplay widget throughout the app for consistency
- Currency display now uses locale-aware decimal separators respecting user's regional settings
- Applied consistent TabBar styling across History, Stats, and Overview pages for unified experience
- Replaced icon button with text button in expense form for improved accessibility and clarity

### Fixed
- Auto-location setting not saving when modified alone in expense group settings
- Android map rendering issues by adding INTERNET permission and OpenStreetMap domain to security configuration

## [1.0.45] - 2025-10-16

### Fixed
- Completed translations for all supported languages (Spanish, Portuguese, Chinese)
- Added 3 missing translation keys in Spanish
- Added 81 missing translation keys in Portuguese
- Added 135 missing translation keys in Chinese
- Removed 60 obsolete translation keys from Chinese
- All languages now have complete parity with English (511 keys each)

## [1.0.44] - 2025-01-09

### Changed
- Refactored save button enable logic tests for improved readability and consistency

## [1.0.38] - 2025-01-07

### Added
- "What's New" page accessible from version number in settings
- Localized changelog support (English, Italian, Spanish, Portuguese, Chinese)

### Changed
- Optimized user interface for Material 3

### Fixed
- Minor fixes for app stability

## [1.0.0] - Initial Release

### Added
- Group expense management for trips and shared costs
- Participant management with detailed tracking
- Expense tracking with categories and assignments
- Smart calculations for debt settlement
- Location context for expenses
- Photo attachments for groups and expenses
- Data export to CSV and JSON formats
- Complete backup and restore functionality
- Privacy-first local storage (no cloud sync)
- Multi-language support (English, Italian, Spanish, Portuguese, Chinese)
- Material 3 design with dark/light theme support
- Cross-platform support (Android, iOS, Web, Desktop)

[Unreleased]: https://github.com/calca/caravella/compare/v1.8.0...HEAD
[1.8.0]: https://github.com/calca/caravella/compare/v1.6.0...v1.8.0
[1.6.0]: https://github.com/calca/caravella/compare/v1.4.0...v1.6.0
[1.4.0]: https://github.com/calca/caravella/compare/v1.2.0...v1.4.0
[1.2.0]: https://github.com/calca/caravella/compare/v1.0.45...v1.2.0
[1.0.45]: https://github.com/calca/caravella/compare/v1.0.44...v1.0.45
[1.0.44]: https://github.com/calca/caravella/compare/v1.0.38...v1.0.44
[1.0.38]: https://github.com/calca/caravella/compare/v1.0.0...v1.0.38
[1.0.0]: https://github.com/calca/caravella/releases/tag/v1.0.0
