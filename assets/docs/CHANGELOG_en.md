## 1.8.0 (14.07.2026)

- **New**: Voice input – speak naturally to add an expense, with amount, description, category, date, and payer parsed automatically, in all supported languages
- **New**: Receipt OCR scanning – photograph a receipt and let on-device text recognition extract the amount and description for you
- **New**: Unsplash image search for group backgrounds, with in-app download
- **New**: Android home screen widget showing today's and the group's total spending, with quick-add and open-group actions
- **New**: Dedicated expense search page with full-text search, a calendar highlighting days with expenses, and filters by category, participant, attachment, and location
- **New**: Gmail-style full-screen group search from the groups page
- **New**: Custom group templates – create, edit, and delete your own group types with a name, icon, and default categories from Settings
- **Improvements**: Expense group detail page redesigned to match the home card style, with a centered header
- **Improvements**: Group creation wizard refined with cleaner layout and input styling
- **Improvements**: Group template editor moved to a dedicated full-screen page with clearer icon selection and an editable category list, and now usable when editing existing groups too
- **Fixed**: Voice input no longer leaks a leading currency symbol into the description, and now reliably surfaces recognition errors instead of silently failing
- **Fixed**: Receipt scan button opens the camera directly, with gallery available via long-press
- **Fixed**: Unsplash background picker no longer shows a stale thumbnail, and now works correctly in all release builds
- **Fixed**: Duplicate participant/category name check no longer flags the item being edited against itself
- **Fixed**: Add expense form no longer flashes a red "invalid" background on open, and the Add/Save button now turns primary-colored as soon as the form becomes valid
- **Fixed**: Quick-add expense sheet now opens full edit mode with a swipe-up gesture

## 1.6.0 (03.04.2026)

- **New**: Android AI agent integration – Google Gemini can add expenses and check balances for you
- **New**: Group creation wizard with guided 3-step flow for first-time users
- **New**: Month separators in expense list for better navigation
- **New**: Pagination for large expense lists with smooth loading
- **New**: Featured card on home page highlights your pinned group
- **New**: Smooth animations when adding new expenses
- **Improvements**: Redesigned home page layout with featured group and carousel
- **Improvements**: Group settings reorganized into dedicated pages for easier access
- **Improvements**: Export options displayed in clear card-based layout
- **Improvements**: Home page skeleton loader matches actual widget structure
- **Fixed**: Expense amounts now correctly show decimal places everywhere
- **Fixed**: Persistent notifications respect group date ranges
- **Fixed**: Notifications update correctly from all entry points
- **Fixed**: Welcome page appears smoothly on first launch

## 1.4.0 (16.12.2025)

- **New**: Media attachments support for expenses (images, PDFs, videos) with full-screen viewer
- **New**: Markdown export format with comprehensive statistics and expense tables
- **New**: Tab-based group editing with organized sections for General, Participants, Categories, and Settings
- **New**: Share button in expense form to share expense details as text
- **Improvements**: Camera now opens with rear camera by default for more natural photo-taking
- **Improvements**: Improved attachment handling with better error feedback and stability
- **Improvements**: Consolidated group settings into single interface with tab navigation
- **Fixed**: Android notification icons now work correctly in all build variants
- **Fixed**: Button style consistency across all forms
- **Technical**: Updated to Flutter 3.38.3 with latest dependency versions

## 1.2.0 (03.12.2025)

- **New**: Interactive maps with OpenStreetMap showing expense locations
- **New**: Location search with autocomplete and automatic GPS capture
- **New**: Dynamic color theming adapts to your device wallpaper (Android 12+)
- **New**: Android Quick Actions to launch expense groups from home screen
- **New**: Automatic update checks with weekly notifications
- **Improvements**: Beautiful skeleton loader animations for smoother loading
- **Improvements**: Enhanced currency display with locale-aware formatting
- **Fixed**: Auto-location setting now saves correctly

## 1.0.45 (16.10.2025)

- **Fixed**: Completed translations for all supported languages
- **Fixed**: Added missing translation keys in Spanish (3), Portuguese (81), and Chinese (135)
- **Improvements**: All languages now have complete parity with 511 translation keys each

## 1.0.44 (09.01.2025)

- **Changed**: Android app now restricted to smartphone devices only (tablets excluded) for optimal user experience
- **Changed**: Refactored save button enable logic tests for improved readability and consistency

## 1.0.38 (07.01.2025)

- **New**: "What's New" page accessible from version number in settings
- **Improvements**: Optimized user interface for Material 3
- **Bug fixes**: Minor fixes for app stability