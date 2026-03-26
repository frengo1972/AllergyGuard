# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AllergyGuard is a Flutter mobile app (iOS + Android) that helps people with allergies verify if food products contain dangerous allergens. It works via barcode scanning (Open Food Facts API) and OCR label reading (ML Kit + Cloud Vision fallback). Results are classified as DANGER/WARNING/SAFE/UNKNOWN with TTS announcements for accessibility.

**Important:** The app is a decision-support tool, NOT a safety certification. Every result screen must display the mandatory disclaimer.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Generate Drift database and Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/core/allergen_pattern_engine_test.dart

# Analyze code
flutter analyze

# Format code
dart format lib/ test/
```

## Architecture

The project follows a layered architecture with four main layers:

### `lib/core/` — Business Logic Services
- **allergen_patterns/** — `AllergenPatternEngine` is the core matching engine. It normalizes OCR text, searches for allergen section patterns (contains/may_contain/facility), then matches user allergens across all languages. The result level logic: section found + allergen found → DANGER; allergen found without section → WARNING; section found without allergen → SAFE; no section → UNKNOWN.
- **ocr/** — `OcrService` is a facade: tries ML Kit on-device first, falls back to Cloud Vision if confidence < 60%.
- **scanner/** — Camera controller with 800ms frame throttling, ML Kit barcode scanner, and `OpenFoodFactsClient` with allergen tag mapping (e.g., `en:gluten` → `gluten`).
- **context_learning/** — Background pipeline that extracts new allergen context patterns from OCR text (60 chars before, 30 after the allergen), validates them via Claude API (claude-sonnet-4-20250514), and uploads candidates to Supabase. Thresholds: OCR confidence ≥ 85% to send, Claude confidence ≥ 70% to keep.
- **tts/** — Text-to-Speech wrapper with localized result messages and configurable speed.

### `lib/data/` — Persistence
- **local/** — Drift (SQLite) database with tables: `LocalAllergens`, `UserAllergenPrefs`, `LocalContextPatterns`, `ScanHistoryLocal`, `ProductCache`, `PendingPatternUploads`. DAOs in `dao/` subfolder. Run `build_runner` after modifying table definitions.
- **remote/** — Supabase client and remote repositories for pattern sync and community reports.

### `lib/domain/` — Models & Repository Interfaces
Pure Dart models (`Allergen`, `ScanResult`, `Product`) and abstract repository interfaces. No framework dependencies.

### `lib/ui/` — Screens
- **onboarding/** — 3-page PageView: welcome+disclaimer, allergen selection, optional login
- **scanner/** — Full-screen camera with barcode/OCR toggle, real-time OCR overlay
- **result/** — Color-coded result (red/orange/green/grey), haptic feedback, TTS auto-play, accordion for full label text, mandatory disclaimer
- **history/** — Chronological scan list with level filter and product search
- **allergen_setup/** — 14 EU allergens with toggles + custom allergen input
- **settings/** — TTS config, account, GDPR data deletion

### `lib/providers.dart` — Riverpod Dependency Injection
Central provider definitions for all services.

### `supabase/` — Backend
- **migrations/** — PostgreSQL schema with RLS policies
- **functions/** — Three Deno Edge Functions:
  - `promote-patterns`: scheduled 24h, promotes candidates to verified (seen_count ≥ 5, device_ids ≥ 3)
  - `validate-context`: trigger on INSERT, calls Claude API to validate/translate patterns
  - `sync-patterns`: called by client for incremental pattern updates

### `assets/allergens/` — Static Data
- `allergen_list.json` — 14 EU-regulated allergens with translations in 20 languages
- `context_patterns.json` — Initial verified patterns for IT/EN/DE/FR/ES, updated via Supabase sync

## Key Design Decisions

- **Offline-first:** OCR and pattern matching work fully offline. Barcode lookup falls back to local Drift cache. Context learning queues uploads for later sync.
- **Anonymous by default:** Auth is optional. Device ID (UUID v4 in SharedPreferences) is used for community deduplication. Migration from anonymous to account preserves all local data.
- **API keys:** `SUPABASE_ANON_KEY` is the only key in the client. `ANTHROPIC_API_KEY` and `GOOGLE_CLOUD_VISION_API_KEY` live only in Supabase Edge Functions — never in the app bundle.
- **Pattern learning pipeline:** Candidate patterns need validation from 5+ scans across 3+ devices before promotion to verified status.

## Environment Setup

Copy `.env.example` to `.env` and fill in the keys. Never commit `.env`.

## Implementation Phases

The spec defines 4 phases. Phase 1 (core scan + OCR + TTS) should be completed before moving to Phase 2 (barcode + OFF). See `AllergyGuard_Specifica_ClaudeCode.docx` for the complete specification.
