# Run Therapist App
# This script refreshes PATH and runs the therapist app

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Navigate to project root first
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Navigate to therapist directory
Set-Location therapist

# Check if .env exists
if (-not (Test-Path "..\.env")) {
    Write-Host "⚠ WARNING: .env file not found at project root!" -ForegroundColor Yellow
    Write-Host "Please create .env file with your Supabase credentials." -ForegroundColor Yellow
    Write-Host ""
}

# Clean and rebuild to fix AssetManifest.json issues
Write-Host "Cleaning build cache..." -ForegroundColor Yellow
flutter clean

Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build for web first to generate AssetManifest.json properly
Write-Host "Building for web (this ensures AssetManifest.json is generated)..." -ForegroundColor Yellow
flutter build web

# Run Flutter app
Write-Host "Starting Therapist App on http://localhost:50002..." -ForegroundColor Cyan
Write-Host "This may take a moment on first run..." -ForegroundColor Gray
flutter run -d chrome --web-port=50002
