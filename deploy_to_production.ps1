
# Production Deployment Script for Modern POS
# This script compiles, obfuscates, and packages the app for distribution.

Write-Host "--- Starting Production Build (Code Protection Enabled) ---" -ForegroundColor Cyan

# 1. Build the release with Obfuscation to hide the code
Write-Host "[1/3] Compiling & Obfuscating Code..." -ForegroundColor Yellow
flutter build windows --release --obfuscate --split-debug-info=build/debug_info

# 2. Create the professional MSIX Installer
Write-Host "[2/3] Creating MSIX Installer..." -ForegroundColor Yellow
dart run msix:create

# 3. Move final file to C:\ for easy sharing
Write-Host "[3/3] Finalizing Installer..." -ForegroundColor Yellow
$installer = Get-Item "build\windows\x64\runner\Release\*.msix"
Move-Item -Path $installer.FullName -Destination "C:\نظام_المبيعات_الحديث.msix" -Force

Write-Host "--- SUCCESS! ---" -ForegroundColor Green
Write-Host "Final protected installer is ready at: C:\نظام_المبيعات_الحديث.msix" -ForegroundColor White
Write-Host "You can now share this file via WhatsApp." -ForegroundColor White
