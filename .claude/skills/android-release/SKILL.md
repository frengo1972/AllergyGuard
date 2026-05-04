---
name: android-release
description: >
  Full Android release pipeline for AllergyGuard. Runs analyze + tests, bumps
  version (patch/minor/major), builds release AAB, then generates a Play Store
  release name and multilingual release notes (it-IT, en-US, zh-CN, ja-JP,
  fr-FR, es-ES). Use when user says "prepara release android", "nuova build
  android", "fai la release", "android release", or invokes /android-release.
---

## Steps (execute in order)

### 1. Verify

```bash
flutter analyze
flutter test
```

If analyze or tests fail: stop, report errors, do NOT proceed.

### 2. Bump version

Read current version from `pubspec.yaml` (`version: X.Y.Z+N`).

- Default: bump **patch** (Z+1) and **build number** (N+1)
- If user specifies "minor" or "major": bump accordingly, reset lower parts
- Write new version back to `pubspec.yaml`

Report: "Versione aggiornata: X.Y.Z+N → X.Y.Z+N"

### 3. Build AAB

```bash
flutter build appbundle --release
```

Expected output artifact: `build/app/outputs/bundle/release/app-release.aab`

Report size in MB on success. Stop and report on failure.

### 4. Generate release name

Format: `vX.Y.Z – <short description of main change in Italian>`

Derive the description from:
- Recent git commits since the previous tag or last 5 commits
- The most impactful change visible in the diff

Examples:
- `v1.0.5 – OCR cinese, giapponese e coreano`
- `v1.1.0 – Barcode scanner migliorato`
- `v1.0.6 – Fix crash Android 14`

### 5. Generate release notes

Summarize the changes in 2-3 bullet points, concise and user-facing (not technical).
Output in Play Store format for these locales:

```
<it-IT>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</it-IT>

<en-US>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</en-US>

<zh-CN>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</zh-CN>

<ja-JP>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</ja-JP>

<fr-FR>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</fr-FR>

<es-ES>
[bullet 1]
[bullet 2]
[bullet 3 if needed]
</es-ES>
```

Rules for release notes:
- User-facing language, no technical jargon
- Max 500 chars per locale
- Describe WHAT improved for the user, not HOW it was implemented
- Do NOT mention internal class names, file names, or PR numbers
- Translate faithfully — do not reuse English phrases transliterated

### 6. Final report

Output a summary block:

```
AAB: build/app/outputs/bundle/release/app-release.aab (XX.X MB)
Versione: X.Y.Z+N
Release name: vX.Y.Z – ...
Note di rilascio: [pasted above]
```
