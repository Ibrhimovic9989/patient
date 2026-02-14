# Refresh PATH in current PowerShell session
# This makes Flutter (installed via Scoop) available immediately

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "PATH refreshed! Flutter should now be available." -ForegroundColor Green
Write-Host "Verify with: flutter --version" -ForegroundColor Yellow
