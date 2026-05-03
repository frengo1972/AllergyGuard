# AllergyGuard — Admin Dashboard

## Cos'è

Un pannello di controllo web per visualizzare e analizzare tutti i dati presenti nel database Supabase dell'app AllergyGuard. È un file HTML statico deployato su **GitHub Pages**, accessibile all'indirizzo:

```
https://frengo1972.github.io/AllergyGuard/admin.html
```

---

## Architettura generale

```
Browser (admin.html)
       │
       │  POST  x-admin-secret: <password>
       ▼
Supabase Edge Function  ─── admin-query
       │
       │  service_role key (server-side, mai esposta al browser)
       ▼
Supabase PostgreSQL  (bypass RLS completo)
```

### Perché questa struttura?

Supabase blocca l'uso della **service role key** dal browser per ragioni di sicurezza (sia lato client JS che lato server gateway). La service role key bypassa tutte le RLS policy e non va mai esposta in una pagina web pubblica.

La soluzione adottata prevede un livello intermedio: l'**Edge Function** `admin-query` gira server-side su Deno, usa la service role key come variabile d'ambiente (mai visibile al browser), e accetta richieste dal dashboard solo se la richiesta include l'header `x-admin-secret` con il valore corretto.

---

## File creati

### 1. `docs/admin.html`

Il pannello di controllo vero e proprio. È un **single-file HTML** senza build step, senza framework, con CSS e JavaScript embedded.

**Librerie esterne (CDN):**
- **SheetJS** (`xlsx.full.min.js`) — per l'export in formato Excel (.xlsx)

**Funzionalità:**

| Sezione | Tabella Supabase | Descrizione |
|---|---|---|
| Overview | — | Contatori totali + 4 bar chart |
| Context Patterns | `context_patterns` | Pattern OCR crowdsourced |
| User Feedback | `user_feedback` | Feedback anonimi degli utenti |
| Product Reports | `product_reports` | Segnalazioni allergeni per barcode |
| Scan History | `scan_history` | Storico scansioni utenti autenticati |
| Allergens | `allergens` | Catalogo allergeni EU |
| App Datasets | `app_datasets` | Versioni dataset |

