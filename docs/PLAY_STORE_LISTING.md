# Play Store — Guida pubblicazione AllergyGuard

Documento di riferimento. Contiene tutto il copia-incolla per Play Console.

## Costi e prerequisiti
- **Account Play Console**: $25 una tantum — https://play.google.com/console/signup
- Carta di credito/debito valida
- Documento d'identità (verifica Google, richiede 1–3 giorni)
- Numero di telefono

## File da caricare
- **AAB firmato**: `build/app/outputs/bundle/release/app-release.aab` (68.9 MB)
- **Icon 512×512**: `assets/branding/logo.png` (già nel repo)
- **Feature graphic 1024×500** (JPG/PNG, no trasparenza): DA CREARE
- **Screenshot phone** 2–8 immagini, portrait 1080×1920 (o simili, min 320px lato corto): DA FARE con emulator/device

---

## Dati app — Main store listing (italiano)

### App name (max 30 char)
```
AllergyGuard
```

### Short description (max 80 char)
```
Scansiona etichette e barcode per rilevare allergeni alimentari. 100% anonimo.
```

### Full description (max 4000 char)
```
AllergyGuard ti aiuta a verificare in pochi secondi se un prodotto alimentare contiene allergeni che potrebbero essere pericolosi per te.

🔍 COME FUNZIONA
• Scansiona il codice a barre del prodotto — controlla Open Food Facts
• Oppure fotografa l'etichetta — l'OCR legge gli ingredienti in tempo reale
• Riceve il risultato con codice colore: ROSSO pericolo, ARANCIONE attenzione, VERDE apparentemente sicuro, GRIGIO non verificabile
• Lettura vocale automatica per accessibilità

🍞 14 ALLERGENI UE + PERSONALIZZATI
Glutine, crostacei, uova, pesce, arachidi, soia, latte, frutta a guscio, sedano, senape, sesamo, solfiti, lupini, molluschi — più allergeni personalizzati che aggiungi tu.

🌍 MULTILINGUA
Riconosce ingredienti in 20 lingue. Interfaccia in italiano.

🔒 PRIVACY ASSOLUTA
• Nessun dato personale raccolto
• Nessun account richiesto
• Nessuna pubblicità
• Funziona anche offline
• Solo un ID anonimo casuale per evitare duplicati nei feedback

♿ ACCESSIBILITÀ
• Text-to-speech con velocità regolabile
• Contrasti alti
• Compatibile con lettori schermo

⚠️ AVVERTENZA IMPORTANTE
AllergyGuard è uno strumento di supporto informativo, NON una certificazione di sicurezza. Le informazioni provengono da database pubblici e lettura OCR automatica che possono contenere errori. In caso di allergie gravi, consulta sempre il medico e verifica personalmente l'etichetta del prodotto.

💚 OPEN SOURCE
AllergyGuard è software libero con licenza MIT. Codice su GitHub: github.com/frengo1972/AllergyGuard

📧 CONTATTI E FEEDBACK
allergyguard.app@gmail.com

🙏 RINGRAZIAMENTI
Dati prodotto da Open Food Facts (ODbL). Riconoscimento testo con Google ML Kit. Backend Supabase.
```

---

## Main store listing (English — optional, if supporting EN market)

### App name
```
AllergyGuard
```

### Short description
```
Scan labels and barcodes to detect food allergens. Fully anonymous.
```

### Full description (short EN version — expand if needed)
```
AllergyGuard helps you verify in seconds whether a food product contains allergens that could be dangerous for you.

🔍 HOW IT WORKS
• Scan the product barcode — checks Open Food Facts
• Or photograph the label — OCR reads ingredients in real time
• Color-coded result: RED danger, ORANGE warning, GREEN likely safe, GREY unverifiable
• Automatic voice readout for accessibility

🍞 14 EU ALLERGENS + CUSTOM
Gluten, crustaceans, eggs, fish, peanuts, soy, milk, tree nuts, celery, mustard, sesame, sulphites, lupin, molluscs — plus custom allergens you add yourself.

🌍 MULTILINGUAL
Recognises ingredients in 20 languages.

🔒 FULL PRIVACY
• No personal data collected
• No account required
• No ads
• Works offline
• Only an anonymous random ID to avoid duplicate feedback

⚠️ IMPORTANT DISCLAIMER
AllergyGuard is a support tool, NOT a safety certification. Data comes from public databases and automatic OCR that may contain errors. For severe allergies, always consult a doctor and personally verify product labels.

💚 OPEN SOURCE (MIT License)
github.com/frengo1972/AllergyGuard

📧 allergyguard.app@gmail.com
```

---

## Categorizzazione

- **App category**: `Health & Fitness` (Salute e fitness)
- **Tags**: `Nutrition`, `Medical`, `Food`
- **Contains ads**: **No**
- **In-app purchases**: **No**

---

## Content rating (questionario IARC)

Rispondi **No** a tutto:
- Violenza: No
- Sesso/nudità: No
- Linguaggio volgare: No
- Gioco d'azzardo: No
- Sostanze: No
- Horror: No
- Generato utenti: **NO** (il feedback commento è moderato lato server, non è UGC pubblico)
- Condivide posizione: No
- Accesso dati personali: No
- Acquisti digitali: No

Risultato atteso: **PEGI 3 / ESRB Everyone**.

---

## Data Safety form (Sicurezza dei dati)

### "Does your app collect or share any of the required user data types?"
**YES** (ma solo minimo)

### Data types collected
Solo queste voci:

