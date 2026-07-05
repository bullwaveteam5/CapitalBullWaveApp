# BullWave — reliable Flutter web launch on Windows (fixes locked build/ folder).
# Usage: .\run_chrome.ps1

$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot

Write-Host "Stopping leftover Dart/Flutter/Chrome dev processes..." -ForegroundColor Cyan
Get-Process dart, dartaotruntime -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Cleaning build cache..." -ForegroundColor Cyan
if (Test-Path "build") {
    cmd /c "rmdir /s /q build" 2>$null
    if (Test-Path "build") {
        Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
    }
}
flutter clean 2>$null | Out-Null

flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Launching on Chrome (port 7357)..." -ForegroundColor Green
flutter run -d chrome --web-port=7357
