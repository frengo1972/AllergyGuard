# Documento Operativo — Release AllergyGuard su Google Play Store

**App:** AllergyGuard | **Package:** `io.github.frengo1972.allergyguard` | **Versione attuale:** `1.0.2+4`

---

## FASE 1 — Preparazione locale

### 1.1 Aggiorna la versione in `pubspec.yaml`

```yaml
# Formato: versionName+versionCode
# versionCode DEVE essere sempre incrementato (+1) rispetto alla versione precedente
# Esempio: da 1.0.2+4 a 1.0.3+5
version: 1.0.3+5
```

Regola: `versionCode` (numero dopo `+`) è intero crescente — Play Store **rifiuta** AAB con versionCode uguale o inferiore a versioni già caricate.

### 1.2 Verifica prerequisiti

```powershell
# Controlla che key.properties esista (richiesto per firma release)
Test-Path "android\key.properties"
# Deve restituire True

# Controlla Flutter
flutter doctor -v

# Sincronizza dipendenze
flutter pub get

# Rigenera codice generato (Drift + Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

### 1.3 Esegui i test

```powershell
flutter test
flutter analyze
```

Blocca la release se ci sono errori. Warning sono accettabili.

---

## FASE 2 — Build dell'AAB (Android App Bundle)

Google Play **richiede AAB**, non APK (dall'agosto 2021).

```powershell
# Build release AAB firmato
flutter build appbundle --release

# Output: build\app\outputs\bundle\release\app-release.aab
```

Verifica che il file esista:

```powershell
Test-Path "build\app\outputs\bundle\release\app-release.aab"
# Deve restituire True
```

> **Nota firma:** il `build.gradle.kts` legge `android/key.properties` automaticamente. Se il file manca, la build usa il debug keystore e Play Store **rifiuterà** l'upload (firma diversa dalla versione precedente).

---

## FASE 3 — Upload su Google Play Console

### 3.1 Accedi alla Console

**URL:** https://play.google.com/console

Accedi con l'account Google owner del Developer account.

### 3.2 Seleziona l'app

- Sidebar sinistra → **"Tutte le app"**
- Clicca su **AllergyGuard** nella lista

---

## FASE 4 — Caricamento per i tester (Internal Testing)

### 4.1 Naviga al canale Internal Testing

```
Menu sinistro → "Test" → "Test interni"
```

oppure per Alpha:

```
Menu sinistro → "Test" → "Test chiusi" → scheda "Tester interni"
```

### 4.2 Crea nuova release

1. Clicca **"Crea nuova release"** (pulsante blu in alto a destra)
2. Nella sezione **"App bundle"** → trascina o clicca **"Carica"**
3. Seleziona il file: `build\app\outputs\bundle\release\app-release.aab`
4. Attendi upload e processing (1–3 minuti)
5. Play Console mostra automaticamente **versione:** `1.0.3` | **codice versione:** `5`

### 4.3 Compila le note di rilascio

Nel campo **"Note sulla versione"** aggiungi note per lingua:

```
it-IT: Nuove funzionalità: [descrizione]. Correzioni: [lista bug].
en-US: What's new: [description]. Bug fixes: [list].
```

### 4.4 Salva e pubblica

1. Clicca **"Salva"**
2. Clicca **"Esamina release"**
3. Clicca **"Inizia distribuzione agli internal tester"**

Il canale Internal Testing è **immediato** — nessuna review di Google richiesta.

---

## FASE 5 — Notifica ai tester e disattivazione versione precedente

### 5.1 Link di opt-in per i tester

```
Menu sinistro → "Test" → "Test interni" → scheda "Tester"
```

Copia il link **"Invita i tester"** (formato: `https://play.google.com/apps/internaltest/...`) e invialo ai tester via email o chat.

I tester che hanno già il link ricevono **notifica automatica di aggiornamento** dal Play Store entro pochi minuti.

### 5.2 Verifica disattivazione versione precedente

Quando la nuova release è in stato **"Attiva"**, la versione precedente viene automaticamente sostituita. Non serve un'azione manuale.

Per verificare:

```
"Test interni" → sezione "Release" → lista storico versioni
```

La versione precedente mostra stato **"Non attiva"** o **"Sostituita"**.

### 5.3 (Opzionale) Blocco di emergenza

Se devi bloccare la versione appena pubblicata prima che i tester la scarichino:

```
"Test interni" → clicca sulla release attiva → "Sospendi release"
```

---

## FASE 6 — Promozione in Produzione

### 6.1 Checklist pre-produzione

- [ ] Tutti i tester hanno confermato che la versione funziona
- [ ] Screenshot aggiornati se l'UI è cambiata
- [ ] Descrizione store aggiornata se necessario
- [ ] Privacy policy URL valido
- [ ] Rating contenuti compilato

### 6.2 Promuovi da Internal Testing a Produzione

**Opzione A — Promozione diretta dal canale test:**

```
"Test interni" → release attiva → pulsante "Promuovi release" → "Produzione"
```

**Opzione B — Nuova release diretta in produzione:**

```
Menu sinistro → "Produzione" → "Releases" → "Crea nuova release"
```

Carica lo stesso AAB già usato per i test — non ricompilare, usa lo stesso file con la stessa firma.

### 6.3 Rollout graduale (raccomandato)

Al momento della pubblicazione in produzione, Play Console chiede la percentuale di rollout:

| Percentuale | Quando usarla |
|-------------|---------------|
| 10% | Prima release pubblica, app nuova |
| 20–50% | Release con modifiche significative |
| 100% | Hotfix critici o versioni già testate a lungo |

**Procedura rollout graduale:**

1. Imposta percentuale → es. **20%**
2. Clicca **"Pubblica"** → Google avvia review (1–3 giorni per nuove app, ore per app già approvate)
3. Dopo review approvata → stato cambia in **"In distribuzione (20%)"**
4. Monitora crash rate e rating in: `Android Vitals → Crash e ANR`
5. Se stabile dopo 24–48h → aumenta percentuale: **"Aumenta rollout"** → 50% → poi 100%

### 6.4 Stati della release in produzione

```
Menu sinistro → "Produzione" → "Releases"
```

| Stato | Significato |
|-------|-------------|
| **In revisione** | Google sta esaminando — attendi |
| **In distribuzione** | Live con rollout parziale |
| **Pubblicata** | 100% degli utenti |
| **Sospesa** | Bloccata manualmente o da Google |

---

## RIEPILOGO COMANDI — Cheatsheet

```powershell
# 1. Bump versione in pubspec.yaml (modifica manuale)

# 2. Dipendenze e codice generato
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# 3. Test
flutter test
flutter analyze

# 4. Build AAB
flutter build appbundle --release

# 5. File output
#    build\app\outputs\bundle\release\app-release.aab
```

**URL utili:**

| Risorsa | URL |
|---------|-----|
| Play Console | https://play.google.com/console |
| Android Vitals (crash) | Play Console → Android Vitals → Stabilità |
| Stato review | Play Console → Politica → Dashboard |

---

## NOTE CRITICHE

- **Non incrementare `versionCode`** → Play Store rifiuta l'upload silenziosamente
- **Non ricompilare per la promozione prod** → usa l'AAB già testato, identico
- **`key.properties`** non va mai committato su git (già in `.gitignore`)
- Internal Testing non richiede review Google, Produzione sì (1–3 giorni)
- I tester devono iscriversi tramite il link opt-in **prima** di ricevere aggiornamenti dal canale test
