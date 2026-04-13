#!/usr/bin/env bash
# Cattura screenshot per Play Store da emulatore/device Android collegato.
# Usage: bash tools/capture_screens.sh
#
# Requisiti:
# - adb in PATH (fornito da Android SDK / Android Studio)
# - Emulatore o device reale collegato con app AllergyGuard aperta
# - Risoluzione emulatore consigliata: 1080x1920 (Pixel 5 / Pixel 4)
#
# Flusso:
# 1. Lancia in un altro terminale: flutter run --release
# 2. Naviga all'onboarding welcome
# 3. Esegui questo script
# 4. Per ogni schermata: posizionala nell'emulatore, premi INVIO
# 5. Output in docs/screenshots/
set -euo pipefail

OUT_DIR="docs/screenshots"
mkdir -p "$OUT_DIR"

if ! command -v adb >/dev/null 2>&1; then
  echo "ERRORE: adb non trovato in PATH."
  echo "Aggiungi %LOCALAPPDATA%\\Android\\Sdk\\platform-tools al PATH Windows."
  exit 1
fi

DEVICES=$(adb devices | grep -w "device" | wc -l)
if [ "$DEVICES" -eq 0 ]; then
  echo "ERRORE: nessun device/emulatore connesso."
  echo "Avvia l'emulatore o collega un device via USB (debug abilitato)."
  exit 1
fi

SHOTS=(
  "01_onboarding_welcome"
  "02_allergen_selection"
  "03_scanner_camera"
  "04_result_danger"
  "05_result_safe"
  "06_history"
  "07_settings_privacy"
)

echo ""
echo "Screenshot tool AllergyGuard"
echo "============================="
echo "Output: $OUT_DIR"
echo "Screenshot da catturare: ${#SHOTS[@]}"
echo ""

for name in "${SHOTS[@]}"; do
  echo "[$name] posiziona la schermata nell'emulatore, poi premi INVIO (s per skip)..."
  read -r key
  if [ "${key:-}" = "s" ]; then
    echo "  -> skippato"
    continue
  fi
  adb exec-out screencap -p > "$OUT_DIR/${name}.png"
  SIZE=$(wc -c < "$OUT_DIR/${name}.png")
  echo "  -> salvato $OUT_DIR/${name}.png ($SIZE bytes)"
  echo ""
done

echo "Fatto. Controlla gli screenshot in $OUT_DIR/"
echo "Se la risoluzione non va bene per Play Store:"
echo "  - Min 320px lato corto, max 3840px"
echo "  - Portrait consigliato per app mobile"
echo "  - Aspect ratio tra 9:16 e 16:9"
