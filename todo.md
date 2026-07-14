# TODO — Migliorie funzionali e tecniche

Ricognizione della codebase (v1.7.18) per identificare aree di miglioramento concrete. Non sono presenti TODO/FIXME inline nel codice (buon segno di igiene, ma significa che questo debito non era tracciato da nessuna parte prima d'ora).

Legenda priorità: 🔴 alta · 🟡 media · 🟢 bassa/nice-to-have

---

## 1. Performance

- 🔴 **N+1 query nel repository SQLite** — `packages/caravella_core/lib/data/sqlite_expense_group_repository.dart`:
  - `_loadAllGroups` (righe 733-743) itera su tutti i gruppi ed esegue `_mapToGroup` per ciascuno in sequenza (await in loop).
  - `_mapToGroup` (righe 758-836) per ogni gruppo lancia 3 query separate (participants, categories, expenses) invece di un JOIN.
  - `_mapToExpense` (righe 858-885) per **ogni singola spesa** esegue un'ulteriore query per gli attachments (righe 878-882).
  - Costo risultante: `O(3N + M)` query sequenziali (N=gruppi, M=totale spese) per `getAllGroups()`, che alimenta home page e history. Gli indici (righe 151-167) sono corretti, ma non compensano il pattern N+1. Da sostituire con JOIN o query batch (`WHERE group_id IN (...)`).
- 🟡 **Nessuna paginazione generale** — solo `getRecentExpenses(groupId, limit:)` (`expense_group_storage_v2.dart:495`) è limitato; `getAllGroups()` e lo storico completo spese caricano tutto in memoria. Con molti gruppi/spese diventa un problema sia di query sia di rendering.
- 🟢 **Liste non lazy** — verificare i 5 file che usano `ListView(` invece di `ListView.builder(` (contro 7 che già usano la versione lazy) per le liste potenzialmente lunghe (storico spese, ricerca).

## 2. Sicurezza

- 🔴 **Dati finanziari non cifrati a riposo** — nessuna dipendenza `flutter_secure_storage` nel progetto. Il database SQLite (`expense_groups.db`) e le SharedPreferences (nome utente, impostazioni) non sono cifrati, nonostante l'app tratti spese, importi, partecipanti e posizione geografica delle spese. Valutare cifratura del DB (es. `sqlcipher_flutter_libs`) o quantomeno dei campi più sensibili.
- 🟡 **Backup/export non protetti** — gli export (CSV, OFX, Markdown, ZIP backup in `lib/manager/details/export/`) sono generati in chiaro senza opzione di password/cifratura, pur contenendo gli stessi dati finanziari.
- 🟡 **`flag_secure` solo Android** — `lib/settings/flag_secure_android.dart` oscura l'app switcher/screenshot solo su Android; su iOS lo stesso rischio (dati finanziari visibili nello screenshot dell'app switcher) non è coperto.
- 🟢 **Swallow silenzioso di errori in punti sensibili** — es. `storage_migration_service.dart` ignora silenziosamente i fallimenti di backup durante la migrazione ("don't fail migration if backup fails"); `packages/play_store_updates/lib/src/app_update_service.dart` (righe 45, 55, 89) ha blocchi `catch` con commenti "Ignore errors" / "Handle any other errors silently" senza logging. Su 132 `catch (e)` generici nel codice, solo 46 file usano `LoggerService` — andrebbe fatta una passata per assicurarsi che gli errori rilevanti (specialmente su storage/backup) siano quantomeno loggati.

## 3. Test & qualità

- 🔴 **Nessun test per il flusso OCR ricevute** — esiste solo `test/services/receipt_scanner_service_test.dart` (unit sul service). Il flusso UI completo descritto in `docs/RECEIPT_OCR_FLOW.md` (scansione, review, attach) non ha widget test, nonostante sia una feature complessa con più stati di errore.
- 🟡 **`lib/manager/details` scoperto** — 26 file (statistiche, grafici, export) senza una struttura di test parallela; solo l'export (`markdown_export_test.dart`, `ofx_export_test.dart`, `zip_backup_test.dart`) è coperto. I widget dei grafici (`caravella_core_ui/lib/widgets/charts`) non hanno test dedicati verificati.
- 🟡 **Nessun golden test** in tutto il repo — per un'app con temi light/dark, dynamic color e più lingue (testo di lunghezza variabile), i golden test aiuterebbero a intercettare regressioni visive.
- 🟡 **Nessun vero integration test end-to-end** — `integration_test_test.dart` e affini sono in realtà widget test (`flutter_test`), non test `integration_test` su device/emulatore reale. Da introdurre almeno per il flusso critico "crea gruppo → aggiungi spesa → verifica saldo".
- 🟢 **`packages/play_store_updates` senza test** e `packages/android_app_functions` con test minimi rispetto a `lib/src` — package isolati dovrebbero avere copertura propria dato che sono testabili senza dipendere dall'app host.
- 🟢 **Test di accessibilità limitati a EN/IT/ES** — `test/accessibility_localization_test.dart` non copre PT e ZH.

