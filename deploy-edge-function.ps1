# Deploy Edge Function Script
# This script helps deploy the evaluate-assessments edge function to Supabase

Write-Host "=== Deploy Edge Function ===" -ForegroundColor Cyan
Write-Host ""

# Check if Supabase CLI is installed
$supabaseInstalled = Get-Command supabase -ErrorAction SilentlyContinue

if (-not $supabaseInstalled) {
    Write-Host "⚠ Supabase CLI not found!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please install Supabase CLI first:" -ForegroundColor Yellow
    Write-Host "  Option 1: scoop install supabase" -ForegroundColor Gray
    Write-Host "  Option 2: Download from https://github.com/supabase/cli/releases" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or deploy manually via Supabase Dashboard:" -ForegroundColor Yellow
    Write-Host "  1. Go to Supabase Dashboard → Edge Functions" -ForegroundColor Gray
    Write-Host "  2. Create/Edit function: evaluate-assessments" -ForegroundColor Gray
    Write-Host "  3. Copy contents of supabase/functions/evaluate-assessments/index.ts" -ForegroundColor Gray
    Write-Host "  4. Paste and Deploy" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Navigate to project root
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Checking Supabase login status..." -ForegroundColor Cyan
$loginStatus = supabase projects list 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ Not logged in to Supabase!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please login first:" -ForegroundColor Yellow
    Write-Host "  supabase login" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✅ Logged in to Supabase" -ForegroundColor Green
Write-Host ""

# Check if project is linked
Write-Host "Checking project link..." -ForegroundColor Cyan
$linkStatus = supabase status 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠ Project not linked!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please link your project first:" -ForegroundColor Yellow
    Write-Host "  supabase link --project-ref YOUR_PROJECT_REF" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Find your project ref in:" -ForegroundColor Gray
    Write-Host "  Supabase Dashboard → Settings → General → Reference ID" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✅ Project linked" -ForegroundColor Green
Write-Host ""

# Deploy the function
Write-Host "Deploying evaluate-assessments function..." -ForegroundColor Cyan
Write-Host "This may take a minute..." -ForegroundColor Gray
Write-Host ""

supabase functions deploy evaluate-assessments

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Function deployed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now test it in the patient app." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Deploy via Supabase Dashboard" -ForegroundColor Yellow
    Write-Host "  1. Go to Supabase Dashboard → Edge Functions" -ForegroundColor Gray
    Write-Host "  2. Create/Edit function: evaluate-assessments" -ForegroundColor Gray
    Write-Host "  3. Copy contents of supabase/functions/evaluate-assessments/index.ts" -ForegroundColor Gray
    Write-Host "  4. Paste and Deploy" -ForegroundColor Gray
}
