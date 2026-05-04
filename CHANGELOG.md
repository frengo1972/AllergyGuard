# Changelog

## [1.0.4] - 2026-05-04

### Fixed
- **OCR crash on CJK recognizers**: Disabled Chinese/Japanese/Korean text recognition for still capture. These models are not included in all ML Kit builds, causing `ClassNotFoundException` on Android devices. Now only Latin script is used for still capture (works offline on all devices)

### Notes
- Trade-off: still captures no longer support CJK text recognition, but app now runs without crashes on all Android devices
- Stream OCR (real-time preview) already used Latin-only, so no functional change for live scanning

---

## [1.0.3] - 2026-05-04

### Fixed
- **Camera crash on Android**: Fixed `NullPointerException` in camera plugin's `unlockAutoFocus()` by locking focus mode before capture to prevent race conditions on some Android devices
- **OCR crash on missing language models**: Fixed `NoClassDefFoundError` when ML Kit Text Recognition tries to initialize Chinese/Japanese/Korean recognizers on devices without those models installed. Now gracefully falls back to Latin script recognition

### Changed
- Updated `camera` dependency from `0.10.5` to `0.11.4` for stability improvements
- Moved exception handling in `_runScripts()` to catch errors during TextRecognizer initialization, not just during recognition

### Notes
- App now handles gracefully when optional language models are unavailable
- Camera focus is now locked during still capture to prevent native-level race conditions

---

## [1.0.2] - Previous
- Initial release and prior versions
