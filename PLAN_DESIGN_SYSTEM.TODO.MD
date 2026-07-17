# Piano: Recupero Debito Tecnico — Design System & Accessibilità

Basato su un'analisi statica della codebase (luglio 2026). Obiettivi:
1. Centralizzare UI e componenti comuni in `caravella_core_ui`.
2. Migliorare l'uniformità della UI / il design system.
3. Portare i componenti condivisi a conformità WCAG 2.2.

Ogni item riporta i file coinvolti trovati durante l'analisi. Non sono ancora state fatte modifiche al codice — questo è solo il piano.

---

## Fase 0 — Fondamenta (bloccanti per tutto il resto)

- [x] **Ricreare `validate_accessibility.sh`**, citato in `.github/copilot-instructions.md:84` ma assente dal repo. Creato alla root: esegue i test di accessibilità, fallisce su regressioni note-a-zero (`ScaffoldMessenger.showSnackBar` raw, `AlertDialog` raw) e riporta (non bloccante) i conteggi di debito residuo. Verificato manualmente: individua correttamente l'unico `AlertDialog` raw rimasto (`lib/manager/expense/widgets/attachment_input_widget.dart:229`, debito di Fase 2.4). **Non ancora collegato alla CI** — collegamento pianificato in Fase 4.7.
- [x] **Corretto il drift di naming tra la documentazione e il codice reale** in `packages/caravella_core_ui`:
  - `GroupBottomSheetScaffold` rinominato in `CaravellaBottomSheetScaffold` (per coerenza con `CaravellaAppBar`/`CaravellaTabBar`/`CaravellaThemes`) e il file sorgente spostato in `widgets/caravella_bottom_sheet_scaffold.dart`. Aggiornati tutti i 23 file che lo referenziavano in `lib/`, oltre a un import che faceva deep-import invece di passare dal barrel (`lib/manager/group/widgets/period_selection_bottom_sheet.dart`).
  - `.github/copilot-instructions.md` aggiornato: `BottomSheetScaffold` → `CaravellaBottomSheetScaffold`; `SelectionBottomSheet` → `showSelectionBottomSheet<T>()` (chiarito che è una funzione, non una classe widget).
  - `flutter analyze` pulito su `caravella_core_ui` e sull'intero progetto dopo il rename.
- [x] **Uniformato il barrel file**: `BottomActionBar` ora è esportato anche direttamente da `caravella_core_ui.dart` (oltre che da `widgets/widgets.dart`, lasciato invariato per compatibilità), quindi raggiungibile con il solo `import 'package:caravella_core_ui/caravella_core_ui.dart';`.
- [x] **Introdotte costanti condivise per i target di tocco**: `packages/caravella_core_ui/lib/themes/app_dimens.dart` → `AppDimens.minTouchTarget = 48.0`, `AppDimens.minTouchTargetCompact = 44.0`, esportate dal barrel. I 6 file con valori 48/44/42 hardcoded (Fase 4.2) vanno ancora migrati a usare questa costante — non toccati in questa fase per restare a debito zero-rischio.
- [x] **Introdotti colori semantici di stato** (`success`/`warning`) come extension `CaravellaSemanticColors on ColorScheme` in `caravella_themes.dart` (`.success`, `.onSuccess`, `.warning`, `.onWarning`). Valori scelti e verificati manualmente per contrasto WCAG AA (≥4.5:1) contro `surface` in entrambi i temi (es. light warning portato da `#B8860B`, ~3.25:1, a `#9C6D00`, ~4.56:1, per garantire conformità anche se usato su testo). **`error` non aggiunto**: `ColorScheme.error`/`.onError` di Material 3 coprono già quel ruolo, non serve duplicarlo. La migrazione dei consumer esistenti (`lib/sync/settings_sync_badge.dart`, `lib/home/cards/widgets/carousel_group_card.dart`) resta pianificata in Fase 3.2.

---

## Fase 1 — Centralizzare componenti in `caravella_core_ui`

Widget già usati in ≥2 flow app-specific diversi (candidati forti, nessuna logica business da disaccoppiare):

