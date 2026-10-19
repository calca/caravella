# App: Expense Entry

Covers `lib/manager/expense/**` — the expense form, attachments, voice input, receipt scanning, and the location subsystem.

## State/controller split

`ExpenseFormState` (`state/expense_form_state.dart`) is an **immutable** value object: `category`, `amount`, `paidBy`, `date`, `location`, `name`, `note`, `attachments`, `assignedTo`, plus UI flags (`isDirty`, `isExpanded`, `isRetrievingLocation`) and per-field `*Touched` flags for validation-feedback timing. Exposes `isNameValid`/`isAmountValid`/`isPaidByValid`/`isCategoryValid(categories)`/`isFormValid(categories)`, factories `.initial(...)`/`.fromExpense(...)`, and `toExpense()`.

`ExpenseFormController` (`state/expense_form_controller.dart`, `ChangeNotifier`) owns the `TextEditingController`s, `FocusNode`s, and `GlobalKey`s (for scroll-to-field). Fields are marked "touched" only **on blur** (not on autofocus) so error styling doesn't flash immediately. All real validation is delegated to `ExpenseValidationService`.

## Component composition

`ExpenseFormComponent` (`components/expense_form_component.dart`) is the actual widget used everywhere, via `.create`/`.edit`/`.legacy` factories all funneling into one `ExpenseFormConfig` (a config object whose docstring notes it replaces "43 constructor parameters" — distinguishes `create`/`edit` behavior from whether `initialExpense.id` is set).