## 4. Architettura & debito tecnico

- 🟡 **Doppio repository ancora coesistente** — `file_based_expense_group_repository.dart` (JSON legacy) convive con `sqlite_expense_group_repository.dart` da diverse versioni (SQLite è default da tempo secondo `docs/SQLITE_BACKEND.md`). Se la migrazione è stabile in produzione, pianificare la rimozione del backend JSON (o quantomeno il congelamento a solo-lettura per l'export F-Droid) per ridurre la superficie di manutenzione doppia.
- 🟢 **`ExpenseGroupNotifier` e altri 16 `ChangeNotifier`** — nessun problema strutturale, ma con la crescita dell'app valutare se Provider + ChangeNotifier custom scala ancora bene o se conviene consolidare pattern comuni (es. gestione loading/error) in una base class condivisa.

## 5. CI/CD

- 🔴 **Nessuna pipeline iOS** — l'app ha target iOS configurato (`flutter_launcher_icons` genera icone iOS, esiste `ios/`) ma nessun workflow builda o testa su iOS. Se iOS è un target reale, va aggiunta una lane CI dedicata; se non lo è, va chiarito/documentato per evitare di scoprire regressioni solo al momento del rilascio.
- 🟡 **Nessun report di code coverage** — CI esegue `flutter test` ma senza `--coverage` né upload a Codecov/simili, quindi le lacune di test (sezione 3) restano invisibili nel tempo.
- 🟢 **Nessun check di formattazione** — `flutter analyze` è presente ma manca `dart format --set-exit-if-changed` come gate CI.
- 🟢 **Package interni senza CI isolata** — `caravella_core`, `caravella_core_ui`, `android_app_functions`, `play_store_updates` non hanno un workflow che li testi indipendentemente dall'app host.

## 6. Localizzazione

- 🟡 **Traduzioni incomplete rispetto a EN** — confronto chiavi: IT -5, ES -14, **PT -21** (lingua più indietro), ZH -15 (+10 chiavi extra non presenti in EN, da ripulire). Da allineare, soprattutto PT che è la più scoperta.
- 🟢 **File ZH anomalo** — molto più grande delle altre lingue (verificare duplicati/placeholder ridondanti in `lib/l10n/app_zh.arb`).

## 7. Accessibilità

- 🟡 **Nessuno script di validazione automatica** — `CLAUDE.md`/`copilot-instructions.md` menzionano `validate_accessibility.sh` ma il file non esiste nel repo: va creato oppure la documentazione va corretta.
- 🟢 **Copertura parziale** — i test Dart esistenti (`accessibility_test.dart`) verificano semantics labels su elementi base (logo, FAB, settings) ma non contrasto colori, dynamic type/scaling, o flussi complessi come il wizard di creazione gruppo.

## 8. Documentazione

- 🟡 **Feature recenti non documentate in `docs/`** — group type templates, wizard di creazione gruppo, integrazione Android App Functions (AI agent/Gemini) sono solo nel CHANGELOG, non hanno una pagina dedicata in `docs/` come invece OCR e SQLite backend.
- 🟢 **Mancano doc per**: sistema notifiche, export multi-formato (OFX/Markdown/CSV/ZIP backup), sistema temi/dynamic color, processo di contribuzione traduzioni.

## 9. Dipendenze

- 🟡 **`file_picker: ^12.0.0-beta.7`** — dipendenza beta in produzione, da monitorare per il rilascio stabile.
- 🟢 **Package di nicchia/poco maturi**: `flag_secure ^2.0.2`, `zentoast ^0.2.2`, `android_nav_setting ^0.0.2+2` — verificarne manutenzione attiva e valutare alternative più consolidate se il progetto cresce.
- 🟢 **`image_picker_android` pinnato separatamente** (`^0.8.13`) — probabile workaround per un bug; ricontrollare se ancora necessario con le versioni più recenti di `image_picker`.

## 10. Funzionalità (spunti prodotto)

Aree suggerite dall'assenza di feature comuni in app simili di expense-splitting, da validare con il product owner prima di implementare:

- 🟢 **Export/backup cifrato** (collegato al punto 2) — password opzionale su export ZIP/CSV.
- 🟢 **Statistiche multi-periodo/confronto** — se non già presenti, grafici di confronto mese-su-mese o categoria-su-categoria oltre alle viste esistenti (`DateRangeExpenseChart`, `MonthlyExpenseChart`, ecc.).
- 🟢 **Sync/backup cloud opzionale** — attualmente backup nativo Android/iOS (`BackupService`) via canale nativo; valutare se serve un backup cross-device esplicito (non solo OS-level).
- 🟢 **Ruolo iOS nella roadmap** — dato che manca sia CI sia documentazione dedicata, va chiarito se iOS è un target di prima classe o secondario, per allineare test/CI/doc di conseguenza.

---

*Generato tramite ricognizione automatica del codebase il 2026-07-13. I riferimenti a file/righe sono relativi allo stato del repo a quella data — verificarli prima di aprire issue/PR.*
