---
description: Checklist-driven prompt to prepare a full Caravella release (changelogs, store metadata, version bump, tag)
argument-hint: [version] [release-date]
---

# Release Creation Prompt

Prompt per creare una nuova release di Caravella con tutti i materiali necessari.

## Input Richiesto
- **Versione**: (es. 1.0.46, 1.1.0) — se non specificata negli argomenti, chiedila all'utente
- **Data release**: (es. 2025-12-03) — se non specificata negli argomenti, chiedila all'utente

Argomenti passati a questo comando: $ARGUMENTS

## Checklist Attività

### 1. Aggiorna CHANGELOG.md
- [ ] Sposta voci da `[Unreleased]` alla nuova versione
- [ ] Crea header `[X.Y.Z] - YYYY-MM-DD` sotto `[Unreleased]`
- [ ] Mantieni categorie: Added, Changed, Deprecated, Removed, Fixed, Security
- [ ] Aggiorna link di confronto versioni in fondo al file
- [ ] Lascia `[Unreleased]` vuoto per future modifiche

**Percorso**: `/CHANGELOG.md`

### 2. Aggiorna README.md
- [ ] Aggiungi/aggiorna sezione "What's New" dopo Screenshots
- [ ] Elenca 3-5 cambiamenti più importanti della release
- [ ] Usa tono professionale e amichevole
- [ ] Focalizza sui benefici utente, non dettagli tecnici
- [ ] Bullet point concisi (1-2 righe ciascuno)

**Percorso**: `/README.md`

**Formato esempio**:
```markdown
## 🎉 What's New in v1.0.46

- **Enhanced Maps**: Clearer point of interest visibility in dark theme
- **Smoother Updates**: Automatic update checks happen seamlessly in the background
- **Smarter Charts**: Expense graphs now adapt intelligently to your date ranges
- **Better Stability**: Improved loading states and fixed various edge cases
```

### 3. Aggiorna Changelog Localizzati (In-App)
Aggiorna i file markdown in `assets/docs/` per mostrare le novità nella pagina "What's New" dell'app:

**File da aggiornare**:
- `assets/docs/CHANGELOG_en.md` (English)
- `assets/docs/CHANGELOG_it.md` (Italian)
- `assets/docs/CHANGELOG_es.md` (Spanish)
- `assets/docs/CHANGELOG_pt.md` (Portuguese)
- `assets/docs/CHANGELOG_zh.md` (Chinese)

**Formato**: Segui lo stile Keep a Changelog
```markdown
# Changelog

## [X.Y.Z] - YYYY-MM-DD

### Added
- [Nuova funzionalità user-facing]

### Changed
- [Miglioramento user-facing]

### Fixed
- [Bug fix user-facing]

## [Versioni precedenti...]
```

**Linee guida**:
- Usa linguaggio user-friendly, non tecnico
- Focus su cambiamenti visibili all'utente
- Mantieni coerenza tra tutte le lingue
- Ordina per rilevanza (features → improvements → fixes)

### 4. Crea Changelog Fastlane per F-Droid
Crea file di changelog per F-Droid in `fastlane/metadata/android/[locale]/changelogs/[versionCode].txt`

**Percorsi**:
- `fastlane/metadata/android/en-US/changelogs/[BUILD_NUMBER].txt`
- `fastlane/metadata/android/it-IT/changelogs/[BUILD_NUMBER].txt`
- `fastlane/metadata/android/es-ES/changelogs/[BUILD_NUMBER].txt`
- `fastlane/metadata/android/pt-BR/changelogs/[BUILD_NUMBER].txt`
- `fastlane/metadata/android/zh-CN/changelogs/[BUILD_NUMBER].txt`

**Formato**: Testo semplice, massimo 500 caratteri
```
Version X.Y.Z - [Titolo]

• [Cambiamento 1]
• [Cambiamento 2]
• [Cambiamento 3]

[Nota finale positiva]
```

**Linee guida F-Droid**:
- Massimo 500 caratteri per file
- Usa bullet points (•) per chiarezza
- Nome file deve corrispondere al versionCode (build number)
- Tono user-friendly, evita tecnicismi
- Focus su 3-4 cambiamenti più rilevanti
- F-Droid mostrerà questi changelog nella pagina dell'app

### 5. Crea Release Notes per Store
Crea file: `store/changelog/release-notes-X.Y.Z.xml`

**Template**:
```xml
<en-US>
Version X.Y.Z - [Titolo Accattivante]

• [Categoria]: [Cambiamento user-facing 1]
• [Categoria]: [Cambiamento user-facing 2]
• [Categoria]: [Cambiamento user-facing 3]
• [Frase conclusiva positiva]
</en-US>
<es-419>
Versión X.Y.Z - [Título Atractivo]

• [Categoría]: [Cambio para usuario 1]
• [Categoría]: [Cambio para usuario 2]
• [Categoría]: [Cambio para usuario 3]
• [Frase conclusiva positiva]
</es-419>
<es-ES>
[Come es-419]
</es-ES>
<es-US>
[Come es-419]
</es-US>
<it-IT>
Versione X.Y.Z - [Titolo Accattivante]

• [Categoria]: [Modifica user-facing 1]
• [Categoria]: [Modifica user-facing 2]
• [Categoria]: [Modifica user-facing 3]
• [Frase conclusiva positiva]
</it-IT>
<pt-BR>
Versão X.Y.Z - [Título Atraente]

• [Categoria]: [Mudança para usuário 1]
• [Categoria]: [Mudança para usuário 2]
• [Categoria]: [Mudança para usuário 3]
• [Frase conclusiva positiva]
</pt-BR>
<pt-PT>
[Come pt-BR ma con "utilizador" invece di "usuário"]
</pt-PT>
<zh-CN>
版本 X.Y.Z - [吸引人的标题]

• [类别]: [面向用户的更改 1]
• [类别]: [面向用户的更改 2]
• [类别]: [面向用户的更改 3]
• [积极结尾]
</zh-CN>
```

