# Receipt OCR

Lets users scan a receipt (camera or gallery) to auto-fill an expense's amount and description, using **on-device** OCR — no network call, no cloud API. This page replaces `RECEIPT_OCR_FEATURE.md` and `RECEIPT_OCR_FLOW.md`.

## Implementation

`ReceiptScannerService` (`lib/data/services/receipt_scanner_service.dart`, singleton) uses **`google_mlkit_text_recognition`** (`TextRecognizer(script: TextRecognitionScript.latin)` — Latin script only, so it covers IT/EN/ES/PT but not the app's Chinese locale).

`scanReceipt(File imageFile)`:
1. `_textRecognizer.processImage(InputImage.fromFile(imageFile))` — runs OCR.
2. `_parseReceiptText` regex-scans line by line for:
   - **Amount** — keyword-adjacent numbers (`totale`, `total`, `subtotal`, `tot.`, `somma`), or `€`/`eur`-adjacent numbers, falling back to any `NN.NN`/`NN,NN` pattern if no keyword/currency match is found.
   - **Description** — the first plausible non-numeric, non-date line within the first 5 lines (merchant name/item guess).
3. `dispose()` closes the recognizer — call this when the owning widget is disposed.

## UI integration

The scan action is a document-scanner icon button in `ExpenseFormActionsWidget` (part of [Expense Entry](APP_EXPENSE_ENTRY.md)), shown only in **add mode** (not when editing an existing expense). Tapping it opens a bottom sheet (camera vs. gallery), shows a "scanning" toast while processing, then:

- **Success** — prefills the amount and name/description fields, shows a success toast.
- **No text found** — shows an informational toast, no fields changed.
- **Error** — shows an error toast (image read failure, OCR exception, etc).

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
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md) — `AppToast` used for all scan feedback
