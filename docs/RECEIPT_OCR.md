# Receipt OCR

Lets users scan a receipt (camera or gallery) to auto-fill an expense's amount and description, using **on-device** OCR — no network call, no cloud API. This page replaces `RECEIPT_OCR_FEATURE.md` and `RECEIPT_OCR_FLOW.md`.

## Implementation

`ReceiptScannerService` (`lib/services/receipt_scanner_service.dart`, singleton) gets its text recognizer from `GmsIntegrations.instance.createReceiptTextRecognizer()`: in Play builds that's `MlKitReceiptTextRecognizer` (`packages/caravella_gms`), **`google_mlkit_text_recognition`** with `TextRecognitionScript.latin` — Latin script only, so it covers IT/EN/ES/PT but not the app's Chinese locale. The F-Droid build has no recognizer: `isAvailable` is false and `ExpenseFormComponent` hides both scan actions — see [caravella_gms](PACKAGE_CARAVELLA_GMS.md).

`scanReceipt(File imageFile)`:
1. `recognizer.recognizeText(imageFile.path)` — runs OCR, returning the plain text.
2. `_parseReceiptText` regex-scans line by line for:
   - **Amount** — keyword-adjacent numbers (`totale`, `total`, `subtotal`, `tot.`, `somma`), or `€`/`eur`-adjacent numbers, falling back to any `NN.NN`/`NN,NN` pattern if no keyword/currency match is found.
   - **Description** — the first plausible non-numeric, non-date line within the first 5 lines (merchant name/item guess).
3. `dispose()` closes the recognizer — call this when the owning widget is disposed.

## UI integration

The scan action is a document-scanner icon button in `ExpenseFormActionsWidget` (part of [Expense Entry](APP_EXPENSE_ENTRY.md)), shown only in **add mode** (not when editing an existing expense). Tapping it opens a bottom sheet (camera vs. gallery), shows a "Reading receipt…" line with a spinner above the form's fields (`_ReceiptScanLine` in `expense_form_component.dart`) while processing, then:

- **Success** — prefills the amount and name/description fields and the line goes (the filled fields are the feedback).
- **No text found** — the line says so (× closes it), no fields changed.
- **Error** — the line says "Couldn’t read the receipt" in red (image read failure, OCR exception, etc). Camera/photo permission denied is still a toast.

Home's receipt button (`AddExpenseController.scanReceiptAndAdd`) reads the photo before the quick-add sheet opens, so there the "reading" and "no text found" messages stay toasts.

## Permissions

Camera permission is declared in `AndroidManifest.xml` (`android.permission.CAMERA`, feature declared `android:required="false"` so the app remains installable/usable without it) and `Info.plist` (`NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription`) on iOS.

## Limitations

- Works best with clear, well-lit receipt images.
- Latin script only — doesn't help for the Chinese locale.
- Amount extraction prioritizes "total" keywords but can pick up other numbers on ambiguous receipts.
- Description extraction is heuristic and varies by receipt layout.

## Testing

```bash
flutter test test/services/receipt_scanner_service_test.dart
```

## See also

- [App: Expense Entry](APP_EXPENSE_ENTRY.md)
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md) — `AppToast` for the scan feedback that has no place on screen (Home's scan, permission denied)
