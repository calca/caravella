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
   - ~~`packages/caravella_core/lib/data/sqlite_expense_group_repository.dart` — 1085 righe~~ — ✅ **completato 2026-07-14**: sceso a 574 righe (-47%). Estratti `sqlite_tables.dart` (costanti nomi tabella, 6 righe), `sqlite_schema.dart` (DDL `CREATE TABLE`/`INDEX`, 95 righe), `sqlite_group_mapper.dart` (conversione riga SQL ↔ `ExpenseGroup`/`ExpenseDetails`, 207 righe). Nel file principale, introdotto un helper privato `_guarded<T>` che accentra il pattern `measureOperation` + try/catch + wrapping `StorageResult`/`FileOperationError` ripetuto identico in ~20 metodi, eliminando la boilerplate senza toccare i messaggi di errore per-metodo. Nessun cambio di comportamento: stessa interfaccia pubblica, stessi messaggi d'errore, stesso schema DB (`_databaseVersion` invariato). Validato con `flutter analyze` e l'intera suite (`flutter test`, incluso `test/sqlite_repository_test.dart` e `test/storage_migration_test.dart`) sia nel pacchetto che in root.
   - ~~`lib/manager/group/pages/expenses_group_edit_page.dart` — 945 righe~~ — ⚠️ **scoperta 2026-07-14, poi risolta diversamente**: durante lo scorporo (tab "General"/"Other" estratti in `GroupGeneralTab`/`GroupOtherTab`, overlay in `GroupFormBusyOverlay`) la verifica manuale sull'app ha rivelato che **`ExpensesGroupEditPage` era codice morto, irraggiungibile da qualunque punto della navigazione**: zero import del file in tutto il repo, la creazione gruppo reale passa da `GroupCreationWizardPage` e la modifica da `group_settings_page.dart` (che usa 4 pagine separate: `expense_group_general_page.dart`, `expense_group_participants_page.dart`, `expense_group_categories_page.dart`, `expense_group_other_page.dart`). L'unico riferimento residuo era un commento in un test. Deciso con l'utente di **cancellare il file e i 3 widget appena estratti** invece di mantenerli scorporati (~1300 righe morte rimosse invece di riorganizzate). Validato con `flutter analyze`, `flutter test` (653 test, nessuna regressione: non esisteva copertura dedicata) e un giro live sull'emulatore Android sulle pagine realmente usate (creazione gruppo end-to-end + pagina "Generali" con il selettore periodo semplificato in P0), senza errori.
   - `lib/manager/details/pages/expense_group_detail_page.dart` — 843 righe
   - `lib/manager/expense/components/expense_form_component.dart` — 733 righe
   - `lib/manager/details/pages/expense_search_page.dart` — 725 righe
   - `lib/settings/pages/settings_page.dart`, `lib/manager/group/pages/unsplash_search_page.dart`, `lib/manager/group/widgets/background_picker.dart` — 590-630 righe (non ancora affrontati)
5. ~~`packages/caravella_core/lib/data/storage_benchmark.dart` (541 righe) è un tool da dev/test, ma è esportato da `caravella_core.dart` e finisce compilato nelle build di produzione. Va isolato (spostato in `test/tooling` o dietro un dart-define) per alleggerire il pacchetto core.~~ — ✅ **completato 2026-07-14**: spostato (con `git mv`, storia preservata) da `packages/caravella_core/lib/data/storage_benchmark.dart` a `packages/caravella_core/test/storage_benchmark.dart`; il test associato (prima in `test/storage_benchmark_test.dart` nella root app) si è spostato con lui in `packages/caravella_core/test/storage_benchmark_test.dart` e ora importa la libreria core via `package:caravella_core/...` invece del barrel `caravella_core.dart`, da cui l'export è stato rimosso. Aggiunto `path_provider_platform_interface` come dev_dependency di `caravella_core` (serviva al fake path provider del test). Validato con `flutter analyze` e `flutter test` puliti sia nel pacchetto sia in root (root passa da 667 a 653 test: i 14 test del benchmark sono solo "traslocati", non persi).
6. ~~Viste SQL `v_group_totals`/`v_category_totals`/`v_participant_totals` create nello schema v2 ma **mai interrogate** dal codice Dart (documentato in `docs/STORAGE_BACKEND.md`): o si sfruttano per semplificare le query raw esistenti, o si tolgono dallo schema per evitare drift silenzioso.~~ — ✅ **completato 2026-07-14**: rimosse dallo schema (`_createViews`/`_upgradeDatabase` in `sqlite_expense_group_repository.dart`) invece di adottarle, perché non sarebbero state materializzate (nessun vantaggio di performance rispetto alle query raw esistenti) e due delle tre non avevano nessun consumatore previsto. `_databaseVersion` non è stato incrementato: le installazioni già migrate a v2 mantengono le viste (innocue, inutilizzate) finché non reinstallano. `docs/STORAGE_BACKEND.md` aggiornato di conseguenza.