Its `initState` builds an `ExpenseFormLifecycleManager` (controller construction, optional `FormScrollCoordinator`, auto-location retrieval, "newly added category" auto-select) and then an `ExpenseFormOrchestrator` (owns `saveExpense`/`deleteExpense`/`expand`, wires parent-supplied callbacks like `onSaveCallbackChanged` so an external toolbar can trigger the form's internal save).

Widget tree in `build()`: `ExpenseFormCompactHeader` ("In group: <title>", hidden by the current callers) → `ExpenseFormFields` (the amount — whole amounts without decimals, otherwise always two, via `ExpenseFormController.formatAmountForInput`, so an edited 54.5 reads "54.50" — then the description as a raised rounded field (`FormTheme.getCardDecoration`), then paidBy and category; touched-and-invalid fields get a subtle red-tinted `AnimatedContainer`) → `ExpenseFormExtendedFields` (always shown, compact sheet included) → `ExpenseFormActionsWidget` when `showActionsRow` (round mic and scan buttons, then a full-width stadium Add expense / Save button; delete only when editing in a sheet). A vertical swipe-up gesture on the compact form still triggers `orchestrator.expand()` (opens `ExpenseFormPage`).

`ExpenseFormExtendedFields` is the "Details" section: a `FormSectionLabel` over a `Wrap` of `FormPill`s (`caravella_core_ui`) — the date (`DateSelectorWidget`, "Today" or the date, opens the date picker), the place (`LocationInputWidget`: dashed "Place" when empty → `PlaceSearchPage`, the locality once set → the details sheet with current location / search / remove, a spinner with "Getting location..." while detecting), attachments (`AttachmentInputWidget(asPill: true)`, dashed, opens the source picker) and note (dashed; tapping reveals the note field and focuses it). Once there are attachments the pill is replaced by the thumbnail strip below; an existing note shows its field straight away. In read-only groups the empty "add" pills are hidden. Automatic location detection runs once, in `ExpenseFormLifecycleManager` (create mode, address resolved), and reports its progress through `ExpenseFormController.setLocationRetrieving`, which the place pill shows; a place the user picks meanwhile is not overwritten.

Hosts: `ExpenseFormPage` (full page: grey `surfaceContainer` background, edge to edge, `RoundBackButton` plus round share / delete (`RoundIconButton`) when editing, the group name over a large "New expense" / "Edit expense" title, and the actions bar pinned at the bottom above the keyboard; the amount is autofocused only when adding) and `ExpenseEntrySheet` (the quick sheet from Home and from the notification: same grey, the form scrolls while the actions bar stays pinned below it, above the keyboard; the sheets open with `useSafeArea` so the taller form stays below the status bar).

`ParticipantSelectorWidget`/`CategorySelectorWidget` (`widgets/`) render a `FormSectionLabel` ("Paid by" / "Category") above a `ChipSelectorRow<T>` (`caravella_core_ui`) — pills that wrap onto more lines, identical in compact and extended mode; payers carry their `ParticipantAvatar` initials, and the selected pill is filled in the text color. The row shows up to 4 items in whatever order the caller passes in (`ExpenseFormPage`/`ExpenseEntrySheet` pass `ExpenseGroup.getParticipantsByLastUsed()`/`getCategoriesByLastUsed()`, so the most recently used participant/category surfaces first); a group with more than 5 values collapses the rest behind a trailing "..." pill (`showSelectionBottomSheet` for the full list), showing the current selection's name instead only when the selection itself is one of the hidden ones. A trailing round "+" opens the same sheet in inline-add mode (`autoStartAdd`) when an add callback is supplied.

## Validation

`validation/expense_validation_service.dart` — pure static functions: `isAmountValid` (non-null & >0), `parseAmount` (normalizes comma→dot), `isNameValid`, `isPaidByValid`, `isCategoryValid` (an **empty categories list is valid** — lets a brand-new group with zero categories still save an expense), `isAttachmentCountValid`, `isLocationValid`, aggregate `isFormValid`. `errors/expense_error_handler.dart` centralizes all toast messaging via `AppToast.show` — note most of its strings are hardcoded English rather than localized (a known inconsistency to watch for when touching this file).

## Attachments

`widgets/attachments/attachment_state_manager.dart` (`ChangeNotifier`) is the business logic: picks via `FilePickerService` (camera/gallery/files), copies into `AttachmentsStorageService.getAttachmentPath(...)` (from `caravella_core`), compresses images through `ImageCompressionService` only when file size is between 200KB–50MB (skips very small/large files, falls back to a plain copy on compression failure). Tracks an `AttachmentProcessingState` (`idle/picking/compressing/saving`).

`AttachmentInputWidget` renders a fixed number of slots (default 5, `AttachmentSlot`) — image thumbnail, or a generic icon for PDF/video/other. Tapping a slot opens `AttachmentViewerPage` (`pages/attachment_viewer_page.dart`, driven by `AttachmentViewerController`), which dispatches per-file to `image_viewer_page.dart`, `pdf_viewer_page.dart`, or `video_player_page.dart` by extension.

## Voice input

`VoiceInputButton`/`VoiceCaptureBottomSheet` (`widgets/`) and the home-card `GroupCardVoiceButton` (`lib/home/cards/widgets/group_card_voice_button.dart`) all wrap `lib/services/voice_input_service.dart`'s `VoiceInputService`, which wraps the `speech_to_text` plugin across the app's 5 supported locales.

- `startListening({localeId, onResult, onError, onDone})` drives the mic; errors are normalized into `VoiceInputError` (`notAvailable`/`permissionDenied`/`noSpeech`/`recognitionFailed`).
- `parseExpenseFromText(text, {participantNames})` is a keyword-based NL parser returning `{amount, name, category, paidBy, date}` — regex-extracts amount (multi-currency tokens), relative dates (yesterday, last week/month, weekday names — per-locale), a "paid by" participant name (matched case-insensitively against the group's participants), and an expense category (locale-specific keyword lists → `food/transport/accommodation/entertainment/shopping/health`).
- From a group card, if amount+payer+category were all parsed the expense is saved directly (`ExpenseGroupStorageV2.addExpenseToGroup`); otherwise `ExpenseFormPage` opens pre-filled. Either path then calls `NotificationManager().updateNotificationForGroupById` and `RatingService.checkAndPromptForRating()`.

## Receipt scanning (OCR)

See the dedicated page: **[Receipt OCR](RECEIPT_OCR.md)**.

## Location subsystem

See the dedicated page: **[Location & Maps](LOCATION_AND_MAPS.md)** for the full geocoding/search pipeline (`LocationService` → `LocationRepository`/`LocationRepositoryImpl` → `NominatimSearchService` → `PlaceSearchController`).

## Scroll coordination

`coordination/form_scroll_coordinator.dart` (`FormScrollCoordinator`) computes whether a field's rect is obscured by the keyboard or too near the top, and `animateTo` an adjusted scroll offset. `coordination/keyboard_aware_scroll_mixin.dart` (`KeyboardAwareScrollMixin`) is a `WidgetsBindingObserver` mixin watching `didChangeMetrics()` for keyboard height changes, invoking an overridable `scrollToFocusedField()` hook.

## See also

- [Receipt OCR](RECEIPT_OCR.md)
- [Location & Maps](LOCATION_AND_MAPS.md)
- [App: Group Details & Stats](APP_GROUP_DETAILS_STATS.md) — where expenses are listed/edited from
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)