- [x] **`SettingsCard` + `SettingsSection`** promosse in `packages/caravella_core_ui/lib/widgets/settings_card.dart`/`settings_section.dart`, esportate dal barrel. Zero dipendenze app-specific da rimuovere (già solo `flutter/material.dart` + `caravella_core_ui`). Aggiornati i 13 call site in `lib/` (rimossi import locali/deep-import ridondanti, uno di questi — `general_settings_section.dart` — importava già il barrel). `flutter analyze` pulito su `caravella_core_ui` e sul progetto.
- [x] **`ParticipantAvatar` + `ExpenseGroupAvatar`** promosse in `packages/caravella_core_ui/lib/widgets/avatars.dart` (nessuna modifica di API: dipendevano solo da `caravella_core`, ammesso dai confini di package). **`GroupHeader`** (il widget composito nello stesso file originale) **non è stato promosso ma eliminato**: verificato con grep su tutto `lib/`+`test/` che non veniva mai istanziato in nessuna pagina — solo la sua dichiarazione di classe esisteva. File originale `lib/manager/details/widgets/group_header.dart` rimosso; aggiornati 5 call site + 1 test (`test/participant_avatar_test.dart`) che importava il vecchio path.
- [x] **`ExpenseAmountCard`** promossa in `packages/caravella_core_ui/lib/widgets/expense_amount_card.dart`, nessuna modifica di API: dipendeva solo da `flutter`, `timeago` (già dipendenza di `caravella_core_ui`), `caravella_core` — nessun accoppiamento a pagine o provider app-specific. Aggiornati i 4 call site + 1 test (`test/expense_amount_card_decimal_test.dart`).
- [ ] **`GroupCard`** (`lib/home/cards/widgets/group_card.dart`) — **valutato, non promosso**: a differenza degli altri candidati ha due accoppiamenti hard all'app-layer che bloccano la promozione così com'è — (1) naviga internamente a `ExpenseGroupDetailPage` (`Navigator.push` hardcoded dentro `onTap`, non un callback iniettato) e (2) il parametro `localizations` è tipizzato `gen.AppLocalizations`, la classe generata dell'app, che `caravella_core_ui` non può importare per i confini di package. Promuoverlo richiederebbe invertire il controllo sulla navigazione (accettare un `onTap`/`onOpen` esterno) e passare stringhe già risolte invece dell'oggetto `localizations` — un refactor più ampio, non fatto in questa passata per non introdurre rischio senza un piano dedicato.
- [x] Per i 3 componenti effettivamente promossi: nessuna dipendenza da tipi/provider app-specific da rimuovere — verificato caso per caso, non genericamente assunto.

Nuovi componenti condivisi (pattern oggi duplicati tra flow, vedi Fase 2):