## P2 — Debito architetturale (da pianificare, rischio più alto)

7. ~~`packages/caravella_core/lib/data/storage_transaction.dart` è progettato per il backend file-based e **non è testato contro le garanzie di atomicità di SQLite** (rischio già segnalato nella doc, ma non risolto nel codice). Se qualcuno lo estende assumendo semantiche SQLite, rompe silenziosamente.~~ — ✅ **completato 2026-07-14, scoperta più grave del previsto**: analizzando il file è emerso che non si tratta solo di "non testato" ma di un **bug reale**: `executeTransaction` è un'extension su `IExpenseGroupRepository` (quindi chiamabile anche sul repository SQLite), ma `_saveAllGroups` per qualunque backend diverso da `FileBasedExpenseGroupRepository` esegue un loop di `saveGroup()` singoli **senza transazione**, senza rollback in caso di fallimento parziale. Come per `ExpensesGroupEditPage`, si è verificato che **nessun codice di produzione chiama `.executeTransaction(`** — è dead code con un bug latente, non un rischio "in attesa di essere colpito" ma già del tutto inerte. Rimosso `storage_transaction.dart`, l'export dal barrel, il test dedicato (`test/storage_transaction_test.dart`) e il benchmark che lo esercitava in `packages/caravella_core/test/storage_benchmark.dart`. `docs/STORAGE_BACKEND.md` aggiornato con la spiegazione e un puntatore a `db.transaction` (già usato in `saveGroup`/`updateGroupMetadata`) per chi avesse bisogno di scritture atomiche batch in futuro. Validato con `flutter analyze` e `flutter test` (634 test, -19 per la rimozione dei test dedicati, nessuna regressione altrove).
8. Backend JSON legacy (`packages/caravella_core/lib/data/file_based_expense_group_repository.dart`, 812 righe) mantenuto solo per l'escape hatch F-Droid/`USE_JSON_BACKEND` — ben documentato, ma è una seconda implementazione completa dell'interfaccia da tenere in sync nei test. **Non affrontato**: a differenza degli item 7/4, qui non c'è un'azione meccanica sicura — è un trade-off architetturale intenzionale (serve come sorgente per la migrazione una-tantum e come escape hatch F-Droid), non un bug. Richiede una decisione di prodotto (es. "vale ancora la pena mantenere l'escape hatch JSON?") più che un refactor.
9. ~~**Copertura test**: 96 file di test contro 267 file sorgente (~36% a livello di file, nessuna metrica line-level in CI). La pipeline non misura coverage — non si vede se `sqlite_expense_group_repository.dart` o i controller critici sono davvero coperti.~~ — ✅ **completato 2026-07-14** (solo visibilità, senza soglia minima come concordato): `.github/workflows/Development - Android.yml` ora lancia `flutter test --coverage` e carica `coverage/lcov.info` come artifact (`coverage-report`) — nessun cambio al gate pass/fail della pipeline. `coverage/` era già tracciato per errore in git (un vecchio `coverage/lcov.info` committato in `21ffbb9e`) senza essere in `.gitignore`: rimosso dal tracking e aggiunta la voce a `.gitignore`, altrimenti ogni sviluppatore l'avrebbe visto "modificato" a ogni run locale. Baseline attuale misurata localmente: **19.4% di copertura a livello di riga** (15593 righe totali, 3024 coperte) — nessuna soglia minima impostata in CI, da valutare in futuro se si vuole un gate. `docs/CI_PIPELINES.md` aggiornato di conseguenza.

## Fuori scope per ora

Non ci sono deprecazioni API né gap di dipendenze major da inseguire (i gap più grandi, es. `analyzer`/`pigeon`, sono dev-tool pinnati dal Flutter SDK, non serve toccarli).

## Piano di esecuzione proposto

| Sprint | Contenuto | Durata stimata |
|---|---|---|
| 1 | P0 completo (fix AppToast + bump dipendenze) + regola/lint per prevenire nuovi `ScaffoldMessenger.of` diretti | 1-2 giorni |
| 2 | ✅ Refactor dei 2 file più critici: `sqlite_expense_group_repository.dart` (scorporato) e `expenses_group_edit_page.dart` (rivelato codice morto, cancellato) | 3-5 giorni |
| 3 | ✅ Isolato `storage_benchmark.dart`; viste SQL inutilizzate rimosse; `storage_transaction.dart` rimosso (era dead code con bug di non-atomicità su SQLite, non solo "da chiarire") | 2-3 giorni |
| 4 | ✅ Coverage baseline in CI (`flutter test --coverage`, solo visibilità, nessuna soglia minima) — item 8 (backend JSON legacy) resta aperto: è una decisione di prodotto, non un refactor | 2-3 giorni |