1. **Device or other IDs**
   - Collected: ✅
   - Shared: ❌
   - Optional: ❌ (necessario per funzionamento)
   - Purpose: `App functionality`, `Analytics`
   - Nota: "Anonymous device ID (UUID v4) generated locally to avoid duplicate feedback submissions"

2. **App interactions** (sezione "App activity")
   - Collected: ✅
   - Shared: ❌
   - Optional: ❌
   - Purpose: `Analytics`, `App functionality`
   - Nota: "Aggregated feedback metrics (result level, country, app version)"

3. **Other user-generated content** (sezione "Messages")
   - Collected: ✅
   - Shared: ❌
   - Optional: ✅ (opzionale, solo se compila feedback)
   - Purpose: `App functionality`
   - Nota: "Optional free-text feedback comments submitted by the user"

### Data encryption
- **In transit**: ✅ YES (HTTPS via Supabase)
- **At rest**: ✅ YES (Supabase Postgres encryption)

### Data deletion
**YES** — l'utente può richiedere cancellazione scrivendo a allergyguard.app@gmail.com.
Privacy URL: `https://frengo1972.github.io/AllergyGuard/privacy.html`

---

## Permessi (già dichiarati in manifest)
- `android.permission.CAMERA` — scansione barcode e OCR
- `android.permission.INTERNET` — lookup Open Food Facts + invio feedback

Giustificazione in Play Console: "Camera permission is required to scan barcodes and capture label images for OCR ingredient analysis. No images are uploaded or stored on servers."

---

## Policy dichiarazioni
- **Government app**: No
- **COVID-19 contact tracing**: No
- **News app**: No
- **Ads**: No
- **Target audience**: 13+ (consigliato, app consultata anche da genitori per bambini allergici, ma non mirata a minori)

---

## URL obbligatori

| Campo | URL |
|-------|-----|
| Privacy Policy | https://frengo1972.github.io/AllergyGuard/privacy.html |
| Website | https://frengo1972.github.io/AllergyGuard/ |
| Email | allergyguard.app@gmail.com |
| Phone | (opzionale, lascia vuoto se non vuoi) |

---

## Asset grafici — checklist

### Icon launcher — FATTO
- 512×512 PNG: `assets/branding/logo.png` ✅
- Adaptive icons generate da flutter_launcher_icons ✅

### Feature graphic — DA CREARE
- **1024×500 pixel**, PNG o JPG, **no trasparenza, no testo essenziale** (il testo può essere tagliato su device piccoli)
- Suggerimento: logo centrato + slogan "Scan. Check. Safe." su sfondo blu brand #1976D2
- Tool rapido: Canva → template "Google Play Feature Graphic"

### Screenshot telefono — DA FARE
Min 2, max 8. Risoluzione: 1080×1920 (portrait). Min lato corto ≥ 320px, max 3840px.

Ordine suggerito:
1. **Onboarding welcome** — logo + slogan
2. **Selezione allergeni** — lista 14 allergeni UE con toggle
3. **Scanner attivo** — camera con overlay
4. **Risultato DANGER** — schermata rossa con allergene evidenziato
5. **Risultato SAFE** — schermata verde
6. **Storico** — lista scan
7. **Impostazioni privacy** — conferma "zero dati personali"

Come generare:
```
flutter run --release
# Su emulatore/device: usa screenshot Android (Volume Down + Power)
# Oppure Android Studio: View → Tool Windows → Logcat → Screenshot
```

### Screenshot tablet — OPZIONALE
Richiesti SOLO se supporti tablet. Per MVP mobile-only puoi skippare.

---

## Release flow

1. **Create app** in Play Console → Dashboard → "Create app"
   - Name: AllergyGuard
   - Default language: Italian (it-IT)
   - App or game: App
   - Free or paid: Free
   - Accetta dichiarazioni (developer program policies, US export laws)

2. **Dashboard steps** (completare uno per volta):
   - App access → "All functionality available without special access"
   - Ads → No
   - Content rating → Compila questionario (tutti No)
   - Target audience → 13+
   - News app → No
   - COVID-19 → No
   - Data safety → Compila come sopra
   - Government app → No
   - Financial features → No
   - Health → **Sì, health app** (dichiaralo perché riguarda allergie — aggiungi disclaimer che NON è dispositivo medico)

3. **Main store listing** → incolla testi sopra

4. **Production release**:
   - Testing → Internal testing (prima) → aggiungi la tua email come tester → carica AAB
   - Prova l'app via link tester
   - Poi Production → Create new release → upload AAB
   - Release notes: "Prima versione pubblica di AllergyGuard."
   - Submit for review

5. **Tempi review**: prima pubblicazione 3–7 giorni (verifica policy accurata). Update successive 2–24h.

---

## Checklist finale prima di submit

- [ ] AAB generato e testato su device reale
- [ ] key.properties salvato in luogo sicuro (keystore NON si può sostituire!)
- [ ] Screenshot 1080×1920 pronti (min 2)
- [ ] Feature graphic 1024×500 pronta
- [ ] Privacy URL raggiungibile (HTTP 200)
- [ ] Tutti i disclaimer in-app visibili
- [ ] Email contatto funzionante
- [ ] Migrations Supabase applicate su progetto production
- [ ] Testato flusso feedback end-to-end
- [ ] Testato scansione barcode reale
- [ ] Testato OCR su etichetta reale

## Dopo la prima release
- Monitora **Crashes & ANRs** in Play Console
- Controlla **feedback Supabase** (`user_feedback` table)
- Lascia almeno 7 giorni stable prima di push update grande
