# NeuroTrack Setup Script
# This script helps set up the project

Write-Host "NeuroTrack Setup Script" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Flutter is installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
        Write-Host "  Please install Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Please install Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Check if .env exists
Write-Host ""
Write-Host "Checking .env file..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "✓ .env file exists" -ForegroundColor Green
} else {
    Write-Host "✗ .env file not found" -ForegroundColor Red
    if (Test-Path ".env.example") {
        Write-Host "  Copying .env.example to .env..." -ForegroundColor Yellow
        Copy-Item ".env.example" ".env"
        Write-Host "✓ Created .env file from template" -ForegroundColor Green
        Write-Host "  ⚠ Please edit .env and add your actual credentials!" -ForegroundColor Yellow
    } else {
        Write-Host "  Creating .env file..." -ForegroundColor Yellow
        @"
# Supabase Credentials
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# Gemini API Key
GEMINI_API_KEY=your-gemini-api-key-here

# Google OAuth Credentials
GOOGLE_WEB_CLIENT_ID=your-google-web-client-id-here
GOOGLE_IOS_CLIENT_ID=your-google-ios-client-id-here
"@ | Out-File -FilePath ".env" -Encoding utf8
        Write-Host "✓ Created .env file" -ForegroundColor Green
        Write-Host "  ⚠ Please edit .env and add your actual credentials!" -ForegroundColor Yellow
    }
}

# Enable Flutter web
Write-Host ""
Write-Host "Enabling Flutter web support..." -ForegroundColor Yellow
flutter config --enable-web
Write-Host "✓ Flutter web enabled" -ForegroundColor Green

# Install dependencies for patient app
Write-Host ""
Write-Host "Installing dependencies for patient app..." -ForegroundColor Yellow
Set-Location patient
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Patient app dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install patient app dependencies" -ForegroundColor Red
}
Set-Location ..

# Install dependencies for therapist app
Write-Host ""
Write-Host "Installing dependencies for therapist app..." -ForegroundColor Yellow
Set-Location therapist
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Therapist app dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install therapist app dependencies" -ForegroundColor Red
}
Set-Location ..

Write-Host ""
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Edit .env file and add your Supabase credentials" -ForegroundColor White
Write-Host "2. Set up Supabase cloud project (see SETUP_GUIDE.md)" -ForegroundColor White
Write-Host "3. Run the apps with: flutter run -d chrome" -ForegroundColor White
Write-Host ""
