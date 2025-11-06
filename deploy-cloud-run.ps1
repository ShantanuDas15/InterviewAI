# Google Cloud Run Deployment Script for InterviewAI Backend
# Run this in PowerShell

Write-Host "=== InterviewAI Backend - Google Cloud Run Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Check if gcloud is installed
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: gcloud CLI is not installed!" -ForegroundColor Red
    Write-Host "Please install from: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ gcloud CLI found" -ForegroundColor Green

# Prompt for configuration
Write-Host ""
Write-Host "Please provide the following details:" -ForegroundColor Yellow
$PROJECT_ID = Read-Host "Enter Google Cloud Project ID (e.g., interviewai-backend)"
$REGION = Read-Host "Enter region (press Enter for us-central1)" 
if ([string]::IsNullOrEmpty($REGION)) { $REGION = "us-central1" }

# Environment Variables
Write-Host ""
Write-Host "Enter your environment variables:" -ForegroundColor Yellow
$DB_URL = Read-Host "DB_URL (Supabase JDBC URL)"
$DB_PASSWORD = Read-Host "DB_PASSWORD (Supabase password)" -AsSecureString
$DB_PASSWORD_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DB_PASSWORD))
$SUPABASE_URL = Read-Host "SUPABASE_URL"
$SUPABASE_JWT_SECRET = Read-Host "SUPABASE_JWT_SECRET" -AsSecureString
$SUPABASE_JWT_SECRET_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SUPABASE_JWT_SECRET))
$SUPABASE_SERVICE_ROLE_KEY = Read-Host "SUPABASE_SERVICE_ROLE_KEY" -AsSecureString
$SUPABASE_SERVICE_ROLE_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SUPABASE_SERVICE_ROLE_KEY))
$GEMINI_API_KEY = Read-Host "GEMINI_API_KEY" -AsSecureString
$GEMINI_API_KEY_PLAIN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($GEMINI_API_KEY))

Write-Host ""
Write-Host "=== Setting up Google Cloud ===" -ForegroundColor Cyan

# Set project
Write-Host "Setting project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Enable required APIs
Write-Host "Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable secretmanager.googleapis.com

Write-Host ""
Write-Host "=== Creating Secrets ===" -ForegroundColor Cyan

# Create secrets
Write-Host "Creating secret: db-url..."
echo $DB_URL | gcloud secrets create db-url --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $DB_URL | gcloud secrets versions add db-url --data-file=-
}

Write-Host "Creating secret: db-password..."
echo $DB_PASSWORD_PLAIN | gcloud secrets create db-password --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $DB_PASSWORD_PLAIN | gcloud secrets versions add db-password --data-file=-
}

Write-Host "Creating secret: supabase-url..."
echo $SUPABASE_URL | gcloud secrets create supabase-url --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $SUPABASE_URL | gcloud secrets versions add supabase-url --data-file=-
}

Write-Host "Creating secret: supabase-jwt-secret..."
echo $SUPABASE_JWT_SECRET_PLAIN | gcloud secrets create supabase-jwt-secret --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $SUPABASE_JWT_SECRET_PLAIN | gcloud secrets versions add supabase-jwt-secret --data-file=-
}

Write-Host "Creating secret: supabase-service-role-key..."
echo $SUPABASE_SERVICE_ROLE_KEY_PLAIN | gcloud secrets create supabase-service-role-key --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $SUPABASE_SERVICE_ROLE_KEY_PLAIN | gcloud secrets versions add supabase-service-role-key --data-file=-
}

Write-Host "Creating secret: gemini-api-key..."
echo $GEMINI_API_KEY_PLAIN | gcloud secrets create gemini-api-key --data-file=- 2>$null
if ($LASTEXITCODE -ne 0) {
    echo $GEMINI_API_KEY_PLAIN | gcloud secrets versions add gemini-api-key --data-file=-
}

Write-Host ""
Write-Host "=== Deploying to Cloud Run ===" -ForegroundColor Cyan
Write-Host "This may take 5-10 minutes..." -ForegroundColor Yellow

cd interviewai_backend

gcloud run deploy interviewai-backend `
  --source . `
  --platform managed `
  --region $REGION `
  --allow-unauthenticated `
  --set-env-vars="DB_USERNAME=postgres,GEMINI_API_URL=https://generativelanguage.googleapis.com/v1beta/models" `
  --set-secrets="DB_URL=db-url:latest,DB_PASSWORD=db-password:latest,SUPABASE_URL=supabase-url:latest,SUPABASE_JWT_SECRET=supabase-jwt-secret:latest,SUPABASE_SERVICE_ROLE_KEY=supabase-service-role-key:latest,GEMINI_API_KEY=gemini-api-key:latest" `
  --memory 1Gi `
  --cpu 1 `
  --timeout 300 `
  --min-instances 0 `
  --max-instances 10

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Deployment Successful! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend is now live!" -ForegroundColor Cyan
    Write-Host "Get your service URL with:" -ForegroundColor Yellow
    Write-Host "  gcloud run services describe interviewai-backend --region $REGION --format='value(status.url)'"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Copy the service URL"
    Write-Host "2. Update frontend/lib/constants/api_constants.dart"
    Write-Host "3. Deploy frontend to Netlify/Vercel"
} else {
    Write-Host ""
    Write-Host "=== Deployment Failed ===" -ForegroundColor Red
    Write-Host "Check the logs above for errors"
}
