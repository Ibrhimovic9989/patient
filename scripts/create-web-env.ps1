# PowerShell script to create .env file in web directory from environment variables
# This script is called during Vercel build (if using Windows build environment)

$webDir = "web"
if (Test-Path "..\$webDir") {
    $webDir = "..\$webDir"
}

# Create .env file in web directory
$envContent = @"
SUPABASE_URL=$env:SUPABASE_URL
SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
GEMINI_API_KEY=$env:GEMINI_API_KEY
"@

$envContent | Out-File -FilePath "$webDir\.env" -Encoding utf8 -NoNewline

Write-Host "Created .env file in $webDir\.env"
Write-Host ($envContent -replace '=.*', '=***') # Show file with masked values
