# Receipt OCR Feature - User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    RECEIPT OCR FEATURE FLOW                     │
└─────────────────────────────────────────────────────────────────┘

User Action                     System Response
═══════════════════════════════════════════════════════════════════

1. ADD NEW EXPENSE
   ┌──────────────┐
   │ Tap "Add     │
   │  Expense"    │
   └──────┬───────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  Expense Form Opens                │
   │  ┌──────────────────────────────┐  │
   │  │ [📄] [↑] [💾]               │  │
   │  │  ↑                           │  │
   │  │  Scan Receipt Button         │  │
   │  └──────────────────────────────┘  │
   └────────────────────────────────────┘

2. INITIATE SCAN
   ┌──────────────┐
   │ Tap Scan     │
   │  Button [📄] │
   └──────┬───────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  Bottom Sheet Appears              │
   │  ┌──────────────────────────────┐  │
   │  │ 📷 From Camera              │  │
   │  │ 🖼️  From Gallery             │  │
   │  └──────────────────────────────┘  │
   └────────────────────────────────────┘

3. SELECT SOURCE
   ┌──────────────┐       ┌──────────────┐
   │ Camera       │  OR   │ Gallery      │
   └──────┬───────┘       └──────┬───────┘
          │                      │
          ▼                      ▼
   ┌────────────┐         ┌────────────┐
   │ Take Photo │         │ Pick Image │
   └──────┬─────┘         └──────┬─────┘
          │                      │
          └──────────┬───────────┘
                     │
                     ▼

4. PROCESS IMAGE
   ┌────────────────────────────────────┐
   │  ⏳ "Scanning receipt..."          │
   │     (SnackBar notification)        │
   └────────────────────────────────────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  🔍 ML Kit Text Recognition        │
   │     • On-device OCR                │
   │     • No internet required         │
   │     • Latin script support         │
   └────────────────────────────────────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  🧠 Smart Text Parsing             │
   │     • Extract amount patterns      │
   │     • Extract description lines    │
   │     • Filter dates/numbers         │
   └────────────────────────────────────┘

5. RESULTS

   SUCCESS PATH                   NO TEXT PATH                ERROR PATH
   ═══════════════════════════════════════════════════════════════════
   Amount and/or                  No text found              Exception caught
   description found              in image                   during processing
          │                            │                          │
          ▼                            ▼                          ▼
   ┌──────────────┐           ┌──────────────┐          ┌──────────────┐
   │ Prefill Form │           │ Show Message │          │ Show Error   │
   │              │           │ "No text     │          │ "Error       │
   │ Amount: 45.50│           │  found"      │          │  scanning"   │
   │ Name: Store  │           └──────────────┘          └──────────────┘
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ ✅ "Receipt  │
   │  scanned"    │
   └──────────────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  Form Ready to Complete            │
   │  ┌──────────────────────────────┐  │
   │  │ Amount:      45.50 ✓        │  │
   │  │ Name:        Store Name ✓   │  │
   │  │ Paid by:     [Select]       │  │
   │  │ Category:    [Select]       │  │
   │  └──────────────────────────────┘  │
   └────────────────────────────────────┘

6. COMPLETE EXPENSE
   ┌──────────────┐
   │ Fill         │
   │ Remaining    │
   │ Fields       │
   └──────┬───────┘
          │
          ▼
   ┌──────────────┐
   │ Tap Save [💾]│
   └──────┬───────┘
          │
          ▼
   ┌────────────────────────────────────┐
   │  ✅ Expense Added to Group         │
   └────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════
TECHNICAL DETAILS
═══════════════════════════════════════════════════════════════════

OCR Processing Pipeline:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  Image File → ML Kit → Text Recognition → Text Parsing         │
│                                                                 │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   │
│  │ Receipt  │ → │ ML Kit   │ → │ Extract  │ → │ Return   │   │
│  │ Image    │   │ OCR      │   │ Amount & │   │ Results  │   │
│  │ (.jpg)   │   │ Engine   │   │ Desc     │   │ (Map)    │   │
│  └──────────┘   └──────────┘   └──────────┘   └──────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Amount Detection Patterns:
• TOTALE 45.50
• TOTAL 45,50
• € 45.50
• 45.50 EUR
• 45.50 (standalone)

Description Extraction:
• First 5 lines analyzed
• Dates filtered (XX/XX/XXXX)
• Pure numbers filtered
• Meaningful text selected

Supported Formats:
• Comma decimal: 12,50
• Dot decimal: 12.50
• With/without currency symbols
• With/without keywords

═══════════════════════════════════════════════════════════════════
```
