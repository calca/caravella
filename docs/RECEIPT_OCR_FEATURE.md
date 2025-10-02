# Receipt OCR Feature

## Overview
The receipt scanning feature allows users to scan receipts (from camera or gallery) and automatically extract expense information using on-device OCR (Optical Character Recognition).

## Technical Implementation

### Dependencies
- **google_mlkit_text_recognition**: ^0.15.0
  - Provides on-device OCR using ML Kit Text Recognition
  - Works on both Android and iOS
  - No cloud API or internet connection required
  - Supports Latin script text recognition

### Architecture

#### ReceiptScannerService
Located at: `lib/data/services/receipt_scanner_service.dart`

This service handles:
- Text recognition from receipt images
- Parsing text to extract amount and description
- Pattern matching for various receipt formats

**Key Features:**
- **Amount Detection**: Recognizes various patterns:
  - Total keywords: TOTALE, TOTAL, SUBTOTAL, TOT., SOMMA
  - Currency symbols: €, EUR
  - Decimal formats: 12.50, 12,50
  
- **Description Extraction**: Intelligently extracts merchant/item name by:
  - Taking first meaningful lines from receipt
  - Skipping dates, addresses, and pure numbers
  - Prioritizing lines with mixed text content

#### UI Integration
The scan button is integrated into the expense form:
- **Location**: Expense form actions row (left side)
- **Icon**: `Icons.document_scanner_outlined`
- **Visibility**: Only shown in add mode (not edit mode)
- **Position**: Before expand button and delete button

### User Flow

1. **Initiate Scan**: User taps scan receipt button
2. **Choose Source**: Bottom sheet appears with options:
   - Take photo with camera
   - Select from gallery
3. **Processing**: Loading indicator shows "Scanning receipt..."
4. **Results**: 
   - Amount prefills in amount field
   - Description prefills in name/description field
   - Success message: "Receipt scanned"
   - If no text found: "No text found in image"
   - On error: "Error scanning receipt"

### Localization Support
Full i18n support in all app languages:
- Italian (it)
- English (en)
- Spanish (es)
- Portuguese (pt)
- Chinese (zh)

**Translation Keys:**
- `scan_receipt`: Button label
- `scanning_receipt`: Processing message
- `receipt_scan_error`: Error message
- `no_text_found`: No text detected message
- `receipt_scanned`: Success message

## Permissions
Camera permission is already configured in `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

## Testing
To test the feature:
1. Create or open an expense group
2. Tap "Add expense" to open the expense form
3. Look for the document scanner icon on the left side
4. Tap it and choose camera or gallery
5. Take/select a photo of a receipt
6. Verify the amount and description are prefilled

## Limitations
- Works best with clear, well-lit receipt images
- Latin script only (supports Italian, English, Spanish, Portuguese, French, etc.)
- Amount extraction prioritizes "total" patterns but may extract other amounts
- Description extraction is heuristic-based and may vary by receipt format

## Future Enhancements
- Support for additional text recognition scripts (Chinese, Arabic, etc.)
- Date extraction from receipts
- Category suggestion based on merchant name
- Multi-item receipt parsing
- Receipt image attachment to expense