**Linee guida**:
- Massimo 500 caratteri per locale (limite store)
- Usa bullet points (•) per chiarezza
- Categorie suggerite: New features, Improvements, Bug fixes, Performance
- Tono professionale ma amichevole e accessibile
- Focus su 3-4 cambiamenti più importanti
- Evita gergo tecnico
- Termina con nota positiva o ringraziamento

### 6. Aggiorna Store Metadata

#### 6.1 Full Description
**Percorso**: `store/metadata/[locale]/full_description.txt`
- [ ] Rivedi lista funzionalità se aggiunte nuove feature importanti
- [ ] Mantieni descrizione compelling e chiara
- [ ] Aggiorna per tutti i locale: en-US, es-ES, it-IT, pt-BR, zh-CN

#### 6.2 Short Description (se necessario)
**Percorso**: `store/metadata/[locale]/short_description.txt`
- [ ] Mantieni sotto 80 caratteri
- [ ] Aggiorna solo se cambio importante nella value proposition

#### 6.3 Title (se necessario)
**Percorso**: `store/metadata/[locale]/title.txt`
- [ ] Mantieni sotto 30 caratteri
- [ ] Aggiorna solo per cambi di branding importanti

### 7. Aggiorna Numeri Versione

#### 7.1 pubspec.yaml principale
**Percorso**: `/pubspec.yaml`
```yaml
version: X.Y.Z+BUILD_NUMBER
```
- [ ] Aggiorna versione (X.Y.Z)
- [ ] Incrementa build number (+BUILD_NUMBER)

#### 7.2 Package versions (se modificati)
**Percorsi**:
- `/packages/caravella_core/pubspec.yaml`
- `/packages/caravella_core_ui/pubspec.yaml`
- `/packages/play_store_updates/pubspec.yaml`

### 8. Crea Git Tag
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z - [Descrizione breve]"
git push origin vX.Y.Z
```

## Linee Guida Scrittura Release Notes

### Tono & Stile
- **Professionale ma amichevole**: "Abbiamo migliorato..." non "Fixato bug dove..."
- **User-focused**: Spiega benefici, non implementazione tecnica
- **Positivo**: "Migliorato" invece di "Riparato rotto"
- **Action-oriented**: Inizia con verbi (Migliorato, Aggiunto, Ottimizzato)
- **Conciso**: Una riga per cambiamento, massimo impatto

### Esempi Buoni ✅
- "Le mappe in tema scuro ora mostrano i punti di interesse più chiaramente"
- "I controlli aggiornamenti avvengono automaticamente all'avvio dell'app"
- "I grafici si adattano intelligentemente ai tuoi periodi di spesa"
- "Caricamenti più fluidi quando aggiungi nuove spese"

### Esempi Cattivi ❌
- "Fixato null pointer exception in DateRangeExpenseChart widget"
- "Refactoring dependency injection per play_store_updates package"
- "Cambiato URL tile CartoDB da voyager a dark_all"
- "Spostati file update/ nel package senza riferimenti circolari"

### Traduzione Note
- Mantieni tono consistente tra tutti i locale
- Adatta idiomi ed espressioni culturalmente
- Mantieni termini tecnici comuni in inglese (es. "Dark Mode")
- Verifica limiti caratteri per ogni piattaforma store
- Per pt-PT usa "utilizador" invece di "usuário" (pt-BR)

## Priorità Cambiamenti per Release Notes

### Alta priorità (sempre includere)
1. Nuove funzionalità visibili all'utente
2. Miglioramenti UX significativi
3. Bug fix critici che impattavano l'uso

### Media priorità (includere se spazio)
4. Ottimizzazioni performance percepibili
5. Miglioramenti estetici
6. Bug fix minori ma fastidiosi

### Bassa priorità (omettere)
7. Refactoring interni
8. Aggiornamenti dipendenze
9. Fix di edge case rari
10. Miglioramenti codice non visibili

## Controlli Finali
- [ ] Tutti i numeri versione corrispondono tra tutti i file
- [ ] CHANGELOG.md principale formattato correttamente con link
- [ ] README.md aggiornato con highlights user-friendly
- [ ] Tutti i CHANGELOG localizzati (assets/docs) aggiornati
- [ ] Changelog Fastlane per F-Droid creati per tutti i locale (fastlane/metadata/android)
- [ ] Release notes XML create per tutti i locale store
- [ ] Store metadata rivisti e aggiornati se necessario
- [ ] Git tag creato con formato corretto
- [ ] Tutti i file committati e pushati
- [ ] Build di test eseguito con successo
- [ ] `flutter analyze` passa senza errori

## Note Automazione
Considera script per automatizzare:
- Aggiornamento version numbers cross-file
- Sincronizzazione date tra tutti i changelog
- Validazione formato release notes XML
- Controllo limiti caratteri per store
