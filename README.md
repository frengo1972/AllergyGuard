<div align="center">

# 🛡️ AllergyGuard

**Scan food labels. Detect allergens. Stay safe.**

*A Flutter mobile app that puts allergy safety in your pocket.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.5-blue.svg)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev/multi-platform)
[![Open Food Facts](https://img.shields.io/badge/data-Open%20Food%20Facts-brightgreen)](https://world.openfoodfacts.org/)

</div>

---

## 📖 Overview

**AllergyGuard** is an open-source mobile application for Android and iOS that helps people living with food allergies quickly and reliably verify whether a product contains dangerous allergens — before consuming it.

The app combines two complementary scanning methods:

- **Barcode scanning** — queries the [Open Food Facts](https://world.openfoodfacts.org/) database (millions of products worldwide)
- **OCR label reading** — photographs ingredient labels and reads them in real time using on-device ML Kit, with Cloud Vision as a fallback

Results are displayed as a clear **color-coded safety level** (🔴 DANGER / 🟠 WARNING / 🟢 SAFE / ⚫ UNKNOWN) with **voice readout** for maximum accessibility.

> ⚠️ **AllergyGuard is a decision-support tool, NOT a medical safety certification.** Results depend on the accuracy of public databases and OCR recognition. Always verify labels personally for serious allergies and consult your physician.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 📷 **Barcode Scanner** | Instant product lookup via Open Food Facts API |
| 🔤 **OCR Label Reader** | Real-time ingredient text recognition with ML Kit |
| 🧠 **AI Pattern Engine** | Context-aware allergen matching across 20 languages |
| 🔊 **Text-to-Speech** | Auto-reads results aloud with configurable speed |
| 📴 **Offline-First** | Full OCR and pattern matching work without internet |
| 🕵️ **100% Anonymous** | No account required, no personal data collected |
| 📚 **Scan History** | Local log of all past scans with search and filter |
| 🌍 **Multilingual** | Detects allergens in ingredient text in 20 languages |
| ♿ **Accessible** | High contrast, TTS, screen reader compatible |
| 🤖 **Community Learning** | AI-validated crowd-sourced pattern improvement pipeline |

---

## 🍞 Supported Allergens

All **14 EU-regulated allergens** (Regulation EU 1169/2011) plus unlimited custom allergens:

> Gluten · Crustaceans · Eggs · Fish · Peanuts · Soy · Milk · Tree nuts · Celery · Mustard · Sesame · Sulphites · Lupin · Molluscs

---

## 🏗️ Architecture

AllergyGuard follows a clean **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│              UI Layer (lib/ui/)          │
│  Onboarding · Scanner · Result ·        │
│  History · Allergen Setup · Settings    │
├─────────────────────────────────────────┤
│          Providers (Riverpod DI)        │
├──────────────────┬──────────────────────┤
│  Core Services   │   Domain Models      │
│  (lib/core/)     │   (lib/domain/)      │
│                  │                      │
│ • PatternEngine  │ • Allergen           │
│ • OcrService     │ • ScanResult         │
│ • Scanner        │ • Product            │
│ • ContextLearning│ • Repository IFaces  │
│ • TtsService     │                      │
├──────────────────┴──────────────────────┤
│           Data Layer (lib/data/)        │
│   Drift/SQLite (local) · Supabase       │
└─────────────────────────────────────────┤
│         External Services               │
│  Open Food Facts · ML Kit · Cloud Vision│
│  Supabase Edge Functions · Claude AI    │
└─────────────────────────────────────────┘
```

### Core Engine: AllergenPatternEngine

The heart of the app. It:
1. Normalizes OCR text (strips noise, normalizes unicode)
2. Detects allergen section context (`contains` / `may contain` / `made in facility with`)
3. Matches user allergens using verified patterns in all supported languages
4. Returns a classified result: **DANGER** · **WARNING** · **SAFE** · **UNKNOWN**

### Community Learning Pipeline

A background AI pipeline continuously improves pattern recognition:

```
OCR scan ──► extract context window ──► validate via Claude AI
    │              (60 chars before,        (confidence ≥ 70%)
    │               30 chars after)               │
    └──────────────────────────────► upload to Supabase
                                            │
                          5+ scans · 3+ devices
                                            │
                                     promote to verified ──► sync to all clients
```

---

## 🛠️ Tech Stack

### Mobile (Flutter / Dart)

| Layer | Technology |
|---|---|
| Framework | [Flutter 3.x](https://flutter.dev) + Dart 3.3+ |
| State Management | [Riverpod](https://riverpod.dev) (with code generation) |
| Local Database | [Drift](https://drift.simonbinder.eu/) (SQLite, type-safe ORM) |
| OCR (on-device) | [Google ML Kit Text Recognition](https://developers.google.com/ml-kit/vision/text-recognition) |
| Barcode Scanner | [Google ML Kit Barcode Scanning](https://developers.google.com/ml-kit/vision/barcode-scanning) |
| OCR (cloud fallback) | [Google Cloud Vision API](https://cloud.google.com/vision) |
| Text-to-Speech | [flutter_tts](https://pub.dev/packages/flutter_tts) |
| HTTP Client | [Dio](https://pub.dev/packages/dio) |
| Camera | [camera](https://pub.dev/packages/camera) |

### Backend (Supabase + Deno)

| Component | Technology |
|---|---|
| Database | [PostgreSQL](https://www.postgresql.org/) with Row Level Security |
| Auth | [Supabase Auth](https://supabase.com/auth) (optional, anonymous-first) |
| Edge Functions | [Deno](https://deno.land/) (TypeScript) |
| AI Validation | [Anthropic Claude](https://www.anthropic.com/) (claude-sonnet) |
| Pattern sync | Incremental pull via `sync-patterns` edge function |

### Security & Privacy

- API keys (`ANTHROPIC_API_KEY`, `GOOGLE_CLOUD_VISION_API_KEY`) live **only in Supabase Edge Functions** — never in the app bundle
- Only `SUPABASE_ANON_KEY` is on the client (safe to expose by design)
- Device identified by a random UUID v4 — no personal data ever collected
- GDPR-compliant: full data deletion available from settings

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.3
- Android Studio / Xcode for device emulation
- A [Supabase](https://supabase.com) project (for backend features)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/frengo1972/AllergyGuard.git
cd AllergyGuard

# 2. Configure environment variables
cp .env.example .env
# Edit .env with your Supabase URL and anon key

# 3. Install dependencies
flutter pub get

# 4. Generate code (Drift DB + Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# 5. Run on device or emulator
flutter run
```

### Supabase Setup

```bash
# Apply database migrations
supabase db push

# Deploy edge functions
supabase functions deploy promote-patterns
supabase functions deploy validate-context
supabase functions deploy sync-patterns
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/core/allergen_pattern_engine_test.dart

# Static analysis
flutter analyze

# Format code
dart format lib/ test/
```

---

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── providers.dart            # Riverpod dependency injection
├── core/
│   ├── allergen_patterns/    # Core matching engine
│   ├── ocr/                  # OCR facade (ML Kit + Cloud Vision)
│   ├── scanner/              # Camera + barcode + Open Food Facts
│   ├── context_learning/     # Community AI learning pipeline
│   └── tts/                  # Text-to-Speech wrapper
├── data/
│   ├── local/                # Drift SQLite database + DAOs
│   └── remote/               # Supabase repositories
├── domain/                   # Pure Dart models + interfaces
└── ui/
    ├── onboarding/           # Welcome · allergen setup · login
    ├── scanner/              # Camera screen with live OCR overlay
    ├── result/               # Color-coded result + TTS + disclaimer
    ├── history/              # Scan history with filters
    ├── allergen_setup/       # 14 EU allergens + custom input
    └── settings/             # TTS, account, GDPR data deletion

assets/
├── allergens/
│   ├── allergen_list.json    # 14 allergens × 20 language translations
│   └── context_patterns.json # Verified recognition patterns (IT/EN/DE/FR/ES)
└── branding/

supabase/
├── migrations/               # PostgreSQL schema with RLS
├── functions/                # Deno edge functions
└── seeds/
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to help:

1. **Fork** the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'feat: add something useful'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a **Pull Request**

Areas where help is especially appreciated:
- 🌍 New language translations for allergen patterns
- 🧪 Additional test coverage
- ♿ Accessibility improvements
- 🐛 Bug reports and fixes

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- 🥫 Product data from [Open Food Facts](https://world.openfoodfacts.org/) (ODbL license)
- 🔤 On-device OCR by [Google ML Kit](https://developers.google.com/ml-kit)
- ☁️ Backend infrastructure by [Supabase](https://supabase.com)
- 🤖 AI pattern validation by [Anthropic Claude](https://www.anthropic.com)

---

## 📬 Contact

**Issues & Feature Requests:** [GitHub Issues](https://github.com/frengo1972/AllergyGuard/issues)  
**Email:** allergyguard.app@gmail.com

---

<div align="center">
<sub>Built with ❤️ for the allergy community · <a href="https://github.com/frengo1972/AllergyGuard">github.com/frengo1972/AllergyGuard</a></sub>
</div>
