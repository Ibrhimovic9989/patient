# Copy .env file to app directories for Flutter web support
# This script should be run whenever .env is updated

Write-Host "Copying .env to app directories..." -ForegroundColor Yellow

if (Test-Path ".env") {
    Copy-Item ".env" "patient\.env" -Force
    Copy-Item ".env" "therapist\.env" -Force
    Write-Host ".env copied to patient/ and therapist/ directories" -ForegroundColor Green
} else {
    Write-Host ".env file not found at project root!" -ForegroundColor Red
    Write-Host "Please create .env file first." -ForegroundColor Yellow
    exit 1
}