- [x] **`EmptyStateView`** creato in `packages/caravella_core_ui/lib/widgets/empty_state_view.dart` (icon + message + hint opzionale, alpha 0.4/0.6 come nell'originale). **Solo 2 delle 5 varianti unificate su questo componente**: `EmptySearchState` (`lib/manager/details/widgets/expense_search_empty_state.dart`) e l'`_buildEmptyState` inline di `lib/home/search/group_search_page.dart` (rimosso, era la duplicazione byte-per-byte più chiara). Le altre 3 — `GroupCardEmptyState`, `EmptyExpenseState`, `ExpenseGroupEmptyStates._buildSimpleEmptyState` — **non sono state toccate**: sono un pattern visivamente più ricco (animazioni, emoji casuali, testo con bold parsing, azione CTA) con valori di stile diversi (icon size 64 vs 48, nessun alpha sull'icona), non lo stesso pattern "icon+message+hint" — forzarle nello stesso componente avrebbe richiesto un'API kitchen-sink invece di una vera unificazione. `NoExpense` (già in core_ui, 0 utilizzi) resta da rivalutare separatamente.
- [ ] **`SearchAppBar`** — non ancora creato. Duplicazione ancora presente tra `home/search/group_search_page.dart:112-125` e `manager/details/pages/expense_search_page.dart:292-305`.
- [ ] **`FlatAppBar`** — non ancora creato. Duplicazione ancora presente tra `settings/pages/data_backup_page.dart:26-28` e `developer_page.dart:104-106`.

---

## Fase 2 — Eliminare duplicazioni / reimplementazioni

- [ ] **2.1 Empty states**: `EmptyStateView` creato in Fase 1. Delle 5 implementazioni:
  - [x] `lib/manager/details/widgets/expense_search_empty_state.dart` (`EmptySearchState`) — migrato su `EmptyStateView`.
  - [x] `lib/home/search/group_search_page.dart` — `_buildEmptyState(...)` inline (era quasi identico a `EmptySearchState`, la duplicazione byte-per-byte più chiara) rimosso e sostituito da `EmptyStateView` diretto.
  - [x] `lib/manager/history/widgets/expense_group_empty_states.dart` → **typo corretto**: `ExpsenseGroupEmptyStates` → `ExpenseGroupEmptyStates` (aggiornato anche l'unico call site, `lib/manager/history/expenses_history_page.dart:186`). **Non unificato** su `EmptyStateView`: il suo `_buildSimpleEmptyState` ha valori di stile diversi (icon size 64 senza alpha, non 48 con alpha 0.4) — vedi nota in Fase 1.
  - `lib/home/cards/widgets/group_card_empty_state.dart` (`GroupCardEmptyState`) — **non unificabile**: pattern animato con emoji casuale e bold-text parsing, non "icon+message+hint". Lasciato invariato.
  - `lib/manager/details/widgets/empty_expense_state.dart` (`EmptyExpenseState`) — wrappa `GroupCardEmptyState` + CTA, stesso motivo di sopra. Lasciato invariato.
- [ ] **2.2 Card che reimplementano lo stile `BaseCard`**:
  - `lib/manager/details/widgets/stat_card.dart` (`StatCard`, `InfoCard`) — **non rifattorizzato**: hanno un bordo *sempre* presente ad alpha 0.2, mentre `BaseCard` di default non disegna bordo (lo fa solo con `isFlat: false`, e ad alpha 0.12). Migrarle su `BaseCard` oggi cambierebbe visibilmente lo stile (bordo più tenue) o richiederebbe estendere l'API di `BaseCard` con un parametro di alpha del bordo — rimandato a Fase 3 (dove si sceglie l'alpha canonico), per non introdurre un cambiamento visivo silenzioso. Sono comunque single-flow (solo `manager/details/pages/tabs/*`), priorità più bassa rispetto ai candidati di Fase 1.
  - [x] `lib/home/cards/widgets/new_group_card.dart` (`NewGroupCard`) — rifattorizzato su `BaseCard` (stesso `backgroundColor` via `Color.lerp`, stesso `margin`, stesso `onTap`): comportamento verificato identico, nessun parametro nuovo servito. `flutter analyze` pulito.
- [x] **2.3 Bottom sheet**: `lib/manager/group/widgets/unsplash_photo_widgets.dart` (`PhotoPreviewSheet`) migrato da handle-bar manuale a `CaravellaBottomSheetScaffold` (che ora fornisce anche l'handle). Era l'unico caso residuo su 21 bottom sheet.
- [x] **2.4 Dialog**: `lib/manager/expense/widgets/attachment_input_widget.dart` (`_showCameraMediaTypePicker`) migrato da `AlertDialog` raw a `Material3Dialog` + `Material3DialogActions.cancel`. Era l'unico caso residuo su 10 — verificato anche da `validate_accessibility.sh`, che ora riporta zero occorrenze.
- [ ] **2.5 AppBar**: dopo aver introdotto `SearchAppBar`/`FlatAppBar` (Fase 1), migrare i 16 file con `AppBar(` raw dove applicabile. Nota: `expense_group_detail_page.dart:499` usa `SliverAppBar`, legittimamente diverso — non forzare la migrazione lì.
- [ ] **2.6 FAB**: `lib/manager/expense/pages/place_search_page.dart:132` è un FAB semanticamente diverso (icona `my_location`, non "add"). Non serve fix ora — monitorare se il pattern si ripete altrove prima di creare un secondo componente FAB condiviso.

---

## Fase 3 — Uniformità del Design System

- [ ] **3.1 `AppTextStyles`**: solo 2 usi in tutto `lib/` a fronte di decine di `TextStyle(` inline sparsi nelle pagine. Fare un audit mirato delle pagine più visibili (home, dettaglio gruppo, form spesa) e sostituire gli stili inline con gli helper esistenti (`sectionTitle`, `listItem`, `listItemStrong`, `subtle`), estendendo il set di helper se emergono pattern ricorrenti non coperti.
- [ ] **3.2 Colori semantici di stato**: unificare i due sistemi di colore per lo stato "sincronizzato/in attesa":
  - `lib/sync/settings_sync_badge.dart:18-19` → `greenColor = Color(0xFF2E7D32)`, `ochreColor = Color(0xFFB8860B)` hardcoded, non theme-aware.
  - `lib/home/cards/widgets/carousel_group_card.dart:86-87` → `Colors.green`/`Colors.amber` per lo stesso concetto.
  - Sostituire entrambi con i colori semantici introdotti in Fase 0 (`CaravellaThemes.success`/`.warning`), verificati per contrasto in light e dark.
- [ ] **3.3 `CaravellaAppBar` senza `title`**: la scelta di design attuale (header "senza titolo") è legittima per schermate home-like, ma non è documentata come tale — aggiungere un commento/doc nel widget e in `docs/` che chiarisca quando usare `CaravellaAppBar` vs le nuove `FlatAppBar`/`SearchAppBar` (Fase 1), per evitare che si ripeta la confusione vista nell'analisi.
- [ ] **3.4 `form_theme.dart`**: nessuna delle 5 factory di `InputDecoration` (`getStandardDecoration`, `getMultilineDecoration`, `getBorderlessDecoration`, `getBorderlessAmountDecoration`, `getSearchPillDecoration`) accetta `labelText` — solo `hintText`. Estendere ciascuna factory con un parametro `labelText` opzionale (vedi anche Fase 4.4, è anche un requisito WCAG).

---

## Fase 4 — Accessibilità WCAG 2.2

### 4.1 Semantics su elementi interattivi (SC 2.4.4, 4.1.2)
- [ ] Aggiungere `tooltip`/`semanticLabel` ai 13 `IconButton` privi di label individuati, tra cui:
  - `lib/settings/pages/group_type_templates_page.dart:52` (edit)
  - `lib/home/search/group_search_page.dart:134-142` (clear)
  - `lib/manager/group/pages/unsplash_search_page.dart:179` (clear)
  - `lib/manager/group/widgets/period_selection_bottom_sheet.dart:98,115` (prev/next mese)
  - `lib/manager/details/pages/expense_group_detail_page.dart:533` (back custom)
  - `lib/sync/qr_pair_scan_page.dart:85` (back custom)
  - Usare come riferimento il pattern già corretto in `lib/manager/expense/location/widgets/compact_location_indicator.dart:48-66` (`Semantics(button: true, label:...)` + `tooltip`).
- [ ] **`BaseCard`** (`packages/caravella_core_ui/lib/widgets/base_card.dart`): aggiungere parametro `semanticLabel` opzionale e avvolgere il ramo tappable in `Semantics(button: true, label: ...)`/`MergeSemantics` così che titolo+saldo+immagine vengano annunciati come un unico nodo. Applicare a cascata ai call site principali (`group_card.dart`, `expense_amount_card.dart`, `settings_card.dart`, `swipeable_expense_group_card.dart`).
- [ ] Introdurre uso di `MergeSemantics` (oggi 0 occorrenze) per le card composte da più `Text` (nome gruppo + saldo + participanti), così lo screen reader annuncia un blocco coerente invece di frammenti separati.

### 4.2 Target di tocco (SC 2.5.8)
- [ ] `lib/manager/expense/widgets/category_selector_widget.dart:70` — rimuovere `minimumSize: Size.zero` / `tapTargetSize: MaterialTapTargetSize.shrinkWrap`, riportare al minimo condiviso (Fase 0).
- [ ] `lib/manager/expense/widgets/participant_selector_widget.dart:73` — stesso fix.
- [ ] `lib/manager/details/pages/tabs/participants_overview_tab.dart:340,363` — pulsanti "More"/"Less" inline, portare almeno a 24x24 (idealmente 44x44 con padding).
- [ ] `lib/manager/group/widgets/editable_name_list.dart:162,175` — da 42x42 al target consigliato 44-48.
- [ ] `lib/manager/expense/pages/place_search_page.dart:251-252` — da 40x40 al target consigliato.
- [ ] Dopo i fix puntuali, sostituire ovunque i valori hardcoded con la costante condivisa introdotta in Fase 0, per evitare nuova deriva.

### 4.3 Contrasto colori (SC 1.4.3 / 1.4.11)
- [ ] Costruire un piccolo tool/test di calcolo del rapporto di contrasto reale (luminanza relativa WCAG), da usare sia come test automatico sia come check manuale — oggi il test esistente (`test/accessibility_test.dart:205-212`) verifica solo `onSurface != surface`, non un rapporto numerico.
- [ ] Verificare e correggere i cluster a rischio individuati:
  - `lib/manager/expense/pages/viewers/video_player_page.dart:87,91,96` — `Colors.white54` su nero.
  - `lib/manager/expense/pages/attachment_viewer_page.dart:119,124` — `Colors.white70`/`white54`.
  - `lib/sync/qr_pair_scan_page.dart:96,104` — `Colors.black54` su overlay fotocamera.
- [ ] Dopo la Fase 3.2, verificare il contrasto dei nuovi colori semantici `success`/`warning` in entrambi i temi.

### 4.4 Form accessibili (SC 3.3.1, 3.3.2)
- [ ] Estendere `form_theme.dart` con `labelText` (Fase 3.4), poi applicare ai campi oggi solo-hint:
  - `lib/manager/expense/widgets/amount_input_widget.dart:53,126` (importo)
  - `lib/manager/expense/widgets/note_input_widget.dart:34` (nota)
  - `lib/manager/group/widgets/group_title_field.dart:84` (titolo gruppo)
  - `lib/manager/group/wizard/wizard_steps/wizard_user_name_step.dart:94-95`, `wizard_type_and_name_step.dart:50,103` (wizard)
  - Usare come riferimento il pattern già corretto in `lib/manager/expense/widgets/category_dialog.dart:41-49` (`Semantics(textField:true, label:...)` + `labelText`).
- [ ] Estendere l'uso di `errorText` (oggi solo 2 occorrenze) ai form principali (importo, nome gruppo, note, categoria), collegato a `Semantics`/annuncio screen reader degli errori di validazione.

### 4.5 Focus e navigazione da tastiera (SC 2.4.3, 2.1.1)
- [ ] Introdurre `FocusTraversalGroup` con ordine esplicito nelle schermate complesse dove l'ordine implicito è più a rischio: wizard multi-step (`manager/group/wizard/`), form spesa con allegati/categoria/partecipanti (`manager/expense/pages/expense_form_page.dart`). Rilevante perché l'app supporta anche macOS/Windows/Web, non solo mobile.
- [ ] Rivedere i 7 punti con `autofocus: true` per conflitti di focus-trapping quando combinati con un futuro `FocusTraversalGroup`.

### 4.6 Localizzazione delle stringhe di accessibilità
- [ ] `lib/manager/expense/widgets/category_dialog.dart:63,72` — sostituire `'${gloc.cancel} dialog'` / `'${gloc.add} category'` con chiavi `AppLocalizations` dedicate e completamente tradotte.
- [ ] `lib/manager/expense/location/widgets/compact_location_indicator.dart:52` — spostare `'Double tap to cancel location retrieval'` (hardcoded EN) in `AppLocalizations`.
- [ ] Fare un secondo passaggio di ricerca su tutti i `label:`/`hint:`/`semanticLabel:` del repo per individuare eventuali altri casi non emersi nell'analisi iniziale (l'audit ha coperto i pattern più comuni ma non è exhaustive).

### 4.7 Test e gate CI
- [ ] Estendere `test/accessibility_localization_test.dart` oltre ai 3 widget attuali (`AddFab`, `CaravellaAppBar`, `AppToast`) per coprire almeno i nuovi/promossi componenti condivisi di core_ui.
- [ ] Sostituire il test di "contrasto" fittizio in `test/accessibility_test.dart:205-212` con un test che usi il calcolo di rapporto di contrasto reale (Fase 4.3).
- [ ] Aggiungere test di target di tocco per i componenti condivisi promossi in Fase 1/2.
- [ ] Ricollegare lo script ricreato (Fase 0) al workflow CI (`.github/workflows/Development - Android.yml`) come step dopo `flutter analyze`.

---

## Ordine di esecuzione consigliato

1. **Fase 0** (fondamenta) — sblocca tutto il resto, basso rischio, alto valore.
2. **Fase 2** (fix isolate a basso rischio: bottom sheet, dialog, empty-state duplicati, typo `ExpsenseGroupEmptyStates`) — quick win, nessuna nuova API.
3. **Fase 1** (promozione componenti in core_ui) — richiede più coordinamento (import path, dipendenze da provider) ma sblocca la Fase 2 rimanente (AppBar) e riduce superficie per la Fase 4.
4. **Fase 3** (uniformità DS: colori semantici, `AppTextStyles`, `form_theme` labelText) — propedeutica alla Fase 4.
5. **Fase 4** (accessibilità WCAG 2.2) — la più corposa, va fatta widget condiviso per widget condiviso (core_ui) prima, poi a cascata sui call site in `lib/`.

Aggiornare `CHANGELOG.md [Unreleased]` per ogni cambiamento visibile, come da convenzione del progetto, e rieseguire `flutter analyze` + `flutter test` (inclusi i test di accessibilità mirati) dopo ogni fase.
