# Piano di riduzione del debito tecnico — Caravella

Data: 2026-07-14

## Baseline: cosa NON è debito

- `flutter analyze` pulito, 0 warning.
- Zero uso di API deprecate (es. `withOpacity` già migrato ovunque).
- Dipendenze quasi tutte aggiornate (solo patch minori: `intl` 0.20.2→0.20.3, `talker_flutter`→5.1.18, `video_player`→2.13.0).
- Pochi TODO/FIXME reali nel codice.

Il debito non è diffuso: è concentrato in punti specifici e individuabili, elencati sotto per priorità.

## P0 — Quick win (poche ore, rischio basso) — ✅ completato 2026-07-14

1. **Violazione convenzione AppToast**: 8 punti chiamano `ScaffoldMessenger.of(context).showSnackBar` direttamente invece del componente condiviso `AppToast`, come richiesto da `copilot-instructions.md`:
   - `lib/home/cards/widgets/group_card_voice_button.dart:285`
   - `lib/manager/expense/components/expense_form_component.dart:563,581,600,611,623` (5 occorrenze)
   - `lib/manager/expense/widgets/voice_input_button.dart:99`
   - `lib/manager/group/wizard/wizard_navigation_bar.dart:250`
   - `lib/manager/details/pages/group_settings_page.dart:333`
   - `lib/manager/history/widgets/swipeable_expense_group_card.dart:32`
2. Bump delle 3 dipendenze minori sopra (`flutter pub upgrade` mirato).
3. Commento "hacky" in `lib/manager/group/widgets/section_period.dart:103` — fallback da chiarire o rimuovere.

**Esito**: tutti e 3 i punti risolti.
- Le 8 chiamate dirette a `ScaffoldMessenger` sono state sostituite con `AppToast.show`; rimosso anche un parametro `messenger` morto in `swipeable_expense_group_card.dart` (catturato ma mai realmente usato, già migrato ad `AppToast` in precedenza).
- Il fallback "hacky" in `section_period.dart` era codice morto (l'unico chiamante fornisce sempre `onDateRangeChanged`): rimosso insieme alla catena di parametri/metodi diventati inutilizzabili a cascata (`onPickDate` in `SectionPeriod`/`PeriodSectionEditor`, i metodi `_pickDate` da ~50 righe in `expense_group_general_page.dart` ed `expenses_group_edit_page.dart`) — circa 150 righe di codice morto rimosse.
- `talker`/`talker_flutter`/`talker_logger` aggiornati a 5.1.19 e `video_player` a 2.13.0 in root e in tutti i pacchetti locali. `intl` resta a 0.20.2: è vincolato da `flutter_localizations` nell'SDK Flutter installato, non aggiornabile senza bump dell'SDK.
- Validato con `flutter analyze` (0 problemi) e `flutter test` (667 test, tutti passati).
- CHANGELOG.md aggiornato in `[Unreleased]`.

## P1 — Debito strutturale (giorni, per file)

4. **File troppo grandi / troppe responsabilità**, candidati a essere scomposti in widget/controller più piccoli:
   - `packages/caravella_core/lib/data/sqlite_expense_group_repository.dart` — 1085 righe
   - `lib/manager/group/pages/expenses_group_edit_page.dart` — 945 righe
   - `lib/manager/details/pages/expense_group_detail_page.dart` — 843 righe
   - `lib/manager/expense/components/expense_form_component.dart` — 733 righe
   - `lib/manager/details/pages/expense_search_page.dart` — 725 righe
   - `lib/settings/pages/settings_page.dart`, `lib/manager/group/pages/unsplash_search_page.dart`, `lib/manager/group/widgets/background_picker.dart` — 590-630 righe
5. `packages/caravella_core/lib/data/storage_benchmark.dart` (541 righe) è un tool da dev/test, ma è esportato da `caravella_core.dart` e finisce compilato nelle build di produzione. Va isolato (spostato in `test/tooling` o dietro un dart-define) per alleggerire il pacchetto core.
6. Viste SQL `v_group_totals`/`v_category_totals`/`v_participant_totals` create nello schema v2 ma **mai interrogate** dal codice Dart (documentato in `docs/STORAGE_BACKEND.md`): o si sfruttano per semplificare le query raw esistenti, o si tolgono dallo schema per evitare drift silenzioso.

## P2 — Debito architetturale (da pianificare, rischio più alto)

7. `packages/caravella_core/lib/data/storage_transaction.dart` è progettato per il backend file-based e **non è testato contro le garanzie di atomicità di SQLite** (rischio già segnalato nella doc, ma non risolto nel codice). Se qualcuno lo estende assumendo semantiche SQLite, rompe silenziosamente.
8. Backend JSON legacy (`packages/caravella_core/lib/data/file_based_expense_group_repository.dart`, 812 righe) mantenuto solo per l'escape hatch F-Droid/`USE_JSON_BACKEND` — ben documentato, ma è una seconda implementazione completa dell'interfaccia da tenere in sync nei test.
9. **Copertura test**: 96 file di test contro 267 file sorgente (~36% a livello di file, nessuna metrica line-level in CI). La pipeline non misura coverage — non si vede se `sqlite_expense_group_repository.dart` o i controller critici sono davvero coperti.

## Fuori scope per ora

Non ci sono deprecazioni API né gap di dipendenze major da inseguire (i gap più grandi, es. `analyzer`/`pigeon`, sono dev-tool pinnati dal Flutter SDK, non serve toccarli).

## Piano di esecuzione proposto

| Sprint | Contenuto | Durata stimata |
|---|---|---|
| 1 | P0 completo (fix AppToast + bump dipendenze) + regola/lint per prevenire nuovi `ScaffoldMessenger.of` diretti | 1-2 giorni |
| 2 | Refactor dei 2 file più critici: `sqlite_expense_group_repository.dart` e `expenses_group_edit_page.dart` | 3-5 giorni |
| 3 | Isolare `storage_benchmark.dart`, chiarire/testare `storage_transaction.dart` su SQLite, decidere sulle viste inutilizzate | 2-3 giorni |
| 4 | Coverage baseline in CI (`flutter test --coverage`) + soglia minima, test mirati sui file toccati negli sprint precedenti | 2-3 giorni |
