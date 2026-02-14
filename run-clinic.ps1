# Run Clinic App
# This script refreshes PATH and runs the clinic app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Navigate to project root first
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Navigate to clinic directory
Set-Location clinic

# Check if .env exists
if (-not (Test-Path "..\.env")) {
    Write-Host "⚠ WARNING: .env file not found at project root!" -ForegroundColor Yellow
    Write-Host "Please create .env file with your Supabase credentials." -ForegroundColor Yellow
    Write-Host ""
}

# Run Flutter app directly (dev mode handles AssetManifest.json)
Write-Host "Starting Clinic App on http://localhost:50003..." -ForegroundColor Cyan
Write-Host "Note: AssetManifest.json errors are non-critical and won't affect functionality" -ForegroundColor Yellow
flutter run -d chrome --web-port=50003
