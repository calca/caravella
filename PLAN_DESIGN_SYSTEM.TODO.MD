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
- [x] **`SearchAppBar`** creato in `packages/caravella_core_ui/lib/widgets/search_app_bar.dart` (wraps `FormTheme.getGmailAppBarSearchBackground`/`getSearchPillDecoration`, già esistenti). Sostituisce la duplicazione tra `home/search/group_search_page.dart` e `manager/details/pages/expense_search_page.dart` — comportamento identico (stesso `SystemUiOverlayStyle` dinamico su `isDark`, stesso `suffixIcon` per-caller), differenze di `hintText`/`onChanged`/`suffixIcon` passate come parametri.
- [x] **`FlatAppBar` non creato — non serviva**: verificando `CaravellaAppBar` da vicino, i suoi default (`elevation:0`, `foregroundColor: onSurface`, nessun titolo, `backgroundColor` di default = `scaffoldBackgroundColor`, che in `CaravellaThemes` **è** `colorScheme.surface`) producono esattamente lo stesso output visivo del pattern duplicato, con in più semantica di accessibilità (`Semantics(header: true)`) che il codice duplicato non aveva. Creare un secondo componente sarebbe stata pura duplicazione interna a core_ui. Usato `CaravellaAppBar` direttamente in `data_backup_page.dart`, `developer_page.dart` **e** in un terzo caso trovato durante la migrazione, `unified_overview_page.dart:157` (`AppBar()` vuoto — stesso pattern "flat, senza titolo", non individuato nell'audit iniziale). Vedi nota in Fase 3.3: la documentazione va aggiornata per chiarire questo quando usare `CaravellaAppBar`.

---

## Fase 2 — Eliminare duplicazioni / reimplementazioni

- [ ] **2.1 Empty states**: `EmptyStateView` creato in Fase 1. Delle 5 implementazioni:
  - [x] `lib/manager/details/widgets/expense_search_empty_state.dart` (`EmptySearchState`) — migrato su `EmptyStateView`.
  - [x] `lib/home/search/group_search_page.dart` — `_buildEmptyState(...)` inline (era quasi identico a `EmptySearchState`, la duplicazione byte-per-byte più chiara) rimosso e sostituito da `EmptyStateView` diretto.
  - [x] `lib/manager/history/widgets/expense_group_empty_states.dart` → **typo corretto**: `ExpsenseGroupEmptyStates` → `ExpenseGroupEmptyStates` (aggiornato anche l'unico call site, `lib/manager/history/expenses_history_page.dart:186`). **Non unificato** su `EmptyStateView`: il suo `_buildSimpleEmptyState` ha valori di stile diversi (icon size 64 senza alpha, non 48 con alpha 0.4) — vedi nota in Fase 1.
  - `lib/home/cards/widgets/group_card_empty_state.dart` (`GroupCardEmptyState`) — **non unificabile**: pattern animato con emoji casuale e bold-text parsing, non "icon+message+hint". Lasciato invariato.
  - `lib/manager/details/widgets/empty_expense_state.dart` (`EmptyExpenseState`) — wrappa `GroupCardEmptyState` + CTA, stesso motivo di sopra. Lasciato invariato.
- [x] **2.2 Card che reimplementano lo stile `BaseCard`**:
  - [x] `lib/manager/details/widgets/stat_card.dart` (`StatCard`, `InfoCard`) — **rifattorizzate in Fase 3** (vedi 3.2bis sotto): l'alpha 0.2 del bordo era un'anomalia isolata (l'unico altro punto dell'app che disegna un bordo su `BaseCard`, `home/cards/widgets/group_card.dart`, usa già l'alpha 0.12 di default via `isFlat: false`). Deciso 0.12 come canonico e migrate entrambe le classi su `BaseCard(isFlat: false, backgroundColor: ..., padding: ...)`, eliminando la `Container`/`BoxDecoration` duplicata. Bordo leggermente più tenue rispetto a prima — cambiamento visivo intenzionale e minimo, per coerenza col resto dell'app.
  - [x] `lib/home/cards/widgets/new_group_card.dart` (`NewGroupCard`) — rifattorizzato su `BaseCard` (stesso `backgroundColor` via `Color.lerp`, stesso `margin`, stesso `onTap`): comportamento verificato identico, nessun parametro nuovo servito. `flutter analyze` pulito.
- [x] **2.3 Bottom sheet**: `lib/manager/group/widgets/unsplash_photo_widgets.dart` (`PhotoPreviewSheet`) migrato da handle-bar manuale a `CaravellaBottomSheetScaffold` (che ora fornisce anche l'handle). Era l'unico caso residuo su 21 bottom sheet.
- [x] **2.4 Dialog**: `lib/manager/expense/widgets/attachment_input_widget.dart` (`_showCameraMediaTypePicker`) migrato da `AlertDialog` raw a `Material3Dialog` + `Material3DialogActions.cancel`. Era l'unico caso residuo su 10 — verificato anche da `validate_accessibility.sh`, che ora riporta zero occorrenze.
- [x] **2.5 AppBar**: dei 16 file con `AppBar(` raw, migrati i 5 che erano effettivamente "flat, senza titolo" o search: `data_backup_page.dart`, `developer_page.dart`, `unified_overview_page.dart` → `CaravellaAppBar`; `group_search_page.dart`, `expense_search_page.dart` → `SearchAppBar`. Verificati singolarmente gli altri 11 (`group_settings_page.dart`, `attachment_viewer_page.dart`, `expense_form_page.dart`, `group_creation_wizard_page.dart`, `image_crop_page.dart`, `appearance_settings_page.dart`, `group_type_template_form_page.dart`, `group_type_templates_page.dart`, `qr_pair_scan_page.dart`, `expense_locations_map_page.dart`): hanno tutti un `title:` esplicito, incompatibile con `CaravellaAppBar` (che forza `title: null` per design) — **lasciati correttamente `AppBar` raw**, non è debito. `expense_group_detail_page.dart:499` usa `SliverAppBar`, legittimamente diverso.
- [ ] **2.6 FAB**: `lib/manager/expense/pages/place_search_page.dart:132` è un FAB semanticamente diverso (icona `my_location`, non "add"). Non serve fix ora — monitorare se il pattern si ripete altrove prima di creare un secondo componente FAB condiviso.

---

## Fase 3 — Uniformità del Design System

- [x] **3.1 `AppTextStyles`**: fatto un audit *esatto* (non euristico) su tutto `lib/`, cercando pattern multilinea byte-identici alle 4 definizioni di `AppTextStyles` con uno script perl, per azzerare il rischio di derive visive. Trovati e migrati:
  - 3 occorrenze di `bodyMedium?.copyWith(fontWeight: FontWeight.w600)` in `lib/manager/details/widgets/stat_card.dart` → `AppTextStyles.listItemStrong(context)`.
  - 6 occorrenze di `bodyMedium?.copyWith(color: ...onSurfaceVariant)` → `AppTextStyles.subtle(context)`, in `lib/manager/group/wizard/wizard_steps/wizard_user_name_step.dart`, `wizard_completion_step.dart`, `lib/manager/group/pages/unsplash_search_page.dart`, `lib/home/cards/widgets/new_group_card.dart` (richiesto passare `context` a `_buildNewGroupCardContent`, prima non lo prendeva), `lib/home/cards/widgets/empty_groups_state.dart`.
  - **Escluso un falso positivo**: `lib/settings/pages/appearance_settings_page.dart:134-135` usa un colore condizionale (`selected ? onSurface : onSurfaceVariant`), non equivalente a `subtle` (sempre `onSurfaceVariant`) — lasciato invariato.
  - **Non esteso il set di helper**: nessun pattern ricorrente-ma-non-coperto è emerso abbastanza spesso da giustificare un nuovo helper; l'audit sui match esatti tiene comunque la porta aperta per futuri pattern via analisi euristica (più lenta, più rischiosa, non fatta qui).
- [x] **3.2 Colori semantici di stato**: entrambi i sistemi di colore migrati su `CaravellaThemes.success`/`.warning` (Fase 0):
  - `lib/sync/settings_sync_badge.dart` → rimossi `greenColor`/`ochreColor` hardcoded dal mixin, sostituiti con `colorScheme.success`/`.warning` in entrambi i punti di utilizzo (`SettingsSyncBadge`, `SyncStatusIcon`).
  - `lib/home/cards/widgets/carousel_group_card.dart:86-87` → `Colors.green`/`Colors.amber` sostituiti con `theme.colorScheme.success`/`.warning`.
  - **Nota emersa, non risolta (fuori scope Fase 1-3)**: lo stesso file (`carousel_group_card.dart:78-79`) ha una stringa `Semantics(label: ...)` hardcoded in inglese (`'Shared group, synced'`/`'Shared group, not synced'`) invece di passare per `AppLocalizations` — è debito di Fase 4.6, aggiunto lì.
- [x] **3.3 `CaravellaAppBar` senza `title`**: aggiunto un doc comment sulla classe (`packages/caravella_core_ui/lib/widgets/caravella_app_bar.dart`) che spiega l'intento di design e rimanda a `SearchAppBar` per i casi di ricerca. Aggiornato anche `docs/PACKAGE_CARAVELLA_CORE_UI.md` (era già stale su più fronti — nome vecchio `GroupBottomSheetScaffold`, mancavano tutti i widget promossi in Fase 1/2: `SettingsCard`, `SettingsSection`, `ParticipantAvatar`, `ExpenseGroupAvatar`, `ExpenseAmountCard`, `EmptyStateView`, `SearchAppBar`, `AppDimens`, `CaravellaSemanticColors`, il supporto `labelText` di `FormTheme` — tutti aggiunti alla tabella/descrizione).
- [x] **3.4 `form_theme.dart`**: aggiunto `labelText` opzionale a `getStandardDecoration`, `getMultilineDecoration`, `getBorderlessDecoration` (le 3 factory general-purpose). **Non aggiunto** a `getBorderlessAmountDecoration` (pensata per un numero enorme senza bordo, un `labelText` persistente romperebbe il layout) né a `getSearchPillDecoration` (campo di ricerca compatto, stesso motivo) — per queste due l'hint-only resta una scelta di design, non un buco. La migrazione dei call site esistenti (Fase 4.4: `amount_input_widget.dart`, `note_input_widget.dart`, `group_title_field.dart`, i due step del wizard) non è stata fatta qui, resta pianificata in Fase 4.
- [ ] **3.4 `form_theme.dart`**: nessuna delle 5 factory di `InputDecoration` (`getStandardDecoration`, `getMultilineDecoration`, `getBorderlessDecoration`, `getBorderlessAmountDecoration`, `getSearchPillDecoration`) accetta `labelText` — solo `hintText`. Estendere ciascuna factory con un parametro `labelText` opzionale (vedi anche Fase 4.4, è anche un requisito WCAG).

---

## Fase 4 — Accessibilità WCAG 2.2

### 4.1 Semantics su elementi interattivi (SC 2.4.4, 4.1.2) — ✅ completata
- [x] Aggiunto `tooltip`/`semanticLabel` ai 6 `IconButton` individuati, più **un settimo trovato durante la Fase 4.5** (`expense_form_page.dart` back button):
  - `group_type_templates_page.dart` (edit/delete) — chiavi l10n già esistenti (`settings_group_templates_edit_title`/`delete_title`).
  - `group_search_page.dart` + `expense_search_page.dart` (clear) — `gloc.clear`.
  - `unsplash_search_page.dart` (clear) — `loc.clear`.
  - `period_selection_bottom_sheet.dart` (prev/next mese) — nuove chiavi `accessibility_previous_month`/`accessibility_next_month`, tradotte in tutte e 5 le lingue.
  - `expense_group_detail_page.dart`, `qr_pair_scan_page.dart`, `expense_form_page.dart` (back custom, il terzo trovato in corsa) — riusano `accessibility_back_button` già esistente.
- [x] **`BaseCard`**: aggiunto `semanticLabel` opzionale + wrapping del ramo tappable in `Semantics(button:true)`. Con `semanticLabel` → `ExcludeSemantics` (evita doppio annuncio); senza → `MergeSemantics` (unisce i `Text` figli in un unico annuncio, senza bisogno di una label duplicata da mantenere manualmente). Si applica automaticamente a ogni chiamante che già passa `onTap` a `BaseCard` (es. `group_card.dart`, zero modifiche al call site). `expense_amount_card.dart` e `swipeable_expense_group_card.dart` gestiscono il tap tramite un `InkWell` proprio (non il parametro `onTap` di `BaseCard`) — stesso pattern `Semantics`/`MergeSemantics` applicato manualmente lì.
- [x] `MergeSemantics` introdotto (0 → 3 occorrenze), verificato dal regression report di `validate_accessibility.sh`.

### 4.2 Target di tocco (SC 2.5.8) — ✅ completata
- [x] `category_selector_widget.dart` / `participant_selector_widget.dart` — rimosso `Size.zero`/`shrinkWrap`, sostituito con `AppDimens.minTouchTargetCompact`.
- [x] `participants_overview_tab.dart` — pulsanti "More"/"Less" **inline in un `WidgetSpan`** (non possono prendere 44x44 senza rompere il paragrafo): introdotta una terza costante, `AppDimens.minTouchTargetInline = 24.0` (il floor WCAG), invece di `Size.zero`.
- [x] `editable_name_list.dart` — 42x42 → `AppDimens.minTouchTargetCompact` (44x44).
- [x] `place_search_page.dart` — marker mappa 40x40 → hit-box `AppDimens.minTouchTargetCompact`, icona visiva invariata (40, centrata).
- [x] **Trovato durante la Fase 4.6**: `compact_location_indicator.dart` aveva anch'esso `minimumSize: Size(40,40)`, non nell'audit iniziale — corretto allo stesso modo.
- [x] Tutti i fix usano le costanti condivise di Fase 0, nessun valore hardcoded residuo nei punti corretti.

### 4.3 Contrasto colori (SC 1.4.3 / 1.4.11) — ✅ completata
- [x] Creato `ContrastUtils` (`packages/caravella_core_ui/lib/utils/contrast.dart`): luminanza relativa + rapporto di contrasto secondo la formula WCAG, con alpha-compositing corretto per i colori traslucidi (prima versione ignorava l'alpha e restituiva sempre 21:1 — scoperto e corretto confrontando con calcoli manuali prima di fidarsene).
- [x] Rimisurati i 3 cluster segnalati come "a rischio": **tutti falsi positivi**, già conformi sui loro sfondi reali — `white54`/`white70` su nero pieno: 6.1:1/10:1 (soglia AA normale 4.5); lo scrim `black54` di `qr_pair_scan_page.dart` è dietro testo bianco *opaco* (non è il testo stesso a essere traslucido) e supera 4.6:1 anche nel caso peggiore (fotogramma camera bianco). Nessuna modifica al codice sorgente per questi tre — solo il tool, che ora è anche collegato al nuovo test reale (Fase 4.7).
- [x] Colori semantici `success`/`warning` di Fase 3.2 rimisurati con lo stesso tool: tutti conformi (5.1–11.8:1 a seconda del tema/ruolo).
- [x] **Trovato durante il collegamento al test reale**: `onPrimary` su `primary` in tema chiaro è 3.67:1 — sotto la soglia 4.5 per testo normale, ma sopra 3.0 (testo grande/componente UI), che è la soglia corretta per questo caso (usato per icone come `AddFab` e per label di bottoni bold 14sp). Non è un bug del colore, era un limite troppo severo nel nuovo test — corretto lì, non nel tema.

### 4.4 Form accessibili (SC 3.3.1, 3.3.2) — ✅ completata
- [x] `note_input_widget.dart` — il campo non aveva **alcun** nome accessibile (il `semanticsLabel` di `IconLeadingField` etichetta solo l'icona decorativa, non il `TextFormField`): aggiunto `Semantics(textField:true, label:...)` + `labelText` visibile.
- [x] `group_title_field.dart` — stesso gap, stesso fix (widget condiviso da wizard e pagina impostazioni gruppo, un solo fix copre entrambi i call site).
- [x] `wizard_user_name_step.dart` — trovata una chiave `wizard_user_name_label` ("Your name (optional)") già tradotta ma mai usata: agganciata come `labelText` + `Semantics label`, al posto del solo hint-esempio "e.g. Alex".
- [x] `wizard_type_and_name_step.dart` — messaggio di validazione "inserisci un titolo" spostato da `Text` sibling (invisibile allo screen reader sul campo) a `errorText` nativo del field, stessa condizione di visibilità di prima.
- [x] `amount_input_widget.dart` e `category_selector_widget.dart` **intenzionalmente non toccati** qui: il campo importo ha già un `Semantics(textField:true, label:...)` funzionante e il suo `validator` passa già per un vero `Form`/`GlobalKey<FormState>` (errori già accessibili di serie); categoria non ha alcuna regola di validazione oggi (selezione nullable, nessun vincolo) quindi non c'è uno stato di errore da collegare senza cambiare il comportamento del prodotto.

### 4.5 Focus e navigazione da tastiera (SC 2.4.3, 2.1.1) — ✅ completata
- [x] `group_creation_wizard_page.dart` — il `PageView` (non `.builder`) costruisce tutti gli step eagerly anche se ne mostra uno solo: un utente da tastiera/desktop potrebbe tabbare dentro i campi di uno step nascosto. Ogni step ora è avvolto in `ExcludeFocus(excluding: <non è lo step corrente>)` + un proprio `FocusTraversalGroup`.
- [x] `expense_form_page.dart` — corpo del form avvolto in `FocusTraversalGroup`, per rendere esplicito (invece che implicito) l'ordine di tab su allegati/categoria/partecipanti.
- [x] Rivisti tutti i 7 punti `autofocus: true`: nessuno è discendente delle due aree appena delimitate (vivono in bottom sheet/pagine separate — `category_dialog`, sheet di selezione valuta/periodo, le pagine dedicate di editing partecipanti/categorie) — nessun conflitto di focus-trapping da risolvere.

### 4.6 Localizzazione delle stringhe di accessibilità (SC 3.1.2 di fatto) — ✅ completata
- [x] `category_dialog.dart` — rimossi (non tradotti) i due `Semantics(label: '${gloc.cancel} dialog'/'${gloc.add} category')`: sovrascrivevano l'etichetta automatica e corretta del bottone (già il suo stesso `Text` localizzato) con una peggiore, mezza in inglese. Cancellarli è stato il fix giusto, non tradurli.
- [x] `compact_location_indicator.dart` — hint hardcoded EN sostituito da una nuova chiave `accessibility_cancel_location_hint`, tradotta in tutte e 5 le lingue.
- [x] `carousel_group_card.dart` — `'Shared group, synced'`/`'...not synced'` hardcoded sostituiti componendo chiavi **già esistenti** (`sync_group_shared` + `sync_group_synced`/`sync_group_pending`), usate altrove per lo stesso identico stato — non servivano chiavi nuove.
- [x] `amount_input_widget.dart` (Fase 4.4) — label ridondante/parzialmente EN (`"$label amount in $currencySymbol"`, fallback `"Amount input"`) semplificata a `'$label ($currencySymbol)'`, riusando `gloc.amount` per il fallback.
- [x] `swipeable_expense_group_card.dart` (Fase 4.1) — `'$count partecipanti'` hardcoded in italiano *a prescindere dalla lingua dell'app* sostituito dalla chiave pluralizzata già esistente `participant_count`.
- [x] Secondo passaggio di ricerca su tutto `lib/` (`label:`/`hint:`/`tooltip:`/`semanticLabel:` con stringa letterale): nessun altro caso trovato — i restanti `tooltip:`/`hint:` inoltrano tutti un valore fornito dal chiamante, già verificato localizzato in un campione.
- [x] **Effetto collaterale sistemato**: `test/amount_input_simplified_test.dart` montava `AmountInputWidget` senza `localizationsDelegates` (non ne aveva mai avuto bisogno prima) — aggiornato allo stesso pattern già usato dai test analoghi.

### 4.7 Test e gate CI — ✅ completata
- [x] `test/accessibility_localization_test.dart`: aggiunte 2 nuove chiavi l10n (previous/next month, cancel-location-hint) ai 3 test EN/IT/ES di "Localization Key Validation" esistenti, più 2 nuovi test dedicati al comportamento semantico di `BaseCard` (con/senza `semanticLabel`).
- [x] `test/accessibility_test.dart`: il test di "contrasto" fittizio (verificava solo `onSurface != surface`) sostituito con un test che usa `ContrastUtils` su entrambi i temi e 4 coppie colore reali — ha **trovato un vero problema di soglia** durante la scrittura (vedi 4.3).
- [x] Aggiunti 2 test di target di tocco: uno di contratto sulle costanti `AppDimens` (48/44/24), uno che misura il bottone renderizzato di `BottomActionBar` (componente condiviso) contro `AppDimens.minTouchTarget`.
- [x] `validate_accessibility.sh` collegato al workflow CI (`.github/workflows/Development - Android.yml`) come step `Accessibility regression guard` dopo `Analyze`, con `--skip-tests` per non duplicare `flutter test --coverage` che gira subito dopo. **Bug trovato e corretto nello script stesso** in questo passaggio: `report_count` passava due path come un'unica stringa a `grep -rl`, che quindi non trovava mai nulla in uno dei due (il conteggio "MergeSemantics in uso" risultava sempre 0 anche dopo averne aggiunte 3 occorrenze) — corretto a path multipli veri.

Suite finale: `flutter analyze` pulito, `flutter test` **708 test** (704 + 4 nuovi), tutti verdi.

---

## Ordine di esecuzione consigliato

1. ~~**Fase 0** (fondamenta)~~ — **completata**.
2. ~~**Fase 2** (fix isolate a basso rischio)~~ — **completata** (2.1 parzialmente: 2 empty-state su 5 unificate, le altre 3 deliberatamente escluse per pattern diverso; 2.6 nessuna azione necessaria).
3. ~~**Fase 1** (promozione componenti in core_ui)~~ — **completata**, tranne `GroupCard` (valutato, non promosso: richiede inversione di controllo sulla navigazione, rimandato come task a sé).
4. ~~**Fase 3** (uniformità DS)~~ — **completata**.
5. ~~**Fase 4** (accessibilità WCAG 2.2)~~ — **completata** (4.1–4.7 tutte chiuse). Trovati e corretti 4 problemi non presenti nell'audit iniziale mentre si lavorava sul resto (un terzo back-button senza tooltip, un target di tocco 40x40, un bug nello script di regressione, una soglia di contrasto del test troppo severa) — segnale che vale la pena tenere gli occhi aperti anche fuori dalla lista, non solo eseguirla meccanicamente.

Verificato dopo ogni fase: `flutter analyze` pulito, `flutter test` (708 test, tutti verdi — 704 + 4 aggiunti in Fase 4.7). Nessuna voce di cambiamento in `CHANGELOG.md`: tutte le modifiche fin qui sono interne (rename, promozione componenti, refactor a parità di comportamento, fix di accessibilità senza impatto sul flusso prodotto) senza rilevanza per l'utente finale in termini di nuove funzionalità.

**Verifica visiva manuale**: tentata sull'emulatore Android (`flutter run --flavor dev`), confermata solo parzialmente. La home page si è renderizzata correttamente (card gruppo, pill "Condiviso", empty-state animato), ma la navigazione a Impostazioni/Ricerca — le schermate con più modifiche di questa sessione (`SearchAppBar`, `CaravellaAppBar`, `StatCard`) — è stata bloccata da ANR ricorrenti del servizio `GeolocatorLocationService`. Confermato **pre-esistente e non causato da queste modifiche**: file di trace ANR (`/data/anr/`) presenti anche da sessioni precedenti allo stesso giorno (09:49, 14:04), prima di qualunque modifica di questa conversazione. Verifica UI completa quindi non effettuata oltre la home; solo `flutter analyze`/`flutter test` fanno da rete di sicurezza per le schermate non raggiunte.
