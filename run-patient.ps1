# Run Patient App
# This script refreshes PATH and runs the patient app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Navigate to project root first
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Navigate to patient directory
Set-Location patient

# Check if .env exists
if (-not (Test-Path "..\.env")) {
    Write-Host "⚠ WARNING: .env file not found at project root!" -ForegroundColor Yellow
    Write-Host "Please create .env file with your Supabase credentials." -ForegroundColor Yellow
    Write-Host ""
}

# Run Flutter app directly (dev mode handles AssetManifest.json)
Write-Host "Starting Patient App on http://localhost:50001..." -ForegroundColor Cyan
Write-Host "Note: AssetManifest.json errors are non-critical and won't affect functionality" -ForegroundColor Yellow
flutter run -d chrome --web-port=50001
