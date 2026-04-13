# Cattura screenshot per Play Store da emulatore/device Android.
# Usage:  powershell -ExecutionPolicy Bypass -File tools\capture_screens.ps1
#
# Requisiti: adb in PATH, emulatore Pixel 5 (1080x2340) o device collegato,
# AllergyGuard in esecuzione (flutter run --release).

$ErrorActionPreference = "Stop"
$OutDir = "docs/screenshots"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error "adb non trovato. Aggiungi %LOCALAPPDATA%\Android\Sdk\platform-tools al PATH."
    exit 1
}

$devices = (adb devices | Select-String "`tdevice" | Measure-Object).Count
if ($devices -eq 0) {
    Write-Error "Nessun device/emulatore connesso."
    exit 1
}

$shots = @(
    "01_onboarding_welcome",
    "02_allergen_selection",
    "03_scanner_camera",
    "04_result_danger",
    "05_result_safe",
    "06_history",
    "07_settings_privacy"
)

Write-Host ""
Write-Host "Screenshot tool AllergyGuard"
Write-Host "============================="
Write-Host "Output: $OutDir"
Write-Host "Screenshot da catturare: $($shots.Count)"
Write-Host ""

foreach ($name in $shots) {
    $response = Read-Host "[$name] posiziona la schermata e premi INVIO (s per skip)"
    if ($response -eq "s") {
        Write-Host "  -> skippato"
        continue
    }
    $path = Join-Path $OutDir "$name.png"
    adb exec-out screencap -p > $path
    $size = (Get-Item $path).Length
    Write-Host "  -> salvato $path ($size bytes)"
    Write-Host ""
}

Write-Host "Fatto. Screenshot in $OutDir/"
Write-Host "Play Store: min 320px lato corto, max 3840px, portrait consigliato."