**Funzionalità comuni a tutte le tabelle:**
- **Sort** su ogni colonna (click sull'intestazione, toggle asc/desc)
- **Ricerca full-text** (debounced 350ms, ilike su colonne configurate)
- **Filtri dropdown** per i campi categorici (status, lingua, paese, tipo, ecc.)
- **Paginazione** server-side, 50 righe per pagina
- **Export XLS** — esporta tutti i record con i filtri correnti (fino a 10.000 righe)

**Overview dashboard:**
- 5 stat card: totale pattern, feedback, product reports, scan history, allergeni
- Breakdown pattern: quanti verified vs candidate
- Bar chart: pattern per lingua
- Bar chart: pattern per tipo (contains / may_contain / facility)
- Bar chart: feedback per tipo
- Bar chart: feedback per risultato (danger / warning / safe)

**Login / credenziali:**
- Form di login con URL Supabase + Admin Secret
- Opzione "Remember" (localStorage) o solo sessione (sessionStorage)
- Auto-login al ricaricamento se credenziali salvate
- Al logout: pulizia completa da localStorage/sessionStorage

---

### 2. `supabase/functions/admin-query/index.ts`

Edge Function Deno deployata su Supabase. Agisce da **proxy sicuro** tra il browser e il database.

**Endpoint:** `POST https://<project>.supabase.co/functions/v1/admin-query`

**Autenticazione:** header `x-admin-secret: <password>` verificato contro la variabile d'ambiente `ADMIN_DASHBOARD_SECRET`.

**Variabili d'ambiente usate (automatiche in Supabase):**
- `SUPABASE_URL` — iniettata automaticamente dal runtime
- `SUPABASE_SERVICE_ROLE_KEY` — iniettata automaticamente dal runtime
- `ADMIN_DASHBOARD_SECRET` — impostata manualmente via Secrets

**Azioni supportate:**

| Action | Parametri | Risposta |
|---|---|---|
| `ping` | — | `{ ok: true }` — test connessione |
| `count` | `table`, `filters` | `{ count: N }` — conteggio righe |
| `col` | `table`, `col` | array di valori — per popolare dropdown |
| `query` | `table`, `filters`, `search`, `sc`, `sortCol`, `sortAsc`, `page`, `PS`, `forExport` | `{ data, count }` |

**CORS:** headers `Access-Control-Allow-Origin: *` su tutte le risposte, gestione preflight OPTIONS.

**JWT Verification:** **disabilitata** — la funzione gestisce la propria autenticazione via `x-admin-secret`.

---

### 3. `docs/index.html` (modifica minore)

Aggiunto link "Admin Dashboard" nella landing page pubblica di GitHub Pages.

---

## Tabelle del database coperte

### `context_patterns`
Pattern OCR multilingua estratti dalle etichette dei prodotti. Workflow: gli utenti scansionano → i pattern candidati vengono validati da Claude API → promossi a verified dopo 5+ segnalazioni da 3+ dispositivi diversi.

Campi chiave: `pattern_text`, `language_code`, `pattern_type` (contains/may_contain/facility), `confidence`, `status` (candidate/verified), `seen_count`, `device_ids[]`, `source_ocr_text`.

### `user_feedback`
Feedback anonimi degli utenti sulla correttezza dei risultati. **Nessuna RLS SELECT** — leggibile solo con service role key, quindi solo tramite l'edge function.

Campi chiave: `feedback_type` (scan_accuracy/suggestion/bug_report/general), `result_level`, `is_correct`, `expected_level`, `product_barcode`, `allergen_keys[]`, `comment`, `language_code`, `country_code`, `app_version`.

### `product_reports`
Segnalazioni community che associano un barcode a un allergene. Leggibile pubblicamente (RLS = true), ma il dashboard mostra tutto inclusi i device_id.

### `scan_history`
Storico scansioni degli utenti autenticati. RLS per user_id — normalmente ogni utente vede solo le sue. Con service role key (via edge function) il dashboard vede tutto.

### `allergens`
Catalogo master dei 14 allergeni EU regolamentati con nomi in 20 lingue, metadati UI (emoji, colore), severity.

### `app_datasets`
Versioning del dataset allergeni. Traccia quali chiavi sono state aggiunte in ogni versione.

---

## Setup e deployment

### Prerequisiti
- Progetto Supabase attivo
- GitHub Pages abilitato su `main` branch, cartella `/docs`

### Deploy Edge Function (una tantum)

**Via Supabase Dashboard:**
1. Supabase Dashboard → **Edge Functions** → **Deploy a new function**
2. Nome: `admin-query`
3. Incolla contenuto di `supabase/functions/admin-query/index.ts`
4. Toggle **"Verify JWT"** → **OFF**
5. Deploy

**Via CLI (se installata):**
```bash
supabase functions deploy admin-query --no-verify-jwt
```

### Impostare il secret

**Via Dashboard:**  
Edge Functions → **Secrets** → `+ New secret`  
- Name: `ADMIN_DASHBOARD_SECRET`  
- Value: password scelta da te

**Via CLI:**
```bash
supabase secrets set ADMIN_DASHBOARD_SECRET=la-tua-password
```

### Accedere al dashboard

```
URL:          https://frengo1972.github.io/AllergyGuard/admin.html
URL Supabase: https://ngltvhyivnszvibbeumm.supabase.co
Admin Secret: (la password impostata in ADMIN_DASHBOARD_SECRET)
```

---

## Sicurezza

| Elemento | Dove vive | Esposto? |
|---|---|---|
| Service Role Key | Supabase runtime (env var) | ❌ Mai nel browser |
| ADMIN_DASHBOARD_SECRET | Supabase Secrets | ❌ Solo nell'edge function |
| Anon Key | `.env` gitignored | — Non usata dal dashboard |
| Admin HTML | GitHub Pages (pubblico) | ✅ Nessun segreto dentro |

Il dashboard senza la password admin è inutile — non può raggiungere nessun dato.

---

## Evoluzione futura possibile

- Aggiungere la vista aggregata `user_feedback_stats` (già presente come view in Supabase)
- Aggiungere grafici temporali (feedback per giorno, scansioni per settimana)
- Aggiungere possibilità di promuovere manualmente pattern candidate → verified
- Aggiungere filtro per intervallo di date su tutte le tabelle
